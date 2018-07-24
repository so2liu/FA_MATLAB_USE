function varargout = iqcorrmgmt(varargin)
% IQTOOL MATLAB code for iqtool.fig
%      IQTOOL, by itself, creates a new IQTOOL or raises the existing
%      singleton*.
%
%      H = IQTOOL returns the handle to a new IQTOOL or the handle to
%      the existing singleton*.
%
%      IQTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQTOOL.M with the given input arguments.
%
%      IQTOOL('Property','Value',...) creates a new IQTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqcorrmgmt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqcorrmgmt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqtool

% Last Modified by GUIDE v2.5 10-May-2016 18:59:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqcorrmgmt_OpeningFcn, ...
                   'gui_OutputFcn',  @iqcorrmgmt_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before iqtool is made visible.
function iqcorrmgmt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqtool (see VARARGIN)

% Choose default command line output for iqtool
handles.output = hObject;

handles.posWindow = get(handles.iqtool, 'Position');
handles.posCplx = get(handles.uipanelCplx, 'Position');
handles.posSParam = get(handles.uipanelSParam, 'Position');
handles.posReadAWGCal = get(handles.pushbuttonReadAWGCal, 'Position');
handles.posMTCal = get(handles.pushbuttonMTCal, 'Position');
handles.posImportPerChannel = get(handles.pushbuttonImportPerChannel, 'Position');
handles.posExportPerChannel = get(handles.pushbuttonExportPerChannel, 'Position');
handles.posClearPerChannelCorr = get(handles.pushbuttonClearPerChannelCorr, 'Position');
handles.postextCutoff = get(handles.textCutoff, 'Position');
handles.poseditSParamCutoff = get(handles.editSParamCutoff, 'Position');
handles.postextSmooth = get(handles.textSmooth, 'Position');
handles.poseditSmooth = get(handles.editSmooth, 'Position');
handles.poscheckboxAbsMagnitude = get(handles.checkboxAbsMagnitude, 'Position');
handles.postextAbsMagnitude = get(handles.textAbsMagnitude, 'Position');
handles.poseditAbsMagnitude = get(handles.editAbsMagnitude, 'Position');
handles.postextDisplay = get(handles.textDisplay, 'Position');
handles.poscheckboxMagnitude = get(handles.checkboxMagnitude, 'Position');
handles.poscheckboxPhase = get(handles.checkboxPhase, 'Position');
handles.posaxes1 = get(handles.axes1, 'Position');
handles.posaxes2 = get(handles.axes2, 'Position');
% Update handles structure
guidata(hObject, handles);

% update GUI
popupmenuSParamNum_Callback([], [], handles);
try
    ampCorrFile = iqampCorrFilename();
    acs = load(ampCorrFile);
    if (isfield(acs, 'sparamRemoveSkew'))
        set(handles.checkboxRemoveSkew, 'Value', acs.sparamRemoveSkew);
    end
    if (isfield(acs, 'sparamWeight'))
        set(handles.editWeight, 'String', sprintf('%g', acs.sparamWeight));
    end
    if (isfield(acs, 'smoothing'))
        set(handles.editSmoothing, 'String', sprintf('%d', acs.smoothing));
    end
    if (isfield(acs, 'absMagnitude'))
        set(handles.editAbsMagnitude, 'String', sprintf('%g', acs.absMagnitude));
        set(handles.checkboxAbsMagnitude, 'Value', 1);
    else
        set(handles.checkboxAbsMagnitude, 'Value', 0);
    end
    checkboxAbsMagnitude_Callback([], [], handles);
catch
end
% UIWAIT makes iqtool wait for user response (see UIRESUME)
% uiwait(handles.iqtool);


% --- Outputs from this function are returned to the command line.
function varargout = iqcorrmgmt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonClose.
function pushbuttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


function editFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilename as text
%        str2double(get(hObject,'String')) returns contents of editFilename as a double


% --- Executes during object creation, after setting all properties.
function editFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonImportComplex.
function pushbuttonImportComplex_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonImportComplex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% process the following types of files:
%  .csv  VSA exported trace
%  .mat  VSA exported trace
%  .mat  M8195A Calibration file
%
[filename pathname] = uigetfile({ ...
    '*.mat', 'MATLAB file'; ...
    '*.csv', 'CSV file' });
if (filename ~= 0)
    hMsgbox = msgbox('Importing file...', 'Importing file...', 'replace');
    try
        [path, name, ext] = fileparts(filename);
        if (strcmp(ext, '.csv') || strcmp(ext, '.CSV'))
            % VSA equalizer trace file with header
            % expect to get values for XStart, XDelta and Y
            try
                f = fopen(strcat(pathname, filename), 'r');
                a = fgetl(f);
                cnt = 0;
                clear Y;
                XStart = 0;
                XDelta = 0;
                while (a ~= -1)
%                    fprintf('%s\n', a);
                    % process pairs
                    if (cnt > 0)
                        [val, readCnt] = sscanf(a, '%g,%g'); % US style
                        if (readCnt < 2)
                            [val, readCnt] = sscanf(regexprep(a, ',', '.'), '%g;%g'); % German style
                            if (readCnt < 2)
                                errordlg({'unexpected number format in CSV file: ' a});
                                return;
                            end
                        end
                        Y(cnt,1) = complex(val(1), val(2));
                        cnt = cnt + 1;
                    else
                        [tok, remain] = strtok(a, ',;');
                        switch (tok)
                            case 'Y'
                                cnt = 1;
                            case 'XDelta'
                                XDelta = sscanf(regexprep(remain(2:end), ',', '.'), '%g');
                            case 'XStart'
                                XStart = sscanf(regexprep(remain(2:end), ',', '.'), '%g');
                        end
                    end
                    a = fgetl(f);
                end
                fclose(f);
                numPts = cnt - 1;
                % frequency vector
                freq = linspace(XStart, XStart + (numPts - 1) * XDelta, numPts);
                % allow frequency shift
                result = inputdlg('Shift Frequency (use negative values to shift from RF to baseband)', 'Shift Frequency', 1, {'0'});
                if (~isempty(result))
                    freq = freq + eval(result{1});
                    updateAmpCorr(handles, freq, Y);
                end
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        else
            % process .MAT file - could be either VSA equalizer trace or
            % M8195A calibration file
            eq = load(strcat(pathname, filename));
            if (isfield(eq, 'Cal')) % M8195A Calibration file
                % ask user to select a channel
                result = inputdlg('Please select a channel', 'Please select a channel', 1, {'1'});
                if (~isempty(result))
                    ch = eval(result{1});
                    freq = 1e9 * eq.Cal.Frequency_MT;
                    amp = 10 .^ (eq.Cal.AmplitudeResponse_MT(:,ch) / 20);
                    filler = zeros(size(eq.Cal.AmplitudeResponse_MT, 1) - size(eq.Cal.AbsPhaseResponse_MT, 1), 1);
                    phi = [filler; eq.Cal.AbsPhaseResponse_MT(:,ch)] * pi / 180;
                    updateAmpCorr(handles, freq, amp .* exp(j * phi));
                end
            elseif (~isfield(eq, 'Y') || ~isfield(eq, 'XStart') || ~isfield(eq, 'XDelta')) % VSA trace file
                errordlg('Invalid correction file format. Expected variables "Y", "XStart" and "XDelta" in the file');
            else
                loadVSAcorr(handles, eq, @updateAmpCorr);
            end
        end
    catch ex
        errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
    end
    try
        close(hMsgbox);
    catch
    end
end


function loadVSAcorr(handles, eq, updateFct)
cancel = 0;
if (isfield(eq, 'InputCenter') && eq.InputCenter ~= 0)
    res = questdlg(sprintf('The equalizer data in this file is centered at %s Hz.\nDo you want to shift the data to baseband?', iqengprintf(eq.InputCenter)));
    switch (res)
        case 'Yes'; eq.XStart = eq.XStart - eq.InputCenter; eq.InputCenter = 0;
        case 'Cancel'; cancel = 1;
    end
end
% ask for frequency shift
%                 if (eq.InputCenter ~= 0)
%                     result = inputdlg('Shift Frequency (use negative values to shift from RF to baseband)', 'Shift Frequency', 1, {'0'});
%                     if (isempty(result))
%                         cancel = 1;
%                     else
%                         eq.XStart = eq.XStart + eval(result{1});
%                     end
%                 end
if (~cancel)
    % calculate frequency vector
    freq = linspace(eq.XStart, eq.XStart + (length(eq.Y) - 1) * eq.XDelta, length(eq.Y));
    % update ampCorr file
    updateFct(handles, freq, eq.Y);
end


function updateAmpCorr(handles, freq, Y)
% VSA seems to sometimes return multiple columns with the same value...
if (size(Y,1) > 1 && size(Y,2) > 1)
    Y = Y(:,1);
end
% calculate response in dB
Ydb = 20*log10(abs(Y));
% set up ampCorr structure
clear ampCorr;
ampCorr(:,1) = freq(1:end);
ampCorr(:,2) = -Ydb;
ampCorr(:,3) = 1 ./ Y;
% get the filename
ampCorrFile = iqampCorrFilename();
clear acs;
% try to load ampCorr file - be graceful if it does not exist
try
    acs = load(ampCorrFile);
catch
end
acs.ampCorr = ampCorr;
% and save
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);



function updatePerChannelCorr(handles, freq, Y)
% set up perChannelCorr structure
clear perChannelCorr;
perChannelCorr(:,1) = freq(1:end);
perChannelCorr(:,2:size(Y,2)+1) = 1 ./ Y;
% get the filename
ampCorrFile = iqampCorrFilename();
clear acs;
% try to load ampCorr file - be graceful if it does not exist
try
    acs = load(ampCorrFile);
catch
end
acs.perChannelCorr = perChannelCorr;
% and save
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);



% --- Executes on button press in pushbuttonExportComplex.
function pushbuttonExportComplex_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportComplex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    corrfilename = iqampCorrFilename();
catch
    errordlg('No correction file available yet');
    return;
end
try
    load(corrfilename);
    size(ampCorr,2);
catch
    errordlg('No complex corrections available');
    return;
end
[filename, pathname, filterindex] = uiputfile({...
    '.mat', 'MATLAB file (*.mat)'; ...
    '.csv', 'CSV file (*.csv)'}, ...
    'Save Frequency Response As...');
if (filename ~= 0)
    try
        if (size(ampCorr,2) <= 2)  % no complex correction available
            ampCorr(:,3) = 10.^(ampCorr(:,2)/20);
        end
        % store frequency response = inverse correction
        Y = 1 ./ ampCorr(:,3);
        switch (filterindex)
            case 1
                XStart = ampCorr(1,1);
                XDelta = ampCorr(2,1) - ampCorr(1,1);
                save(strcat(pathname, filename), 'XStart', 'XDelta', 'Y');
            case 2
                f = fopen(strcat(pathname, filename), 'w');
                fprintf(f, sprintf('XStart;%g\n', ampCorr(1,1)));
                fprintf(f, sprintf('XDelta;%g\n', ampCorr(2,1) - ampCorr(1,1)));
                fprintf(f, sprintf('Y\n'));
                for i=1:size(ampCorr,1)
                    fprintf(f, sprintf('%g;%g\n', real(Y(i)), imag(Y(i))));
                end
                fclose(f);
        end
    catch ex
        errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
    end
end


function updateAxes(handles)
acs = [];
try
    filename = iqampCorrFilename();
    set(handles.editFilename, 'String', filename);
    acs = load(filename);
catch
end
try
    if (isempty(acs)) % if ampCorr does not exist, create a dummy file
        acs.ampCorr = [1e6 0 1; 2e9 0 1];
    end
    if (isfield(acs, 'ampCorrMode'))
        ampCorrMode = acs.ampCorrMode;
    else
        ampCorrMode = -1;   % old style: de-embed
    end
    idx = [1 3 2];
    set(handles.popupmenuStdMode, 'Value', idx(ampCorrMode+2));
    % check if we use an S-Parameter file
    spNum = get(handles.popupmenuSParamNum, 'Value');
    if (isfield(acs, 'sparamFile') && (~iscell(acs.sparamFile) || iscell(acs.sparamFile) && spNum <= size(acs.sparamFile, 2)))
        if (iscell(acs.sparamFile))
            spFile = acs.sparamFile{spNum};
        else
            spFile = acs.sparamFile;    % old style - only one filename
        end
        if (~isempty(spFile))
            [~, name, ext] = fileparts(spFile);
            set(handles.editSParamFile, 'String', strcat(name, ext));
        else
            set(handles.editSParamFile, 'String', '');
        end
        if (isfield(acs, 'sparamMode'))
            sparamMode = acs.sparamMode;
        else
            sparamMode = -1;
        end
    else
        set(handles.editSParamFile, 'String', '');
        sparamMode = 0;
    end
    idx = [1 3 2];
    set(handles.popupmenuSParamMode, 'Value', idx(sparamMode + 2));
    if (isfield(acs, 'sparamCutoff'))
        cutoff = acs.sparamCutoff;
        set(handles.editSParamCutoff, 'String', iqengprintf(cutoff));
    else
        set(handles.editSParamCutoff, 'String', '');
    end
    
    [ampCorr, perChannelCorr] = iqcorrection([]);
    if (isempty(ampCorr))
        return;
    end
    phase = -1 * 180 / pi * unwrap(angle(ampCorr(:,3)));
    % if phase is *very* small, plot it as zero to avoid confusion...
    if (max(abs(phase)) < 1e-10)
        phase = zeros(size(phase,1), size(phase,2));
    end
    showMag = get(handles.checkboxMagnitude, 'Value');
    showPhase = get(handles.checkboxPhase, 'Value');
    %----- complex correction axes
    axes(handles.axes1);
    if (~showPhase)
        plot(ampCorr(:,1)/1e9, -1*ampCorr(:,2), 'LineWidth', 2);
        legend({'Magnitude'});
        ylabel('Loss (dB)');
    elseif (~showMag)
        plot(ampCorr(:,1)/1e9, phase, 'LineWidth', 2);
        legend({'Phase'});
        ylabel('Phase (degrees)');
    else
        func1 = @(x,y) plot(x,y,'Linewidth',2);
        [ax, ~, ~] = plotyy(ampCorr(:,1)/1e9, -1*ampCorr(:,2), ampCorr(:,1)/1e9, phase, func1);
        legend({'Magnitude', 'Phase'});
        xlabel('Frequency (GHz)');
        ylabel('Loss (dB)');
        axes(ax(2));
        ylabel('Phase (degrees)');
    end
    xlabel('Frequency (GHz)');
    title = get(gca(), 'Title');
    set(title, 'String', 'Complex Frequency/Phase Response');
    set(title, 'FontWeight', 'bold');
    grid on;
    %----- per channel axes
    axes(handles.axes2);
    if (isempty(perChannelCorr))
        perChannelCorr = [0 1; 1e9 1];
    end
    y1 = -20.*log10(abs(perChannelCorr(:,2:end)));
    y2 = -180 / pi * unwrap(angle(perChannelCorr(:,2:end)));
    if (~showPhase)
        plot(perChannelCorr(:,1)/1e9, y1, 'Linewidth', 2);
        switch (size(perChannelCorr,2))
            case 2; legend({'Magnitude'});
            case 3; legend({'Magn./I' 'Magn./Q'});
            case 4; legend({'Magn./I' 'Magn./Q' 'Magn./3rd'});
            case 5; legend({'Magn./I' 'Magn./Q' 'Magn./3rd' 'Magn./4th'});
        end
        ylabel('Loss (dB)');
    elseif (~showMag)
        plot(perChannelCorr(:,1)/1e9, y2, 'Linewidth', 2);
        switch (size(perChannelCorr,2))
            case 2; legend({'Phase'});
            case 3; legend({'Phase/I' 'Phase/Q'});
            case 4; legend({'Phase/I' 'Phase/Q' 'Phase/3rd'});
            case 5; legend({'Phase/I' 'Phase/Q' 'Phase/3rd' 'Phase/4th'});
        end
        ylabel('Phase (degrees)');
    else
        func1 = @(x,y) plot(x,y,'Linewidth',2);
        [ax, ~, ~] = plotyy(perChannelCorr(:,1)/1e9, y1, perChannelCorr(:,1)/1e9, y2, func1);
        switch (size(perChannelCorr,2))
            case 2; legend({'Magnitude' 'Phase'});
            case 3; legend({'Magn./I' 'Magn./Q' 'Phase/I' 'Phase/Q'});
            case 4; legend({'Magn./I' 'Magn./Q' 'Magn./3rd' 'Phase/I' 'Phase/Q' 'Phase/3rd'});
            case 5; legend({'Magn./I' 'Magn./Q' 'Magn./3rd' 'Magn./4th' 'Phase/I' 'Phase/Q' 'Phase/3rd' 'Phase/4th'});
        end
        xlabel('Frequency (GHz)');
        ylabel('Loss (dB)');
        axes(ax(2));
        ylabel('Phase (degrees)');
    end
    xlabel('Frequency (GHz)');
    title = get(gca(), 'Title');
    set(title, 'String', 'Per Channel Frequency/Phase Response');
    set(title, 'FontWeight', 'bold');
    grid on;
catch ex
    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
end



% --- Executes on button press in pushbuttonDisplaySum.
function pushbuttonDisplaySum_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplaySum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonDisplaySParam.
function pushbuttonDisplaySParam_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplaySParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuSParamMode.
function popupmenuSParamMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSParamMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSParamMode
val = get(handles.popupmenuSParamMode, 'Value');
idx = [-1 1 0];  % de-embed, embed, do nothing
ampCorrFile = iqampCorrFilename();
acs = load(ampCorrFile);
acs.sparamMode = idx(val);
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuSParamMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSParamFile_Callback(hObject, eventdata, handles)
% hObject    handle to editSParamFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSParamFile as text
%        str2double(get(hObject,'String')) returns contents of editSParamFile as a double
msgbox('Please use the "..." button to select a file');



% --- Executes during object creation, after setting all properties.
function editSParamFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSParamFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadSParamFile.
function pushbuttonLoadSParamFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadSParamFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ampCorrFile = iqampCorrFilename();
try
    acs = load(ampCorrFile);
catch
end
% change to the directory where the previous S-parameter file was located
spNum = get(handles.popupmenuSParamNum, 'Value');
if (exist('acs', 'var') && ...
      (isfield(acs, 'sparamFile') && (~iscell(acs.sparamFile) || ...
      iscell(acs.sparamFile) && spNum <= size(acs.sparamFile, 2))))
    if (iscell(acs.sparamFile))
        spFile = acs.sparamFile{spNum};
    else
        spFile = acs.sparamFile;
    end
    oldWD = cd();
    try
        [path file ext] = fileparts(spFile);
        cd(path);
    catch   % if the directory does not exist, simply ignore the error
    end
else
    oldWD = [];
end
% get the filename
[filename pathname] = uigetfile('*.s2p;*.s4p;*.s6p');
% and change dir back to where we were before
if (~isempty(oldWD))
    cd(oldWD);
end
if (filename ~= 0)
    try
        % check if the file can be read
        [rows, cols] = setupSelectedSParam(handles, strcat(pathname, filename));
        % select a default SParameter: S21, S31, S21 for 2/4/6 port file
        if (rows ~= 0)
            defVal = [1 1; 2 1; 2 1; 2 1; 2 1; 2 1];
            set(handles.popupmenuSParamSelect, 'Value', (defVal(rows,1)-1)*cols + defVal(rows,2));
            acs.selectedSParam(spNum, :) = [defVal(rows,1) defVal(rows,2)];
            acs.sparamFile{spNum} = strcat(pathname, filename);
            % if it was unused, set to de-embed to avoid confusion
            if (~isfield(acs, 'sparamMode') || acs.sparamMode == 0)
                acs.sparamMode = -1;
            end
            save(ampCorrFile, '-struct', 'acs');
        end
        updateAxes(handles);
    catch ex
        msgbox(ex.message);
    end
end



function [rows, cols] = setupSelectedSParam(handles, filename)
rows = 0;
cols = 0;
if (~isempty(filename))
    try
        sp = rfdata.data;
    catch
        errordlg('Can not create "rfdata" structure. Are you missing the "RF Toolbox" in your MATLAB installation?');
        return;
    end
    sp = read(sp, filename);
%    sp = reads4p(filename);
    if (~isempty(sp))
        rows = size(sp.S_Parameters, 1);
        cols = size(sp.S_Parameters, 2);
        pList = cell(rows*cols, 1);
        for i = 1:rows
            for j = 1:cols
                pList{(i-1)*cols+j} = sprintf('S%d%d', i, j);
            end
        end
        set(handles.popupmenuSParamSelect, 'Value', 1);
        set(handles.popupmenuSParamSelect, 'String', pList);
    end
end


% --- Executes on selection change in popupmenuStdMode.
function popupmenuStdMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuStdMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuStdMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuStdMode
val = get(handles.popupmenuStdMode, 'Value');
idx = [-1 1 0];  % de-embed, embed, do nothing
ampCorrFile = iqampCorrFilename();
acs = load(ampCorrFile);
acs.ampCorrMode = idx(val);
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuStdMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuStdMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editSParamCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to editSParamCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSParamCutoff as text
%        str2double(get(hObject,'String')) returns contents of editSParamCutoff as a double
ampCorrFile = iqampCorrFilename();
acs = load(ampCorrFile);
try
    acs.sparamCutoff = evalin('base', get(handles.editSParamCutoff, 'String'));
catch
    acs.sparamCutoff = 0;
end
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);

% --- Executes during object creation, after setting all properties.
function editSParamCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSParamCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenuSParamSelect.
function popupmenuSParamSelect_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSParamSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSParamSelect
vals = cellstr(get(handles.popupmenuSParamSelect, 'String'));
val = vals{get(handles.popupmenuSParamSelect, 'Value')};
spNum = get(handles.popupmenuSParamNum, 'Value');
sp = sscanf(val, 'S%d');
row = floor(sp/10);
col = sp - 10*row;
ampCorrFile = iqampCorrFilename();
acs = load(ampCorrFile);
acs.selectedSParam(spNum, 1:2) = [row col];
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);



% --- Executes during object creation, after setting all properties.
function popupmenuSParamSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonStoreAsStd.
function pushbuttonStoreAsStd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStoreAsStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
corr = iqcorrection([]);
% get the filename
ampCorrFile = iqampCorrFilename();
% and save
acs = load(ampCorrFile);
acs.ampCorr = corr;
acs.sparamMode = 0;     % don't double embed/deembed
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);


% --- Executes on button press in pushbuttonReadAWGCal.
function pushbuttonReadAWGCal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReadAWGCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
if (~isempty(arbConfig) && (~isempty(strfind(arbConfig.model, 'M8195A')) || ~isempty(strfind(arbConfig.model, 'M8196A'))))
    if (isfield(arbConfig, 'M8195Acorrection') && arbConfig.M8195Acorrection ~= 0)
        errordlg('Please turn off "M8195A/96A built-in corrections" in the configuration window if you want to use the corrections here. Otherwise you will apply the corrections twice');
        return;
    end
    chs = inputdlg({'Correction for "I" from channel: ', 'Correction for "Q" from channel: '}, ...
        'Calibration data set from which channels should be used?', 1, {'1', '3'});
    if (~isempty(chs))
        h = msgbox('Reading cal data from instrument. Please wait...', 'Please wait', 'replace');
        f = iqopen(arbConfig);
        if (~isempty(f))
            try
                clear cplxCorr;
                for i=1:2
                    a = query(f, sprintf('CHAR%d?', str2double(chs{i})));
                    v = sscanf(strrep(strrep(a, '"', ''), ',', ' '), '%g');
                    v = reshape(v, 3, length(v)/3)';
                    freq = v(:,1);
                    cplxCorr(:,i) = v(:,2) .* exp(j * v(:,3));
                end
                updatePerChannelCorr(handles, freq, cplxCorr);
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        end
        try close(h); catch; end;
    end
else
    errordlg({'Only the M8195A/96A supports built-in correction data'});
end


% --- Executes on button press in pushbuttonClearPerChannelCorr.
function pushbuttonClearPerChannelCorr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearPerChannelCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ampCorrFile = iqampCorrFilename();
clear acs;
% try to load ampCorr file - be graceful if it does not exist
try
    acs = load(ampCorrFile);
catch
end
acs.perChannelCorr = [];
acs = rmfield(acs, 'perChannelCorr');
% and save
save(ampCorrFile, '-struct', 'acs');
updateAxes(handles);


% --- Executes on button press in pushbuttonClearCplx.
function pushbuttonClearCplx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearCplx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Do you really want to delete the complex correction?', 'Delete complex correction', 'Yes', 'No', 'No');
if (strcmp(answer, 'Yes'))
    ampCorrFile = iqampCorrFilename();
    clear acs;
    % try to load ampCorr file - be graceful if it does not exist
    try
        acs = load(ampCorrFile);
    catch
    end
    acs.ampCorr = [];
    acs = rmfield(acs, 'ampCorr');
    % and save
    save(ampCorrFile, '-struct', 'acs');
    updateAxes(handles);
end


% --- Executes on button press in checkboxMagnitude.
function checkboxMagnitude_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMagnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((get(handles.checkboxMagnitude, 'Value') == 0) && ...
    (get(handles.checkboxPhase, 'Value') == 0))
  set(handles.checkboxMagnitude, 'Value', 1);
end
updateAxes(handles);


% --- Executes on button press in checkboxPhase.
function checkboxPhase_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((get(handles.checkboxMagnitude, 'Value') == 0) && ...
    (get(handles.checkboxPhase, 'Value') == 0))
  set(handles.checkboxMagnitude, 'Value', 1);
end
updateAxes(handles);


% --- Executes on button press in pushbuttonImportPerChannel.
function pushbuttonImportPerChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonImportPerChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, filterindex] = uigetfile({
    '*.s2p;*.s4p;*.s6p;*.s8p', 'Touchstone file'; ...
    '*.mat', 'MATLAB file'; ...
    '*.csv', 'CSV file'});
if (filename ~= 0)
    switch filterindex
        case 2 % *.mat
            try
                % process .MAT file - could be either VSA equalizer trace or M8195A calibration file
                eq = load(fullfile(pathname, filename));
                if (isfield(eq, 'Cal')) % M8195A Calibration file
                    % ask user to select a channel
                    switch (size(eq.Cal.AmplitudeResponse_MT, 2))
                        case 1; chs = {'1'};
                        case 2; chs = {'1' '2'};
                        otherwise
                            chs = inputdlg({'Correction for "I" from channel: ', 'Correction for "Q" from channel: '}, ...
                                'Calibration data set from which channels should be used?', 1, {'1', '3'});
                            if (isempty(chs))
                                return;
                            end
                    end
                    freq = 1e9 * eq.Cal.Frequency_MT;
                    amp = 10 .^ (eq.Cal.AmplitudeResponse_MT(:,str2double(chs)) / 20);
                    filler = zeros(size(eq.Cal.AmplitudeResponse_MT, 1) - size(eq.Cal.AbsPhaseResponse_MT, 1), length(chs));
                    phi = [filler; eq.Cal.AbsPhaseResponse_MT(:,str2double(chs))] * pi / 180;
                    updatePerChannelCorr(handles, freq, amp .* exp(1i * phi));
                elseif (~isfield(eq, 'Y') || ~isfield(eq, 'XStart') || ~isfield(eq, 'XDelta')) % VSA trace file
                    errordlg('Invalid correction file format. Expected variables "Y", "XStart" and "XStart" in the file');
                else
                    loadVSAcorr(handles, eq, @updatePerChannelCorr);
                end
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        case 3 % *.csv
            try
                val = csvread(fullfile(pathname, filename));
                switch (size(val,2))
                    case 3
                        freq = val(:,1);
                        corr = 10.^(val(:,2)./20) .* exp(1j * val(:,3)*pi/180);
                        updatePerChannelCorr(handles, freq, 1 ./ corr);
                    case 5
                        freq = val(:,1);
                        corr = [10.^(val(:,2)./20) .* exp(1j * val(:,3)*pi/180), ...
                                10.^(val(:,4)./20) .* exp(1j * val(:,5)*pi/180)];
                        updatePerChannelCorr(handles, freq, 1 ./ corr);
                    otherwise
                        errordlg('expected CSV with 3 or 5 columns');
                end
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        case 1 % S-parameter file
            try
                sp = rfdata.data;
            catch
                errordlg('Can not create "rfdata" structure. Are you missing the "RF Toolbox" in your MATLAB installation?');
                return;
            end
            try
                sp = read(sp, fullfile(pathname, filename));
                freq = sp.Freq;
                defaultVal = {'2 1'};
                if (size(sp.S_Parameters, 1) > 2)
                    defaultVal = {'2 1  4 3'};
                end
                result = [];
                while isempty(result)
                    result = inputdlg('Select S-parameter (e.g. "2 1" for S21)', 'Select S-parameter', 1, defaultVal);
                    if (isempty(result))
                        return;
                    end
                    result = sscanf(result{1}, '%d', inf);
                    if (~isvector(result) || length(result) < 2 || mod(length(result),2) ~= 0 || ...
                              min(result) < 1 || max(result) > size(sp.S_Parameters, 1) || ~isequal(floor(result), result))
                        h = errordlg('Please enter 2 or 4 numbers separated by spaces');
                        pause(1);
                        try close(h); catch; end;
                        result = '';
                    end
                end
                numCol = length(result) / 2;
                corr = zeros(size(freq,1), numCol);
                for i = 1:numCol
                    corr(:,i) = squeeze(sp.S_Parameters(result(2*i-1), result(2*i), :));
                end
                updatePerChannelCorr(handles, freq, corr);
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
    end % switch
end


% --- Executes on button press in pushbuttonMTCal.
function pushbuttonMTCal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMTCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqmtcal;


% --- Executes on selection change in popupmenuSParamNum.
function popupmenuSParamNum_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSParamNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSParamNum
% try to load ampCorr file - be graceful if it does not exist
ampCorrFile = iqampCorrFilename();
try
    acs = load(ampCorrFile);
    if (isfield(acs, 'sparamFile') && ischar(acs.sparamFile))
        acs.sparamFile = { acs.sparamFile };
        save(ampCorrFile, '-struct', 'acs');
    end
    spNum = get(handles.popupmenuSParamNum, 'Value');
    if (isfield(acs, 'sparamFile') && spNum <= size(acs.sparamFile, 2))
        [rows, cols] = setupSelectedSParam(handles, acs.sparamFile{spNum});
        if (rows ~= 0)
            sel = acs.selectedSParam(spNum, :);
            set(handles.popupmenuSParamSelect, 'Value', (sel(1)-1)*cols + sel(2));
        end
    end
catch
end
updateAxes(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuSParamNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSParamNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSParamClear.
function pushbuttonSParamClear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSParamClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ampCorrFile = iqampCorrFilename();
try
    set(handles.popupmenuSParamNum, 'Value', 1);
    acs = load(ampCorrFile);
    if (isfield(acs, 'sparamFile'))
        acs = rmfield(acs, 'sparamFile');
    end
    if (isfield(acs, 'sparamMode'))
        acs = rmfield(acs, 'sparamMode');
    end
    if (isfield(acs, 'selectedSParam'))
        acs = rmfield(acs, 'selectedSParam');
    end
    if (isfield(acs, 'sparamRemoveSkew'))
        acs = rmfield(acs, 'sparamRemoveSkew');
    end
    save(ampCorrFile, '-struct', 'acs');
catch
end
updateAxes(handles);


% --- Executes on button press in checkboxRemoveSkew.
function checkboxRemoveSkew_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRemoveSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject, 'Value');
try
    ampCorrFile = iqampCorrFilename();
    acs = load(ampCorrFile);
    acs.sparamRemoveSkew = val;
    save(ampCorrFile, '-struct', 'acs');
    updateAxes(handles);
catch ex
    errordlg(ex.message);
end


function editWeight_Callback(hObject, eventdata, handles)
% hObject    handle to editWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (~isempty(value) && isreal(value))
    set(hObject,'BackgroundColor','white');
    try
        ampCorrFile = iqampCorrFilename();
        acs = load(ampCorrFile);
        acs.sparamWeight = value;
        save(ampCorrFile, '-struct', 'acs');
        updateAxes(handles);
    catch ex
        errordlg(ex.message);
    end
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonExportPerChannel.
function pushbuttonExportPerChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportPerChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ampCorr, perChannelCorr] = iqcorrection([]);
if (isempty(perChannelCorr))
    errordlg('No per-channel correction available');
    return;
end
numChan = size(perChannelCorr, 2) - 1;
sp1 = sprintf('.s%dp', 2*numChan);
sp2 = sprintf('Touchstone %d-port file (*.s%dp)', 2*numChan, 2*numChan);
[filename, pathname, filterindex] = uiputfile({...
    sp1, sp2; ...
    '.mat', 'MATLAB file (*.mat)'; ...
    '.csv', 'CSV file (*.csv)'; ...
    '.csv', 'CSV (VSA style) (*.csv)'}, ...
    'Save Frequency Response As...');
if (filename ~= 0)
    switch filterindex
        case 2 % .mat
            try
                clear Cal;
                Cal.Frequency_MT = perChannelCorr(:,1) / 1e9;
                Cal.AmplitudeResponse_MT = -20 * log10(abs(perChannelCorr(:,2:end)));
                Cal.AbsPhaseResponse_MT = unwrap(angle(perChannelCorr(:,2:end))) * -180 / pi;
                save(fullfile(pathname, filename), 'Cal');
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        case 3 % .csv
            cal = zeros(size(perChannelCorr,1), 2*(size(perChannelCorr,2)-1)+1);
            cal(:,1) = perChannelCorr(:,1);
            for i = 1:numChan
               cal(:,2*i) = 20 * log10(abs(perChannelCorr(:,i+1)));
               cal(:,2*i+1) = unwrap(angle(perChannelCorr(:,i+1))) * 180 / pi;
            end
            csvwrite(fullfile(pathname, filename), cal);
        case 4 % .csv (VSA style)
            try
                ch = 1;
                if (size(perChannelCorr, 2) > 2)
                    list = {'Primary / I', 'Secondary / Q', '3rd', '4th'};
                    [ch,~] = listdlg('PromptString', 'Select Channel', 'SelectionMode', 'single', 'ListString', list(1:size(perChannelCorr,2)-1), 'ListSize', [100 60]);
                end
                if (~isempty(ch))
                    f = fopen(fullfile(pathname, filename), 'wt');
                    % if positive frequencies only, mirror to negative side
                    nPts = size(perChannelCorr, 1);
%                     if (min(perChannelCorr(:,1)) > 0)
%                         pf = polyfit((-nPts:nPts)', [flipud(-perChannelCorr(:,1)); 0; perChannelCorr(:,1)], 1);
%                         fprintf(f, sprintf('InputBlockSize, %d\n', 2*nPts+1));
%                         fprintf(f, sprintf('XStart, %g\n', polyval(pf, -nPts)));
%                         fprintf(f, sprintf('XDelta, %g\n', pf(1)));
%                         fprintf(f, sprintf('YUnit, lin\n'));
%                         fprintf(f, sprintf('Y\n'));
%                         for i = nPts:-1:1
%                             fprintf(f, sprintf('%g,%g\n', real(1/perChannelCorr(i,ch+1)), -imag(1/perChannelCorr(i,ch+1))));
%                             %fprintf(f, sprintf('%g,%g\n', abs(1/perChannelCorr(i,ch+1)), -angle(perChannelCorr(i,ch+1))));
%                             %fprintf(f, sprintf('%g,%g\n', -20*log10(abs(perChannelCorr(i,ch+1))), unwrap(angle(perChannelCorr(i,ch+1))) * -180 / pi));
%                         end
%                         fprintf(f, sprintf('%g,%g\n', real(1/perChannelCorr(1,ch+1)), 0));
%                         for i = 1:nPts
%                             fprintf(f, sprintf('%g,%g\n', real(1/perChannelCorr(i,ch+1)), imag(1/perChannelCorr(i,ch+1))));
%                             %fprintf(f, sprintf('%g,%g\n', abs(1/perChannelCorr(i,ch+1)), -angle(perChannelCorr(i,ch+1))));
%                             %fprintf(f, sprintf('%g,%g\n', -20*log10(abs(perChannelCorr(i,ch+1))), unwrap(angle(perChannelCorr(i,ch+1))) * -180 / pi));
%                         end
%                     else
                        pf = polyfit((0:nPts-1)', perChannelCorr(:,1), 1);
                        fprintf(f, sprintf('InputBlockSize, %d\n', nPts));
                        fprintf(f, sprintf('XStart, %g\n', pf(2)));
                        fprintf(f, sprintf('XDelta, %g\n', pf(1)));
                        fprintf(f, sprintf('YUnit, lin\n'));
                        fprintf(f, sprintf('Y\n'));
                        for i = 1:nPts
                            fprintf(f, sprintf('%g,%g\n', real(1/perChannelCorr(i,ch+1)), imag(1/perChannelCorr(i,ch+1))));
                            %fprintf(f, sprintf('%g,%g\n', abs(1/perChannelCorr(i,ch+1)), -angle(perChannelCorr(i,ch+1))));
                            %fprintf(f, sprintf('%g,%g\n', -20*log10(abs(perChannelCorr(i,ch+1))), unwrap(angle(perChannelCorr(i,ch+1))) * -180 / pi));
                        end
%                     end
                    fclose(f);
                end
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
        case 1 % .sNp
            try
                freq = perChannelCorr(:,1);
                sparam = zeros(2*numChan, 2*numChan, size(freq,1));
                for i = 1:numChan
                    tmp = 1./perChannelCorr(:,i+1);
                    sparam(2*i-1,2*i,:) = tmp;
                    sparam(2*i,2*i-1,:) = tmp;
                end
                sp = rfdata.data('Freq', freq, 'S_Parameters', sparam);
                sp.write(fullfile(pathname, filename));
            catch ex
                errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
            end
    end
end


% --- Executes when iqtool is resized.
function iqtool_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to iqtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    posWindow = get(handles.iqtool, 'Position');
    tmp = handles.uipanelCplx.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posCplx(1));
    handles.uipanelCplx.Position = tmp;
    tmp = handles.uipanelSParam.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posSParam(1));
    handles.uipanelSParam.Position = tmp;
    tmp = handles.pushbuttonReadAWGCal.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posReadAWGCal(1));
    handles.pushbuttonReadAWGCal.Position = tmp;
    tmp = handles.pushbuttonMTCal.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posMTCal(1));
    handles.pushbuttonMTCal.Position = tmp;
    tmp = handles.pushbuttonImportPerChannel.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posImportPerChannel(1));
    handles.pushbuttonImportPerChannel.Position = tmp;
    tmp = handles.pushbuttonExportPerChannel.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posExportPerChannel(1));
    handles.pushbuttonExportPerChannel.Position = tmp;
    tmp = handles.pushbuttonClearPerChannelCorr.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.posClearPerChannelCorr(1));
    handles.pushbuttonClearPerChannelCorr.Position = tmp;
    tmp = handles.textCutoff.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.postextCutoff(1));
    handles.textCutoff.Position = tmp;
    tmp = handles.editSParamCutoff.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poseditSParamCutoff(1));
    handles.editSParamCutoff.Position = tmp;

    tmp = handles.textSmooth.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.postextSmooth(1));
    handles.textSmooth.Position = tmp;
    tmp = handles.editSmooth.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poseditSmooth(1));
    handles.editSmooth.Position = tmp;

    tmp = handles.checkboxAbsMagnitude.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poscheckboxAbsMagnitude(1));
    handles.checkboxAbsMagnitude.Position = tmp;
    tmp = handles.textAbsMagnitude.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.postextAbsMagnitude(1));
    handles.textAbsMagnitude.Position = tmp;
    tmp = handles.editAbsMagnitude.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poseditAbsMagnitude(1));
    handles.editAbsMagnitude.Position = tmp;
    
    tmp = handles.textDisplay.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.postextDisplay(1));
    handles.textDisplay.Position = tmp;
    tmp = handles.checkboxMagnitude.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poscheckboxMagnitude(1));
    handles.checkboxMagnitude.Position = tmp;
    tmp = handles.checkboxPhase.Position;
    tmp(1) = posWindow(3) - (handles.posWindow(3) - handles.poscheckboxPhase(1));
    handles.checkboxPhase.Position = tmp;

    r = handles.posaxes1(2) / handles.posWindow(4);
    tmp = handles.axes1.Position;
    tmp(3) = posWindow(3) - (handles.posWindow(3) - handles.posaxes1(3));
    tmp(2) = 0.5 * posWindow(4) + 50;
    tmp(4) = 0.5 * posWindow(4) - 80;
    handles.axes1.Position = tmp;
    tmp = handles.axes2.Position;
    tmp(3) = posWindow(3) - (handles.posWindow(3) - handles.posaxes2(3));
    tmp(2) = 50;
    tmp(4) = 0.5 * posWindow(4) - 80;
    handles.axes2.Position = tmp;
catch; end;

function result = checkfields(hObject, eventdata, handles)
% This function verifies that all the fields have valid and consistent
% values. It is called from inside this script as well as from the
% iqconfig script when arbConfig changes (i.e. a different model or mode is
% selected). Returns 1 if all fields are OK, otherwise 0
result = 1;



function editSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to editSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (~isempty(value) && isreal(value) && value >= 0)
    set(hObject,'BackgroundColor','white');
    ampCorrFile = iqampCorrFilename();
    acs = load(ampCorrFile);
    acs.smoothing = value;
    save(ampCorrFile, '-struct', 'acs');
    updateAxes(handles);
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editSmooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editAbsMagnitude_Callback(hObject, eventdata, handles)
% hObject    handle to editAbsMagnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = [];
try
    value = evalin('base', ['[' get(handles.editAbsMagnitude, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (~isempty(value) && isreal(value) && isscalar(value))
    set(hObject,'BackgroundColor','white');
    try
        ampCorrFile = iqampCorrFilename();
        acs = load(ampCorrFile);
        acs.absMagnitude = value;
        if (~get(handles.checkboxAbsMagnitude, 'Value'))
            acs = rmfield(acs, 'absMagnitude');
        end
        save(ampCorrFile, '-struct', 'acs');
        updateAxes(handles);
    catch ex
        errordlg(ex.message);
    end
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editAbsMagnitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAbsMagnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAbsMagnitude.
function checkboxAbsMagnitude_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAbsMagnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.checkboxAbsMagnitude,'Value');
if (val)
    set(handles.textAbsMagnitude, 'Enable', 'on');
    set(handles.editAbsMagnitude, 'Enable', 'on');
%     try
%         value = evalin('base', ['[' get(handles.editAbsMagnitude, 'String') ']']);
%         if (value == 0)
%             minVal = 0;
%             [ampCorr, perChannelCorr] = iqcorrection([]);
%             if (~isempty(ampCorr))
%                 minVal = max(ampCorr(:,2));
%             end
%             if (~isempty(perChannelCorr))
%                 minVal = max(max(20*log10(abs(perChannelCorr(:, 2:end)))));
%             end
%             minVal = ceil(minVal * 10) / 10;
%             set(handles.editAbsMagnitude, 'String', sprintf('%.1f', minVal));
%         end
%     catch ex
%     end
else
    set(handles.textAbsMagnitude, 'Enable', 'off');
    set(handles.editAbsMagnitude, 'Enable', 'off');
end
editAbsMagnitude_Callback([], [], handles);
