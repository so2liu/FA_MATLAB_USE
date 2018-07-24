function iqsavesettings(handles)
    if (isfield(handles, 'iqtool'))
        h = handles.iqtool;
    elseif (isfield(handles, 'figure1'))
        h = handles.figure1;
    else
        msgbox('Incompatible IQTools utility');
        return;
    end
    [filename pathname] = uiputfile('*.m');
    if (filename ~= 0)
        try
            f = fopen(strcat(pathname, filename), 'w');
        catch ex
            msgbox('Can''t open file');
            return;
        end
        fprintf(f, '%%\n');
        fprintf(f, '%% Settings for: %s\n', get(h, 'Name'));
        fprintf(f, '%%\n');
        [pathstr, filename, ext] = fileparts(get(h, 'Filename'));
        fprintf(f, 'savedFigure = ''%s%s'';\n', filename, ext);
        fprintf(f, 'errCnt = 0;\n');
        if (~isempty(f))
            iqsave2(f, h);
            fclose(f);
        end
    end
end

function iqsave2(f, h)
    type = get(h, 'Type');
    if (strcmp(type, 'uicontrol'))
        style = get(h, 'Style');
        switch (style)
            case 'edit'
                fprintf(f, 'try\n');
                fprintf(f, '   set(handles.%s, ''String'', ''%s'');\n', get(h, 'Tag'), get(h, 'String'));
                fprintf(f, '   set(handles.%s, ''Enable'', ''%s'');\n', get(h, 'Tag'), get(h, 'Enable'));
                fprintf(f, 'catch ex; errCnt = errCnt + 1; end\n');
            case { 'checkbox' 'popupmenu' }
                fprintf(f, 'try\n');
                fprintf(f, '   set(handles.%s, ''Value'', %d);\n', get(h, 'Tag'), get(h, 'Value'));
                fprintf(f, '   set(handles.%s, ''Enable'', ''%s'');\n', get(h, 'Tag'), get(h, 'Enable'));
                fprintf(f, 'catch ex; errCnt = errCnt + 1; end\n');
            case { 'text' }
                if (strcmp(get(h, 'Visible'), 'off'))
                    fprintf(f, 'try\n');
                    fprintf(f, '   set(handles.%s, ''Visible'', ''%s'');\n', get(h, 'Tag'), get(h, 'Visible'));
                    fprintf(f, 'catch ex; errCnt = errCnt + 1; end\n');
                end
        end
    elseif (strcmp(type, 'uitable'))
        fprintf(f, 'try\n');
        data = get(h, 'Data');
        colFmt = get(h, 'ColumnFormat');
        fprintf(f, '   data = cell(%d, %d);\n', size(data,1), size(data,2));
        for k=1:size(data,1);
            for l=1:size(data,2);
                val = data{k,l};
                c = colFmt{l};
                if (iscell(c) || strcmp(c, 'char'))
                    fprintf(f, '   data{%d,%d} = ''%s'';\n', k, l, val);
                elseif (strcmp(c, 'numeric'))
                    if (isempty(val))
                        fprintf(f, '   data{%d,%d} = [];\n', k, l);
                    else
                        fprintf(f, '   data{%d,%d} = %d;\n', k, l, val);
                    end
                elseif (strcmp(c, 'logical'))
                    if (val)
                        fprintf(f, '   data{%d,%d} = true;\n', k, l);
                    else
                        fprintf(f, '   data{%d,%d} = false;\n', k, l);
                    end
                else
                    disp(['unexpected data type in table: ' colFmt]);
                end
            end
        end
        fprintf(f, '   set(handles.%s, ''Data'', data);\n', get(h, 'Tag'));
        fprintf(f, 'catch ex; errCnt = errCnt + 1; end\n');
    end
    try
        hc = get(h, 'Children');
        for (hi=1:length(hc))
            iqsave2(f, hc(hi));
        end
    catch ex
    end
end