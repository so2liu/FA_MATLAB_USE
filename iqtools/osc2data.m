
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v0.3
%   Call this function for test
%   
%   [fileData] = osc2data('fileName')
%   input parameter:    string file name (Optional)
%   output parameter:   fileCharData, SampleRate
%
%                       
%
%   Thanks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fileData, SampleRate] = Osc2data(fileName)
fileData = [];
SampleRate = [];

badfile = 0;      % bad file format check 

if (nargin == 0)        % check for file if function called without filename
    [filename, pathname] = uigetfile({'*.bin;*.h5;*.csv;*.tsv;*.txt'},'Select a Osc file');
    if filename ~= 0
        fileName = strcat(pathname, filename);
    else
        badfile = 1;
    end
end

if ~badfile
k = strfind(fileName,'.');  % check for extention
    if ~isempty(k)
    ext = fileName(k:end);
    x=[];
    y=[];
        switch ext
            case '.bin'     % call funtions for every file type saperatly
                [x,y] = binOsc(fileName);
            case '.h5'
                 [y] = double(h5Osc(fileName));
            case '.txt'
                 [y] = txtOsc(fileName);
            case '.tsv'
                 [x,y] = tsvOsc(fileName);
            case '.csv'
                [x,y] = csvOsc(fileName);
            otherwise
                errordlg('invalid file extrntion');    % show error if file extension invalid
        end
        
        if ~isempty(x) && ~isempty(y)   % check if empty
                sampleTime = x(2)-x(1);
                fileData = y;
                SampleRate = 1/sampleTime;
        elseif ~isempty(y)
                fileData = y;
        else
            error('no data in the file');   % show error if empty
        end
        
    else
    errordlg('no file extrntion found');    % show error if no file extension
    end
    
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% read txt file and output data from file
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [YData] = txtOsc(filename)
    M = csvread(filename);
    YData = M(:,1);
end

function [XData, YData] = tsvOsc(filename)
    M = csvread(filename);
    XData = M(:,1);
    YData = M(:,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% read csv file and output data from file
%% take care for the conditions when first row is titles(charecters) or data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XData, YData] = csvOsc(filename)
    try
        M = csvread(filename);      % data is also present in the first row
    catch
        M = csvread(filename,2);    % data begins from the second row
    end

    XData = M(:,1);
    YData = M(:,2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% read h5 file and output data from file
%% take care for the conditions if file contain more than one segments 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [YData] = h5Osc(filename)

YData = [];

h5infofile = h5info(filename);
for i=1:length(h5infofile.Groups)
    try
        groupname = h5infofile.Groups(i).Groups.Name;
    catch
        groupname = 'anythingsomething';
    end
    if strcmp(groupname(1:11),'/Waveforms/')                        %% search for waveform group
       if length(h5infofile.Groups(i).Groups.Datasets) > 1          %%  if more then one segments for wave forms
            for j = 1:length(h5infofile.Groups(i).Groups.Datasets)
                DatasetName = h5infofile.Groups(i).Groups.Datasets.Name;  %% all the wave forms are concatenated back to back
                tempdata = double(h5read(filename,strcat(groupname,'/',DatasetName(1:13),num2str(i),DatasetName(end-3:end))));
                YData =[YData,tempdata'];
            end
        else
            DatasetName = h5infofile.Groups(i).Groups.Datasets.Name;            
            YData = double(h5read(filename,strcat(groupname,'/',DatasetName))); %% Read waveform
       end
    end
end



end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% read bin file and output data from file
%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XData,YData] = binOsc(filename)
    fId = fopen(filename, 'r');

    if fId ~= -1
                    
% read file header
fileCookie = fread(fId, 2, 'char');%display(sprintf('FileCookie: %s',fileCookie));
fileVersion = fread(fId, 2, 'char');%display(sprintf('Fileversion: %s',fileVersion));
fileSize = fread(fId, 1, 'int32');%display(sprintf('FileSize: %d',fileSize));
nWaveforms = fread(fId, 1, 'int32');%display(sprintf('number of Waveforms: %d',nWaveforms));

% verify cookie
fileCookie = char(fileCookie');
if (~strcmp(fileCookie, 'AG'))
    fclose(fId);
    error('Unrecognized file format.');
end

for waveformIndex = 1:nWaveforms
    % read waveform header
    headerSize =        fread(fId, 1, 'int32'); bytesLeft = headerSize - 4;
    waveformType =      fread(fId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    nWaveformBuffers =  fread(fId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    nPoints =           fread(fId, 1, 'int32'); bytesLeft = bytesLeft - 4;
    count =             fread(fId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    xDisplayRange =     fread(fId, 1, 'float32');  bytesLeft = bytesLeft - 4;
    xDisplayOrigin =    fread(fId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xIncrement =        fread(fId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xOrigin =           fread(fId, 1, 'double');  bytesLeft = bytesLeft - 8;
    xUnits =            fread(fId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    yUnits =            fread(fId, 1, 'int32');  bytesLeft = bytesLeft - 4;
    dateString =        fread(fId, 16, 'char'); bytesLeft = bytesLeft - 16;
    timeString =        fread(fId, 16, 'char'); bytesLeft = bytesLeft - 16;
    frameString =       fread(fId, 24, 'char'); bytesLeft = bytesLeft - 24;
    waveformString =    fread(fId, 16, 'char'); bytesLeft = bytesLeft - 16;
    timeTag =           fread(fId, 1, 'double'); bytesLeft = bytesLeft - 8;
    segmentIndex =      fread(fId, 1, 'uint32'); bytesLeft = bytesLeft - 4;

    % skip over any remaining data in the header
    fseek(fId, bytesLeft, 'cof');

    % generate time vector from xIncrement and xOrigin values
        timeVector = (xIncrement * [0:(nPoints-1)]') + xOrigin;
        Data(:,1) = timeVector;
   for bufferIndex = 1:nWaveformBuffers
        % read waveform buffer header
        headerSize = fread(fId, 1, 'int32'); bytesLeft = headerSize - 4;
        bufferType = fread(fId, 1, 'int16'); bytesLeft = bytesLeft - 2;
        bytesPerPoint = fread(fId, 1, 'int16'); bytesLeft = bytesLeft - 2;
        bufferSize = fread(fId, 1, 'int32'); bytesLeft = bytesLeft - 4;

        % skip over any remaining data in the header
        fseek(fId, bytesLeft, 'cof');
        
           if ((bufferType == 1) || (bufferType == 2) || (bufferType == 3))
                % bufferType is PB_DATA_NORMAL, PB_DATA_MIN, or PB_DATA_MAX (float)
                voltageVector(:, bufferIndex) = fread(fId, nPoints, 'float');
            elseif (bufferType == 4)
                % bufferType is PB_DATA_COUNTS (int32)
                voltageVector(:, bufferIndex) = fread(fId, nPoints, '*int32');
            elseif (bufferType == 5)
                % bufferType is PB_DATA_LOGIC (int8)
                voltageVector(:, bufferIndex) = fread(fId, nPoints, '*uint8');
           else
                % unrecognized bufferType read as unformated bytes
                voltageVector(:, bufferIndex) = fread(fId, bufferSize, '*uint8');
           end    
   end
       Data(:,waveformIndex+1) = voltageVector;
end
        XData = Data(:,1);
        YData = Data(:,2);

                    
    fclose(fId);
    else
        errordlg('no file found');
    end
end