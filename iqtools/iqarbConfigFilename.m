function filename = iqarbConfigFilename()
% returns the name of the file in which the IQtools configuration is stored

global arbConfigFilename;

basename = 'arbConfig.mat';
% first, check if we already have a location
if (exist('arbConfigFilename', 'var') && ~isempty(arbConfigFilename))
    filename = arbConfigFilename;
else
    % check if it exists in the current directory (legacy location)
    filename = basename;
    try
        f = fopen(filename, 'r');
        fclose(f);
    catch
        % fallback filename if actions below fail
        filename = ['c:\' basename];
        % second choice: location of the current executable/script
        try
            if isdeployed % Stand-alone mode
                [~, result] = system('path');
                filename = fullfile(char(regexpi(result, 'Path=(.*?);', 'tokens', 'once')), basename);
            else % MATLAB mode
                filename = fullfile(fileparts(which('vsafunc')), basename);
            end
        catch
        end
        % first choice: \users\xxx\AppData\Local\Keysight\iqtools
        try
            user = getenv('username');
            tmpDir = fullfile('C:\Users', user, 'AppData', 'Local', 'Keysight');
            if (exist(tmpDir, 'dir') == 0)
                mkdir(tmpDir);
            end
            tmpDir = fullfile(tmpDir, 'iqtools');
            if (exist(tmpDir, 'dir') == 0)
                mkdir(tmpDir);
            end
            filename = fullfile(tmpDir, basename);
        catch
        end
    end
end
% save in global variable
arbConfigFilename = filename;
