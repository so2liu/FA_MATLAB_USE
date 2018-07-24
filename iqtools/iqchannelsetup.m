function str = iqchannelsetup(cmd, pb, arbConfig, type)
% helper function for channel mapping dialog
% cmd - one of 'setup', 'mkstring', 'arraystring' (see comments below)
% pb - pushbutton object
% arbConfig - the current arbConfig struct
% type - 'single' or 'IQ' (default: IQ)
%
% The "UserData" property of the channel mapping pushbutton contains the
% current channel mapping array
% Depending on the 'cmd' argument, this function initilizes the "UserData"
% property; converts it to string for the pushbutton or a string for the
% Generate MATLAB code function
%
if (~exist('type', 'var'))
    type = 'IQ';
end
switch (cmd)
    % set up the UserData with channelMapping array and String fields of the pushbutton
    % according to the selected AWG model and operation mode
    case 'setup'
        ud = get(pb, 'UserData');
        if (isempty(ud))
            % channel mapping is not defined at all yet -> set default values
            if (arbConfig.numChannels > 2 || ...
                (~isempty(strfind(arbConfig.model, 'M8190A')) && isfield(arbConfig, 'visaAddr2')))
                ud = [1 0; 1 0; 0 1; 0 1];
            elseif (arbConfig.numChannels >= 2)
                if (strcmp(arbConfig.model, 'M8195A_2ch'))
                    ud = [1 0; 0 0; 0 0; 0 1];
                elseif (strcmp(arbConfig.model, 'M8195A_2ch_mrk'))
                    ud = [1 0; 0 1; 0 0; 0 0];
                else
                    ud = [1 0; 0 1];
                end
            else
                ud = [1 0];
            end
        else
            % channel mapping is already defined
            if (arbConfig.numChannels > 2 || ...
                (~isempty(strfind(arbConfig.model, 'M8190A')) && isfield(arbConfig, 'visaAddr2')))
                if (length(ud) < 4)
                    ud(3:4,:) = [1 0; 0 1];
                end
            elseif (arbConfig.numChannels >= 2)
                if (strcmp(arbConfig.model, 'M8195A_2ch'))
                    ud(2:3,:) = [0 0; 0 0];
                elseif (strcmp(arbConfig.model, 'M8195A_2ch_mrk'))
                    ud(3:4,:) = [0 0; 0 0];
                else
                    ud(3:end,:) = [];
                end
            else
                ud(2:end,:) = [];
            end
        end
        % don't do pulses on all channels...
%         if (strcmp(type, 'pulse') && length(ud) == 4)
%             ud = [1 0; 0 0; 0 0; 0 1];
%         end
        duc = (~isempty(strfind(arbConfig.model, 'DUC')));
        if (duc)
            ud(:,1) = (ud(:,1) + ud(:,2)) ~= 0;
            ud(:,2) = ud(:,1);
        else
            idx = find(ud(:,1) .* ud(:,2));
            idx1 = idx;
            idx1(mod(idx,2)~=0) = [];
            ud(idx1,1) = 0;
            idx2 = idx;
            idx2(mod(idx,2)==0) = [];
            ud(idx2,2) = 0;
        end
        if (strcmp(type, 'single'))
            ud(:,1) = (ud(:,1) + ud(:,2) > 0);
            ud(:,2) = 0;
        end
        set(pb, 'UserData', ud);
        set(pb, 'String', iqchannelsetup('mkstring', ud, arbConfig, type));
    % convert channelMapping into a string that is displayed on the download pushbutton
    case 'mkstring'
        if (~isempty(pb))
            if (strcmp(type, 'single'))
                pre = '';
            else
                pre = 'I to ';
            end
            chs1 = find(pb(:,1));
            if (isempty(chs1))
                str = '';
            else
                str = sprintf('%sCh%s', pre, sprintf('%d+', chs1));
                str(end) = [];
            end
            if (~strcmp(pre, ''))
                chs2 = find(pb(:,2));
                if (~isempty(chs2))
                    if (~isempty(chs1))
                        str = sprintf('%s, ', str);
                    end
                    str = sprintf('%sQ to Ch%s', str, sprintf('%d+', chs2));
                    str(end) = [];
                end
            end
            str = sprintf('%s...', str);
        else
            str = '...';
        end
    % convert channelMapping into a string for the "Generate MATLAB code" function
    case 'arraystring'
        str = '[';
        for i=1:size(pb,1)
            str = sprintf('%s%s', str, sprintf('%d ', pb(i,:)));
            str(end) = [];
            if (i ~= size(pb,1))
                str = sprintf('%s; ', str);
            end
        end
        str = sprintf('%s]', str);
end

