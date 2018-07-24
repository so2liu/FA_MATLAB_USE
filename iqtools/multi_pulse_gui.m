function varargout = multi_pulse_gui(varargin)
% MULTI_PULSE_GUI MATLAB code for multi_pulse_gui.fig
%      MULTI_PULSE_GUI, by itself, creates a new MULTI_PULSE_GUI or raises the existing
%      singleton*.
%
%      H = MULTI_PULSE_GUI returns the handle to a new MULTI_PULSE_GUI or the handle to
%      the existing singleton*.
%
%      MULTI_PULSE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTI_PULSE_GUI.M with the given input arguments.
%
%      MULTI_PULSE_GUI('Property','Value',...) creates a new MULTI_PULSE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multi_pulse_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to multi_pulse_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multi_pulse_gui

% Last Modified by GUIDE v2.5 05-Aug-2015 22:08:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multi_pulse_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @multi_pulse_gui_OutputFcn, ...
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


% --- Executes just before multi_pulse_gui is made visible.
function multi_pulse_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multi_pulse_gui (see VARARGIN)

% Choose default command line output for multi_pulse_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes multi_pulse_gui wait for user response (see UIRESUME)
% uiwait(handles.iqtool);
menuAntennaScanExample_Callback([], [], handles);
%menuBasicExample_Callback([], [], handles);


% --- Outputs from this function are returned to the command line.
function varargout = multi_pulse_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonInsert.
function pushbuttonInsert_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInsert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
default = {'0', '60e-6', '5e-6', '200e-9', '500e6', '10e6', '0', 'None', '', '', '', ''};
insertRow(handles, default);


function insertRow(handles, default)
global currentTableSelection;
data = get(handles.uitable1, 'Data');
if (exist('currentTableSelection', 'var') && length(currentTableSelection) >= 2)
    row1 = currentTableSelection(1);
else
    row1 = 1;
end
set(handles.textEmpty, 'Visible', 'off');
row2 = size(data,1);
if (row1 > row2)
    row1 = row2;
end
% it seems that an assignment like this is not possible
% data{row1+1:row2+1,:} = data{row1:row2,:}
if (row2 < 1)    % empty
    for j=1:size(default,2)
        data{1,j} = default{j};
    end
else
    for i=row2:-1:row1
        for j=1:size(data,2)
            data{i+1,j} = data{i,j};
        end
    end
    if (~isempty(default))
        for j=1:size(default,2)
            data{row1,j} = default{j};
        end
    end
end
set(handles.uitable1, 'Data', data);


% --- Executes on button press in pushbuttonDelete.
function pushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global currentTableSelection;
data = get(handles.uitable1, 'Data');
if (exist('currentTableSelection', 'var') && length(currentTableSelection) >= 2)
    row1 = currentTableSelection(1);
else
    row1 = 1;
end
row2 = size(data,1);
if (row2 <= 0)
    return;
end
if (row2 == 1)
    set(handles.textEmpty, 'Visible', 'on');
end
if (row1 > row2)
    row1 = row2;
end
newdata = cell(row2-1,size(data,2));
% it seems that an assignment like this is not possible
% data{row1+1:row2+1,:} = data{row1:row2,:}
for i=1:row1-1
    for j=1:size(data,2)
        newdata{i,j} = data{i,j};
    end
end
for i=row1:row2-1
    for j=1:size(data,2)
        newdata{i,j} = data{i+1,j};
    end
end
set(handles.uitable1, 'Data', newdata);


% --- Executes on button press in pushbuttonDisplay.
function pushbuttonDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMsgBox = msgbox('Calculating waveform. Please wait...', 'Please wait...', 'replace');
calculatePulses(handles, 0);
try
    close(hMsgBox);
catch e;
end;

% --- Executes on button press in pushbuttonDownload.
function pushbuttonDownload_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDownload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMsgBox = msgbox('Downloading waveform. Please wait...', 'Please wait...', 'replace');
fc = evalin('base', get(handles.editCenterFrequency, 'String'));
calculatePulses(handles, 1);
try
    close(hMsgBox);
catch e;
end;


function calculatePulses(handles, doDownload)
pulseTable = checkPulseTable(handles);
fc = evalin('base', get(handles.editCenterFrequency, 'String'));
amplCutoff = evalin('base', get(handles.editAmplCutoff, 'String'));
correction = get(handles.checkboxCorrection, 'Value');
showDropped = get(handles.checkboxShowDropped, 'Value');
try
    multi_pulse('pulseTable', pulseTable, 'fc', fc, 'correction', correction, ...
    'download', doDownload, 'amplCutoff', amplCutoff, 'showDropped', showDropped);
catch ex;
    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
end



% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
checkPulseTable(handles);


function pulseTable = checkPulseTable(handles)
try
    data = get(handles.uitable1, 'Data');
    pulseTable = cell2struct(data, ...
    {'delay', 'pri', 'pw', 'tt', 'offset', 'span', 'ampl', ...
    'scanType', 'scanPeriod', 'scanFct', 'scanAz', 'scanSq'}, 2);
for i=1:length(pulseTable)
    switch (pulseTable(i).scanType)
        case {'Conical' 'Circular'}
            if (isempty(pulseTable(i).scanFct) || strcmp(pulseTable(i).scanFct, ''))
                data{i,10} = '(sin(x)./x).^3';
            end
            if (isempty(pulseTable(i).scanPeriod) || strcmp(pulseTable(i).scanPeriod, ''))
                data{i,9} = '3';
            end
            if (isempty(pulseTable(i).scanAz) || strcmp(pulseTable(i).scanAz, ''))
                data{i,11} = '4';
            end
            if (strcmp(pulseTable(i).scanType, 'Conical') &&  ...
                 (isempty(pulseTable(i).scanSq) || strcmp(pulseTable(i).scanSq, '')))
                data{i,12} = '4';
            end
            set(handles.uitable1, 'Data', data);
    end
    pulseTable(i).delay  = evalin('base', ['[' pulseTable(i).delay ']']);
    pulseTable(i).pri    = evalin('base', ['[' pulseTable(i).pri ']']);
    pulseTable(i).pw     = evalin('base', ['[' pulseTable(i).pw ']']);
    pulseTable(i).tt     = evalin('base', ['[' pulseTable(i).tt ']']);
    pulseTable(i).offset = evalin('base', ['[' pulseTable(i).offset ']']);
    pulseTable(i).span   = evalin('base', ['[' pulseTable(i).span ']']);
    pulseTable(i).ampl   = evalin('base', ['[' pulseTable(i).ampl ']']);
    pulseTable(i).scanPeriod = evalin('base', ['[' pulseTable(i).scanPeriod ']']);
    pulseTable(i).scanAz = evalin('base', ['[' pulseTable(i).scanAz ']']);
    pulseTable(i).scanSq = evalin('base', ['[' pulseTable(i).scanSq ']']);
    numPulse(i) = max([length(pulseTable(i).delay) ...
                       length(pulseTable(i).pri) ...
                       length(pulseTable(i).pw) ...
                       length(pulseTable(i).tt) ...
                       length(pulseTable(i).span) ...
                       length(pulseTable(i).offset) ...
                       length(pulseTable(i).ampl)]);
    % extend all the other parameter vectors to match the number of pulses
    pulseTable(i).pri    = fixlength(pulseTable(i).pri, numPulse(i));
    pulseTable(i).pw     = fixlength(pulseTable(i).pw, numPulse(i));
    pulseTable(i).tt     = fixlength(pulseTable(i).tt, numPulse(i));
    pulseTable(i).span   = fixlength(pulseTable(i).span, numPulse(i));
    pulseTable(i).offset = fixlength(pulseTable(i).offset, numPulse(i));
    pulseTable(i).ampl   = fixlength(pulseTable(i).ampl, numPulse(i));
    if (sum(pulseTable(i).delay + pulseTable(i).pw + 2*pulseTable(i).tt) > pulseTable(i).pri)
        errordlg(sprintf('Line %d: Delay + Pulse Width + 2 * Rise/Fall Time > PRI', i));
    end
end
try
    close(hMsgBox);
catch e;
end;
catch e;
    msgbox(e.message, 'Error', 'replace');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global currentTableSelection;
if (~isempty(eventdata.Indices))
    currentTableSelection = eventdata.Indices;
end



function editCenterFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editCenterFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCenterFrequency as text
%        str2double(get(hObject,'String')) returns contents of editCenterFrequency as a double


% --- Executes during object creation, after setting all properties.
function editCenterFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCenterFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function x = fixlength(x, len)
% make a vector with <len> elements by duplicating or cutting <x> as
% necessary
x = reshape(x, 1, length(x));
x = repmat(x, 1, ceil(len / length(x)));
x = x(1:len);


% --- Executes on button press in checkboxCorrection.
function checkboxCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCorrection


% --------------------------------------------------------------------
function menuAntennaScanExample_Callback(hObject, eventdata, handles)
% hObject    handle to menuAntennaScanExample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global currentTableSelection;
currentTableSelection = [];
arbConfig = loadArbConfig();
if (~isempty(strfind(arbConfig.model, 'DUC')))
    set(handles.uitable1, 'Data', []);
    default = {'60e-6', '750e-6', '2.7e-6', '270e-9', '[-5 -33 6 25 36]*1e6', '0', '-8', 'Circular', '5.76/2', '(sin(x)./x).^3', '4', ''};
    insertRow(handles, default);
    default = {'40e-6', '1080e-6', '13e-6', '1300e-9', '-2e6', '50e6', '-10', 'Circular', '4.32', '(sin(x)./x).^3', '6', ''};
    insertRow(handles, default);
    default = {'30e-6', '335.768e-6 335.768e-6 379.724e-6 379.724e-6 344.784e-6 344.784e-6 379.724e-6 379.724e-6', ...
        '1.5e-6', '150e-9', '-17e6', '10e6', '0', 'Circular', '8.64', '(sin(x)./x).^3', '4', ''};
    insertRow(handles, default);
    default = {'15e-6', '100e-6', '8e-6', '800e-9', '33e6', '0', '-5', 'Conical', '0.18', '(sin(x)./x).^3', '2', '4'};
    insertRow(handles, default);
    default = {'0', '100e-6', '5e-6', '500e-9', '-37e6', '0', '0', 'Circular', '2.16', '(sin(x)./x).^3', '2', ''};
    insertRow(handles, default);
else
    set(handles.uitable1, 'Data', []);
    default = {'60e-6', '750e-6', '2.7e-6', '270e-9', '1e6', '0', '-8', 'Circular', '2.88', '(sin(x)./x).^3', '20', ''};
    insertRow(handles, default);
    default = {'40e-6', '1080e-6', '13e-6', '1300e-9', '-2e6', '50e6', '0', 'Circular', '4.32', '(sin(x)./x).^3', '5', ''};
    insertRow(handles, default);
    default = {'30e-6', '335e-6', '1.5e-6', '150e-9', '-17e6', '10e6', '0', 'Circular', '8.64', '(sin(x)./x).^3', '20', ''};
    insertRow(handles, default);
    default = {'15e-6', '200e-6', '8e-6', '800e-9', '33e6', '0', '-5', 'Conical', '0.36', '(sin(x)./x).^3', '2', '4'};
    insertRow(handles, default);
    %default = {'0', '100e-6', '5e-6', '500e-9', '-37e6', '0', '-3', 'Circular', '2.16', '(sin(x)./x).^3', '10', ''};
    %insertRow(handles, default);
    set(handles.editAmplCutoff, 'String', '-30');
end


% --------------------------------------------------------------------
function menuSimpleAntennaScan_Callback(hObject, eventdata, handles)
% hObject    handle to menuSimpleAntennaScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global currentTableSelection;
currentTableSelection = [];
set(handles.uitable1, 'Data', []);
default = {'0', '100e-6', '5e-6', '50e-9', '0', '0', '0', 'Circular', '3', '(sin(x)./x).^3', '4', ''};
insertRow(handles, default);


% --------------------------------------------------------------------
function menuBasicExample_Callback(hObject, eventdata, handles)
% hObject    handle to menuBasicExample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global currentTableSelection;
currentTableSelection = [];
arbConfig = loadArbConfig();
if (~isempty(strfind(arbConfig.model, 'DUC')))
    set(handles.uitable1, 'Data', []);
    default = {'0', '60e-6', '5e-6', '20e-9', '50e6', '50e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'0', '10e-6', '1e-6', '100e-9', '-30e6', '10e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'8e-6', '40e-6', '10e-6', '100e-9', '-10e6', '1e6', '-5', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'20e-6', '30e-6', '2e-6', '200e-9', '-60e6', '20e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
else
    set(handles.uitable1, 'Data', []);
    default = {'0', '6e-6', '0.5e-6', '2e-9', '50e6', '50e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'0', '1e-6', '0.1e-6', '10e-9', '-30e6', '10e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'0.8e-6', '4e-6', '1e-6', '10e-9', '-10e6', '1e6', '-5', 'None', '', '', '', ''};
    insertRow(handles, default);
    default = {'2e-6', '3e-6', '0.2e-6', '20e-9', '-60e6', '20e6', '0', 'None', '', '', '', ''};
    insertRow(handles, default);
end


% --------------------------------------------------------------------
function menuLoadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqloadsettings(handles);


% --------------------------------------------------------------------
function menuSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqsavesettings(handles);



function editAmplCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmplCutoff as text
%        str2double(get(hObject,'String')) returns contents of editAmplCutoff as a double


% --- Executes during object creation, after setting all properties.
function editAmplCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowDropped.
function checkboxShowDropped_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowDropped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowDropped


function result = checkfields(hObject, eventdata, handles)
% This function verifies that all the fields have valid and consistent
% values. It is called from inside this script as well as from the
% iqconfig script when arbConfig changes (i.e. a different model or mode is
% selected). Returns 1 if all fields are OK, otherwise 0
result = 1;


% --- Executes when iqtool is resized.
function iqtool_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to iqtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    posWindow = get(hObject, 'Position');
    posTable = get(handles.uitable1, 'Position');
    posTable(4) = posWindow(4) - 95;
    set(handles.uitable1, 'Position', posTable);
catch 
end
