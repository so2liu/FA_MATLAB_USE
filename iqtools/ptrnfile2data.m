%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   v0.5
%   Read PTRN/TXT file and return binary data
%
%   [fileCharData] = ptrnfile2data('fileName')
%   input parameter:    string file name (Optional)
%   output parameter:   bits in the file
%
%   Author: Muhammad Butt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fileCharData] = ptrnfile2data(fileName)

Formatting = {'Version='        ...     % Parameters used in PTRN format
    'Format='         ...
    'Description='    ...
    'Count='          ...
    'Length='         ...
    'Data='           ...
    };
checkFormattingDATA = cell(6,1);        % to store parameter values

expn = 0;
badfile = 0;      % bad file format check
txtfile = 0;
%fileName = 'CEIstress.ptrn';    %
%fileName = 'CRPAT.ptrn';
if (nargin == 0)
    [filename, pathname] = uigetfile({'*.ptrn;*.txt'},'Select a *.ptrn file');
    if filename ~= 0
        fileName = strcat(pathname, filename);
    else
        badfile = 1;
    end
end

k = strfind(fileName,'.');
if isempty(k)
    errordlg('No file extension found',...
        'Error Message PTRNfile');
    badfile = 1;
end
ext = fileName(k:end);

if ~badfile
    if strcmp(ext,'.txt')
        txtfile = 1;
    end
    fid = fopen(fileName, 'r');             % open to read file
    if fid == -1
        errordlg(sprintf('Can''t open %s', fileName),...
            'Error Message PTRNfile');
        badfile = 1;
    end
    dis = sprintf('File name is %s\n',fileName);
    %    disp(dis);
    
    if ~badfile
        if ~txtfile
            for i=1:6       % this loop will test all the parameters and compare
                stringCheck=[]; %
                counter = 0;    % bad file formate check
                while true
                    readchar = fread(fid, 1)';                  % read one byte from file
                    
                    if  (readchar == 10  || readchar == 13)        % find newline as its a part of the format
                        if length(stringCheck) < 1
                            expn = 1;        % its an exception when newline is enter key
                        else
                            break;
                        end
                    end
                    stringCheck=strcat(stringCheck,readchar);   % make string with single characters
                    counter = counter +1;
                    if counter > 257                % check if don't find '=' for longer time
                        errordlg('Bad File Format',...
                            'Error Message PTRNfile');
                        % that means there is some problem with the file format
                        badfile = 1;                        % 257 is just an arbitrarily value.
                        break;                              % "Description parameter" may contain more characters.
                    end
                    
                end
                
                if badfile      % if file format is bad just break for loop
                    break
                end
                
                lengF = length(Formatting{i});   % length of each format string
                if strcmp(stringCheck(1:lengF),Formatting{i})    % compare if we aligned with the format
                    checkFormattingDATA{i} = stringCheck(lengF+1:end);
                else
                    dis = sprintf('..ERROR..Bad file format\n');
                    errordlg('Bad File Format',...
                        'Error Message PTRNfile');
                    badfile = 1;
                end
                
            end     %%%%%%%% End of for loop which test all the parameters
            
        end
    end
    
    if ~badfile         % don't go further if there is some error in format
        
        dataChar = fread(fid, inf)';        % read rest of the data from the file
        fclose(fid);                        % close the file
        
        if ~txtfile
            
            if checkFormattingDATA{4} == '2'        % if count parameter is 2
                if expn
                    adjs = 2;
                else
                    adjs = 1;
                end
                k = strfind(dataChar,Formatting{6});  % then we have duplicate data in file
                dataChar=dataChar(1:k-adjs);
            end
            checkFormattingDATA{i} = dataChar;    % take it for further purpose if needed
            
            switch char(checkFormattingDATA(2))
                case 'Bin'
                    byteCurrection = mod(str2double(checkFormattingDATA{5}),8);
                    if byteCurrection ~= 0
                        byteCurrection = 8 - byteCurrection;
                    end
                    
                    if checkFormattingDATA{5} == num2str( (length(dataChar)*8) - byteCurrection)
                        % just check if the length of
                        % data read from file is
                    else           % equal as stated in the file parameter
                        errordlg(dis, 'Error Message PTRNfile');
                    end
                    
                    fileCharData = [];              % this will convert all the characters and place
                    dtemp = dec2bin(dataChar,8)';
                    fileCharData=dtemp(:)'-'0';
                    fileCharData = fileCharData(1:end-byteCurrection);
                    %%%%%%%%%% end of case 'Bin'
                    
                case 'Dual'
                    if checkFormattingDATA{5} == num2str(length(dataChar))
                    else
                        errordlg(dis, 'Error Message PTRNfile');
                    end
                    fileCharData = [];              % this will convert all the characters and place
                    for j=1:length(dataChar)        % in a variable 'data' as bit pattren
                        switch dataChar(j)
                            case '1'
                                fileCharData = [fileCharData,1];
                            case '0'
                                fileCharData = [fileCharData,0];
                            otherwise
                                dis = sprintf('Error in file');
                                errordlg(dis, 'Error Message PTRNfile');
                        end
                    end
                    %%%%% end of case 'Dual'
                    
                case {'Hex','Text'}
                    tempData = dataChar;     % remove white spaces
                    dataChar = [];
                    for i=1:length(tempData)
                        if tempData(i) == ' ' || tempData(i) == 10 || tempData(i) == 13
                        else
                            dataChar = [dataChar,tempData(i)];
                        end
                    end
                    
                    byteCurrection = mod(str2double(checkFormattingDATA{5}),4);
                    if byteCurrection ~= 0
                        byteCurrection = 4 - byteCurrection;
                    end
                    if checkFormattingDATA{5} == num2str( (length(dataChar)*4) - byteCurrection)
                    else
                        errordlg(dis, 'Error Message PTRNfile');
                    end
                    fileCharData = [];                                  % this will convert all the characters and place
                    fileCharData = hexToBinaryVector(char(dataChar));   % every bit in separately
                    fileCharData = fileCharData(1:end-byteCurrection);  %
                    %%%%% end of case 'Hex','Text'
                    
                case 'Symbol'
                otherwise
                    errordlg('other format', 'Error Message PTRNfile');
                    %%%%%%%%%%%%%  for other formats
            end
            %%%%% end of Switch statement for different formates
            
        else        %%% for txt file 0s and 1s with white space separation
            fileCharData = [];
            i=1;
            sp = 0;
            counterSample = 1;
            while i<length(dataChar)+1      %%% test every byte and take decision accordingly
                if dataChar(i) == ' ' || dataChar(i) == 10 || dataChar(i) == 13
                    i = i + 1;
                    sp = 0;
                elseif dataChar(i) == '1'
                    i = i + 1;
                    sp = sp + 1;
                    counterSample = counterSample + 1;
                    fileCharData = [fileCharData,1];
                elseif dataChar(i) == '0'
                    i = i + 1;
                    sp = sp + 1;
                    counterSample = counterSample + 1;
                    fileCharData = [fileCharData,0];
                else        %%% if unexpected character is detected somewhere in file
                    errordlg(sprintf('Sample %d in file %s is invalid',counterSample, fileName),...
                        'Error Message PTRNfile');
                    fileCharData = [];
                    break;
                end
                if sp > 1   %%% if characters are OK (0s and 1s) but they are not separated with white space somewhere in file
                    errordlg(sprintf('Sample %d in file %s is invalid',counterSample-1, fileName),...
                        'Error Message PTRNfile');
                    fileCharData = [];
                    break;
                end
            end
        end     %%% end of txt file
        
        
        %%%%% if bad formate detected
    else            % if any bad file format error occur then come here
        fileCharData = [];
        if fid ~= -1
            fclose(fid);
        end
    end
else                % if no file selected
    fileCharData = [];
end


fclose('all');


end
