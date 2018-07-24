function iqloadsettings(handles)
    try
        h = handles.iqtool;
    catch ex
        msgbox('Incompatible IQTools utility');
        return;
    end
    [filename pathname] = uigetfile('*.m;*.fig');
    if (filename ~= 0)
        [path, name, ext] = fileparts(filename);
        % if user selects a .fig file, assume it is in the old format
        % where simply the whole dialog was saved
        if (strcmp(ext, '.fig') || strcmp(ext, '.FIG'))
            try
                cf = gcf;
                hgload(strcat(pathname, filename));
                close(cf);
                msgbox({'You just loaded settings in an old format that is no longer supported.' ...
                    'To convert them to the current format, please save the settings again as' ...
                    'a .m file, close the utility, reopen it and load the file .m file again'});
            catch ex
                errordlg(ex.message);
            end
       else
            try
                f = fopen(strcat(pathname, filename), 'r');
            catch ex
                msgbox('Can''t open file');
                return;
            end
            a = fread(f, inf, 'uint8=>char');
            try
                eval(a);
            catch ex;
            end
            if (~exist('errCnt', 'var') || ~exist('savedFigure', 'var'))
                msgbox('Invalid settings file');
                return;
            end
            [pathstr, filename, ext] = fileparts(get(h, 'Filename'));
            if (~strcmp(savedFigure, strcat(filename, ext)))
                msgbox({'This settings file belongs to a different IQTools utility.'});
                return;
            end
            if (errCnt ~= 0)
                msgbox({'One or more GUI elements could not be loaded.' ...
                    'Please check that the settings file matches the version of the utility'});
            end
        end
    end
end


