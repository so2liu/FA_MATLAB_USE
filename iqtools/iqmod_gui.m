function varargout = iqmod_gui(varargin)
% IQMOD_GUI M-file for iqmod_gui.fig
%      IQMOD_GUI, by itself, creates a new IQMOD_GUI or raises the existing
%      singleton*.
%
%      H = IQMOD_GUI returns the handle to a new IQMOD_GUI or the handle to
%      the existing singleton*.
%
%      IQMOD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQMOD_GUI.M with the given input arguments.
%
%      IQMOD_GUI('Property','Value',...) creates a new IQMOD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqmod_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqmod_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqmod_gui

% Last Modified by GUIDE v2.5 16-Nov-2015 23:11:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqmod_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @iqmod_gui_OutputFcn, ...
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


% --- Executes just before iqmod_gui is made visible.
function iqmod_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqmod_gui (see VARARGIN)

% Choose default command line output for iqmod_gui
handles.output = hObject;
handles.os_resolution = 0.001;
% Update handles structure
guidata(hObject, handles);

arbConfig = loadArbConfig();
switch arbConfig.model
    case {'M8190A_14bit'}
        oversampling = 8;
        offset = 2e9;
    case 'M8190A_12bit'
        oversampling = 12;
        offset = 2e9;
    case {'M8195A_Rev0', 'M8195A_Rev1'}
        set(handles.editNumSymbols, 'String', '4000');
        oversampling = 4;
        offset = 0;
    case 'AWG7xxxx'
        offset = 5e9;
        oversampling = 10;
    otherwise
        oversampling = 4;
        offset = 0;
end
set(handles.editFilename, 'Position', get(handles.editData, 'Position'));
set(handles.editSampleRate, 'String', iqengprintf(arbConfig.defaultSampleRate));
set(handles.popupmenuModType, 'Value', 8);  % QAM16
set(handles.editOversampling, 'String', num2str(oversampling));
set(handles.editSymbolRate, 'String', iqengprintf(arbConfig.defaultSampleRate / oversampling));
if (isfield(arbConfig, 'defaultFc') && arbConfig.defaultFc ~= 0)
    set(handles.editCarrierOffset, 'String', iqengprintf(0));
    set(handles.editFc, 'String', iqengprintf(arbConfig.defaultFc));
elseif (~isempty(strfind(arbConfig.model, 'DUC')) && ...
    isfield(arbConfig, 'carrierFrequency'))
    set(handles.editCarrierOffset, 'String', iqengprintf(0));
    set(handles.editFc, 'String', iqengprintf(arbConfig.carrierFrequency));
else
    set(handles.editCarrierOffset, 'String', iqengprintf(offset));
    set(handles.editFc, 'String', iqengprintf(offset));
end
% update all the fields
checkfields([], 0, handles);

if (~isfield(arbConfig, 'tooltips') || arbConfig.tooltips == 1)
set(handles.editSampleRate, 'TooltipString', sprintf([ ...
    'This field defines the AWG sample rate in Hertz. By default, it will be\n' ...
    'set automatically, but the value can be overwritten if a specific sample\n' ...
    'rate is desired']));
set(handles.editOversampling, 'TooltipString', sprintf([ ...
    'This field defines the ratio of sampling rate vs. symbol rate.\n' ...
    'Integer and fractional values are supported. Normally it is not necessary\n' ...
    'to set this field since it will be automatically calculated based on\n' ...
    'sampling rate and symbol rate.']));
set(handles.editSymbolRate, 'TooltipString', sprintf([ ...
    'This field defines the symbol rate (= toggle rate) of the modulated signal.\n']));
set(handles.editNumSymbols, 'TooltipString', sprintf([ ...
    'The utility will generate the given number of random symbols.\n' ...
    'A larger number will give a more realistic spectral shape but\n' ...
    'will also increase computation time. Especially when using large\n' ...
    'oversampling factors (> 20), start with a small number of symbols\n' ...
    '(e.g. 20) to keep the computation time within reasonable limits.\n' ...
    'Then gradually increase the number. Computation time can be reduced\n' ...
    'by using a number that is a multiple of the AWG''s segment granularity.']));
set(handles.popupmenuModType, 'TooltipString', sprintf([ ...
    'Select the modulation scheme for the digital modulation.\n' ...
    'When using high symbol rates (> 1 GSym/s), start with a lower order\n' ...
    'modulation scheme (e.g. QPSK) and make sure it is decoded correctly\n' ...
    'and perform a magnitude/phase calibration using this scheme.\n' ...
    'Then switch to higher order modulation schemes.']));
set(handles.popupmenuFilter, 'TooltipString', sprintf([ ...
    'Select the pulse shaping filter that will be applied to the modulated\n' ...
    'baseband signal. Root raised cosine is the default and should normally\n' ...
    'be used except for experimental purposes.']));
set(handles.pushbuttonCalibrate, 'TooltipString', sprintf([ ...
    'This button uses the VSA software to perform a magnitude and phase\n' ...
    'calibration. After pressing this button, the VSA software will be started\n' ...
    '(if it is not already running) and automatically configured with the parameters\n' ...
    'in this utility. The equalizer in the VSA software is turned on and determines\n' ...
    'the frequency and phase response of the channel. After the equalizer has\n' ...
    'stabilized, you can press the OK button to generate a calibration file.\n' ...
    'Once the file has been created, pre-distortion is automatically applied\n' ...
    'to the original signal, the pre-distorted waveform is downloaded into the\n' ...
    'AWG and the equalizer in the VSA software is turned off.\n\n' ...
    'Please verify that you have the VSA calibration parameters (in particular\n' ...
    '"Fc" set to the correct value before starting the calibration process.']));
set(handles.editFc, 'TooltipString', sprintf([ ...
    'Set the center frequency that is used by the VSA software during calibration.\n' ...
    'Whenever the Carrier Offset parameter is modified, it will be copied into\n' ...
    'this field, but it can be changed afterwards. This is necessary in those cases\n' ...
    'where the output of the AWG is not analyzed directly, but is up-converted using\n' ...
    'an external I/Q modulator or mixer.']));
set(handles.checkboxCorrection, 'TooltipString', sprintf([ ...
    'Use this checkbox to pre-distort the signal using the previously established\n' ...
    'calibration values. Calibration can be performed using the multi-tone or\n' ...
    'digital modulation utilities.']));
set(handles.pushbuttonShowCorrection, 'TooltipString', sprintf([ ...
    'Use this button to visualize the frequency and phase response that has\n' ...
    'been captured using the "Calibrate" functionality in the multi-tone or\n' ...
    'digital modulation utility. In multi-tone, only magnitude corrections\n' ...
    'are captured whereas in digital modulation, both magnitude and phase\n' ...
    'response are calculated.']));
set(handles.editFilterNsym, 'TooltipString', sprintf([ ...
    'Set the filter length of the pulse shaping filter in units of symbols.\n']));
set(handles.editFilterBeta, 'TooltipString', sprintf([ ...
    'Set the filter roll-off for the pulse shaping filter.\n']));
set(handles.editQuadErr, 'TooltipString', sprintf([ ...
    'Set the quadrature error in degrees. Valid range is -360...+360 degrees.\n']));
set(handles.editIQSkew, 'TooltipString', sprintf([ ...
    'Set the IQ Skew in units of seconds.\n' ...
    'Positive values will delay the I component relative to Q\n']));
set(handles.editGainImbalance, 'TooltipString', sprintf([ ...
    'Set the gain imbalance in units of db.\n' ...
    'Positive values will amplify I vs. Q. Negative values will attenuate I vs. Q.\n']));
set(handles.editCarrierSpacing, 'TooltipString', sprintf([ ...
    'Set the carrier spacing for multi-carrier signals.\n' ...
    'The carrier spacing must be larger than the symbol rate.\n' ...
    'Carrier frequencies start with "Carrier offset" and go up in\n' ...
    'steps of "Carrier Spacing".\n']));
set(handles.editCarrierOffset, 'TooltipString', sprintf([ ...
    'Set the carrier offset to 0 to generate a baseband I/Q signal.\n' ...
    'Set it to a value between zero and Fs/2 to perform digital upconversion\n' ...
    'to that center frequency. For a signal in the second Nyquist band,\n' ...
    'set the carrier offset to a value between Fs/2 and Fs. For multi-carrier\n' ...
    'signals, you can enter a list of frequencies or a single value that and\n' ...
    'defines the first (lowest) carrier offset.']));
set(handles.editMagnitudes, 'TooltipString', sprintf([ ...
    'Enter a list of magnitudes in dB. Each carrier will be assigned a\n' ...
    'magnitude from this list. If the list contains fewer values than\n' ...
    'carriers, the list will be used repeatedly.']));
set(handles.pushbuttonChannelMapping, 'TooltipString', sprintf([ ...
    'Select into which channels the real and imaginary part of the waveform\n' ...
    'is loaded. By default, I is loaded into Channel 1, Q into channel 2, but\n' ...
    'it is also possible to load the same signal into both channels.\n' ...
    'In DUC modes, both I and Q are used for the same channel.\n' ...
    'In dual-M8190A configurations, channels 3 and 4 are on the second module.']));
set(handles.editSegment, 'TooltipString', sprintf([ ...
    'Enter the AWG waveform segment to which the signal will be downloaded.\n' ...
    'If you download to segment #1, all other segments will be automatically\n' ...
    'deleted.']));
set(handles.pushbuttonDisplay, 'TooltipString', sprintf([ ...
    'Use this button to calculate and show the simulated waveform using MATLAB plots.\n' ...
    'The signal will be displayed both in the time- as well as frequency\n' ...
    'domain (spectrum). This function can be used even without any hardware\n' ...
    'connected.']));
set(handles.pushbuttonDownload, 'TooltipString', sprintf([ ...
    'Use this button to calculate and download the signal to the configured AWG.\n' ...
    'Make sure that you have configured the connection parameters in "Configure\n' ...
    'instrument connection" before using this function.']));
% set(handles.pushbuttonShowVSA, 'TooltipString', sprintf([ ...
%     'Use this button to calculate and visualize the signal using the VSA software.\n' ...
%     'No hardware access is required.\n' ...
%     'If the VSA software is not already running, it will be started. The utility will\n' ...
%     'automatically configure the VSA software for the parameters of the generated signal.\n' ...
%     'VSA versions 15 and higher are supported.']));
end
% UIWAIT makes iqmod_gui wait for user response (see UIRESUME)
% uiwait(handles.iqtool);


% --- Outputs from this function are returned to the command line.
function varargout = iqmod_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editSampleRate_Callback(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSampleRate as text
%        str2double(get(hObject,'String')) returns contents of editSampleRate as a double
value = [];
arbConfig = loadArbConfig();
try
    value = evalin('base', get(handles.editSampleRate, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= arbConfig.minimumSampleRate && value <= arbConfig.maximumSampleRate)
    symbolRate = evalin('base',get(handles.editSymbolRate, 'String'));
    oversampling = value / symbolRate;
    % set the exact value temporarily - editOversampling_Callback will do
    % the rounding
    set(handles.editOversampling, 'String', iqengprintf(oversampling));
    editOversampling_Callback([], eventdata, handles);
end
checkfields([], 0, handles);


% --- Executes during object creation, after setting all properties.
function editSampleRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumSamples_Callback(hObject, eventdata, handles)
% hObject    handle to editNumSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumSamples as text
%        str2double(get(hObject,'String')) returns contents of editNumSamples as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 320 && value <= 64e6)
    oversampling = evalin('base',get(handles.editOversampling, 'String'));
    numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
    numSamples = evalin('base',get(handles.editNumSamples, 'String'));
    numSymbols = round(numSamples / oversampling);
    numSamples = calcNumSamples(numSymbols, oversampling, handles);
    set(handles.editNumSymbols, 'String', num2str(numSymbols));
    set(handles.editNumSamples, 'String', num2str(numSamples));
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


function numSamples = calcNumSamples(numSymbols, oversampling, handles)
% find rational number to approximate the oversampling
[overN overD] = rat(oversampling, handles.os_resolution);
% adjust number of samples to match AWG limitations
arbConfig = loadArbConfig();
overD1 = gcd(overD, numSymbols);
numSamples = lcm(numSymbols * overN / overD1, arbConfig.segmentGranularity);
while (numSamples < arbConfig.minimumSegmentSize)
    numSamples = 2 * numSamples;
end
numSymbols = round(numSamples / overN * overD);



% --- Executes during object creation, after setting all properties.
function editNumSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editOversampling_Callback(hObject, eventdata, handles)
% hObject    handle to editOversampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOversampling as text
%        str2double(get(hObject,'String')) returns contents of editOversampling as a double
oversampling = [];
try
    oversampling = evalin('base', get(handles.editOversampling, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(oversampling) && oversampling > 0 && oversampling <= 100000) % && (round(oversampling) == oversampling))
    symbolRate = evalin('base',get(handles.editSymbolRate, 'String'));
    numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
    [n,d] = rat(oversampling, handles.os_resolution);
    oversampling = n / d;
    sampleRate = symbolRate * oversampling;
    set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
    numSamples = calcNumSamples(numSymbols, oversampling, handles);
    set(handles.editNumSamples, 'String', num2str(numSamples));
    if (d ~= 1)
        set(handles.editOversampling, 'String', sprintf('%d / %d', n, d));
    end
    checkfields([], 0, handles);
end


% --- Executes during object creation, after setting all properties.
function editOversampling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOversampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editNumSymbols_Callback(hObject, eventdata, handles)
% hObject    handle to editNumSymbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumSymbols as text
%        str2double(get(hObject,'String')) returns contents of editNumSymbols as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 2 && value <= 10e6)
    numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
    oversampling = evalin('base',get(handles.editOversampling, 'String'));
    [n,d] = rat(oversampling, handles.os_resolution);
    oversampling = n / d;
    numSamples = calcNumSamples(numSymbols, oversampling, handles);
    set(handles.editNumSamples, 'String', num2str(numSamples));
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editNumSymbols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumSymbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editNumCarriers_Callback(hObject, eventdata, handles)
% hObject    handle to editNumCarriers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumCarriers as text
%        str2double(get(hObject,'String')) returns contents of editNumCarriers as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 1 && value <= 1000)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editNumCarriers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumCarriers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editParam2_Callback(hObject, eventdata, handles)
% hObject    handle to editParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editParam2 as text
%        str2double(get(hObject,'String')) returns contents of editParam2 as a double


% --- Executes during object creation, after setting all properties.
function editParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuModType.
function popupmenuModType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuModType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modTypeList = get(handles.popupmenuModType, 'String');
modTypeIdx = get(handles.popupmenuModType, 'Value');
switch modTypeList{modTypeIdx}
    case 'QAM256'; resLen = 512; conv = '1e-7';
    case 'QAM512'; resLen = 1024; conv = '1e-8';
    case 'QAM1024'; resLen = 2048; conv = '1e-9';
    case 'QAM2048'; resLen = 4096; conv = '1e-9';
    case 'QAM4096'; resLen = 4096; conv = '1e-9';
    otherwise; resLen = 256; conv = '1e-7';
end
set(handles.editResultLength, 'String', num2str(resLen));
set(handles.editConvergence, 'String', conv);


% --- Executes during object creation, after setting all properties.
function popupmenuModType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuModType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCarrierOffset_Callback(hObject, eventdata, handles)
% hObject    handle to editCarrierOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCarrierOffset as text
%        str2double(get(hObject,'String')) returns contents of editCarrierOffset as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
arbConfig = loadArbConfig();
if (isvector(value) && ~isempty(value) ...
        && isempty(find(abs(value) < -1*arbConfig.maximumSampleRate)) ...
        && isempty(find(abs(value) > arbConfig.maximumSampleRate)))
    if (length(value) > 1)
        set(handles.checkboxMulti, 'Value', 1);
        set(handles.checkboxMulti, 'Enable', 'off');
        set(handles.textMultiCarrier, 'Enable', 'off');
        set(handles.editNumCarriers, 'String', sprintf('%d', length(value)));
    else
        set(handles.checkboxMulti, 'Value', 0);
        set(handles.checkboxMulti, 'Enable', 'on');
        set(handles.textMultiCarrier, 'Enable', 'on');
    end
    if (isfield(arbConfig, 'defaultFc'))
        set(handles.editFc, 'String', iqengprintf(arbConfig.defaultFc + value(1)));
    else
        set(handles.editFc, 'String', iqengprintf(value(1)));
    end
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end
checkboxMulti_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function editCarrierOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCarrierOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonDisplay.
function pushbuttonDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[iqdata sampleRate oversampling marker] = calcModIQ(handles);
%iqplot(iqdata, sampleRate, 'constellation');
%iqplot(iqdata, sampleRate, 'oversampling', oversampling);
%iqplot(iqdata, sampleRate, 'marker', marker);
iqplot(iqdata, sampleRate);
% eyediagram(iqdata, 2*oversampling);


% --- Executes on button press in pushbuttonDownload.
function pushbuttonDownload_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDownload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.lastDownload = 'HW';
guidata(hObject, handles);
[iqdata sampleRate oversampling marker] = calcModIQ(handles);
channelMapping = get(handles.pushbuttonChannelMapping, 'UserData');
segmentNum = evalin('base', get(handles.editSegment, 'String'));
marker = downloadClock(handles);
hMsgBox = msgbox('Downloading Waveform. Please wait...', 'Please wait...', 'replace');
iqdata = setFreqInCalToneWindow(handles, iqdata);
iqdownload(iqdata, sampleRate, 'channelMapping', channelMapping, ...
    'segmentNumber', segmentNum, 'marker', marker);
try close(hMsgBox); catch ex; end
set(handles.pushbuttonCalibrate, 'Enable', 'on');
set(handles.editFc, 'Enable', 'on');
set(handles.textFc, 'Enable', 'on');
set(handles.editFilterLength, 'Enable', 'on');
set(handles.textFilterLength, 'Enable', 'on');
set(handles.editConvergence, 'Enable', 'on');
set(handles.textConvergence, 'Enable', 'on');
set(handles.editResultLength, 'Enable', 'on');
set(handles.textResultLength, 'Enable', 'on');



function iqdata = setFreqInCalToneWindow(handles, iqdata)
% Update the Frequency Edit Field in Calibrated Tone window
try
    amplitude = evalin('base', ['[' get(handles.editMagnitudes, 'String') ']']);
    freq = evalin('base', ['[' get(handles.editCarrierOffset, 'String') ']']);
    if (~isreal(amplitude) || ~isscalar(amplitude) || ~isreal(freq) || ~isscalar(freq))
        return
    end
    % figure out the crest factor of the signal and adjust the power level
    % accordingly
    rms = norm(real(iqdata)) / sqrt(length(iqdata));
    peak = max(abs(real(iqdata)));
    crestdB = 10*log10(peak^2/rms^2);
    amplitude = amplitude + crestdB;
    TempHide = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    figs = findobj(0, 'Type', 'figure', 'Name', 'Tones with calibrated power level');
    set(0, 'ShowHiddenHandles', TempHide);
    for i = 1:length(figs)
        fig = figs(i);
        [path file ext] = fileparts(get(fig, 'Filename'));
        xhandles = guihandles(fig);
        set(xhandles.editFreq, 'String', iqengprintf(freq));
        set(xhandles.editPower, 'String', iqengprintf(amplitude));
        feval(file, 'editFreq_Callback', xhandles.editFreq, 'check', xhandles);
        feval(file, 'editPower_Callback', xhandles.editPower, 'check', xhandles);
        chMap = get(handles.pushbuttonChannelMapping, 'UserData');
        ed = cell2struct({'setFreq', chMap, freq, amplitude}, ...
                         {'cmd', 'channelMapping', 'freq', 'power'}, 2);
        result = feval(file, 'setFreqAndPower', xhandles, ed);
        if (~isempty(result))
            scale = max(max(abs(real(iqdata))), max(abs(imag(iqdata))));
            iqdata = iqdata / scale;
        end
    end
catch ex
    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
end



function marker = downloadClock(handles)
% download a clock signal on unchecked channels, but don't start the generator
marker = [];
div = 1;
clockPat = 'clock';
if (strcmp('on', get(handles.menuClock2, 'Checked')))
    div = 2;
    clockPat = 'clock';
elseif (strcmp('on', get(handles.menuClock4, 'Checked')))
    div = 4;
    clockPat = 'clock4';
elseif (strcmp('on', get(handles.menuClock8, 'Checked')))
    div = 8;
    clockPat = 'clock8';
elseif (strcmp('on', get(handles.menuClock16, 'Checked')))
    div = 16;
    clockPat = 'clock16';
elseif (strcmp('on', get(handles.menuClockOnce, 'Checked')))
    clockPat = 'clockOnce';
end
numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
% check if we need to generate a clock at all
if (div > 1)
    if (mod(numSymbols, div) ~= 0)
        warndlg(sprintf('Number of bits is not a multiple of %d - clock signal will not be periodic', div), 'Warning', 'replace');
    end
    % calculate the clock waveform
    [s fs oversampling marker] = calcModIQ(handles, 0, clockPat);
    if (~isempty(s))
        chMap = get(handles.pushbuttonChannelMapping, 'UserData');
        % find all "unchecked" channels 
        chMap(:,1) = ~chMap(:,1) & ~chMap(:,2);
        chMap(:,2) = zeros(size(chMap,1), 1);
        segmentNum = evalin('base', get(handles.editSegment, 'String'));
        if (~isempty(find(chMap(1:end), 1)))
            iqdownload(s, fs, 'channelMapping', chMap, 'segmentNumber', segmentNum, 'run', 0);
        end
        % calculate the marker signal
        symbolRate = evalin('base', get(handles.editSymbolRate, 'String'));
        numSamples = length(s);
        % find the oversampling ratio, ignore the fractional part, since it
        % can not be realized with markers
        [overN overD] = rat(fs / symbolRate * div);
        % for 1x oversampling, set marker every other symbol
        overN = max(overN, 2);
        % don't send markers faster than 10 GHz (DCA)
        maxTrig = 5e9;
        % for M8190A, max toggle rate for markers = sequencer clock
        if (fs <= 12e9) 
            maxTrig = fs / 64;
        end
        % for M8195A, markers can toggle at a max. rate of fs/128
        if (fs > 50e9 && fs < 70e9)
            maxTrig = fs / 128;
        end
        if (ceil(fs / maxTrig / overN) > 1)
            overN = overN * ceil(fs / maxTrig / overN);
        end
        h1 = floor(overN / 2);
        h2 = overN - h1;
        marker = repmat([15*ones(1,h1) zeros(1,h2)], 1, ceil(numSamples / overN));
        marker = marker(1:numSamples);
    end
end


% --- Executes on button press in pushbuttonShowCorrection.
function pushbuttonShowCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonShowCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqcorrmgmt();


function editCarrierSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to editCarrierSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCarrierSpacing as text
%        str2double(get(hObject,'String')) returns contents of editCarrierSpacing as a double
checkCarrierSpacingSymbolRate(handles);


function checkCarrierSpacingSymbolRate(handles)
carrierSpacing = [];
csValid = false;
symbolRate = [];
srValid = false;
ofValid = false;
offset = 0;
numCarrier = 1;
arbConfig = loadArbConfig();
try
    carrierSpacing = evalin('base', get(handles.editCarrierSpacing, 'String'));
catch ex
end
try
    symbolRate = evalin('base', get(handles.editSymbolRate, 'String'));
catch ex
end
try
    offset = evalin('base', ['[' get(handles.editCarrierOffset, 'String') ']']);
catch ex
end
try
    numCarrier = evalin('base', get(handles.editNumCarriers, 'String'));
catch ex
end
multi = get(handles.checkboxMulti, 'Value');

if (isscalar(carrierSpacing) && carrierSpacing >= 0 && carrierSpacing <= arbConfig.maximumSampleRate)
    csValid = true;
end
if (isscalar(symbolRate) && symbolRate <= arbConfig.maximumSampleRate)
    srValid = true;
end
if (isvector(offset) && ~isempty(offset) ...
        && isempty(find(abs(offset) > arbConfig.maximumSampleRate)))
    ofValid = true;
end
if (csValid && srValid && length(offset) > 1 && symbolRate > min(diff(sort(offset))))
    ofValid = false;
    srValid = false;
end
if (csValid && srValid && length(offset) <= 1 && multi && carrierSpacing < symbolRate)
    csValid = false;
    srValid = false;
end
if (csValid)
    set(handles.editCarrierSpacing,'BackgroundColor','white');
else
    set(handles.editCarrierSpacing,'BackgroundColor','red');
end
if (srValid)
    set(handles.editSymbolRate,'BackgroundColor','white');
else
    set(handles.editSymbolRate,'BackgroundColor','red');
end
if (ofValid)
    set(handles.editCarrierOffset,'BackgroundColor','white');
else
    set(handles.editCarrierOffset,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editCarrierSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCarrierSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAutoSamples.
function checkboxAutoSamples_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAutoSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAutoSamples
autoSamples = get(hObject,'Value');
if (autoSamples)
    set(handles.editNumSamples, 'Enable', 'off');
else
    set(handles.editNumSamples, 'Enable', 'on');
end;


% --- Executes on selection change in popupmenuFilter.
function popupmenuFilter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFilter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFilter
filterList = get(handles.popupmenuFilter, 'String');
filter = filterList{get(handles.popupmenuFilter, 'Value')};
if (strcmp(filter, 'Gaussian'))
    set(handles.textNSymAlpha, 'String', '        Nsym / BT');
else
    set(handles.textNSymAlpha, 'String', '        Nsym / Alpha');
end
editFilterBeta_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function popupmenuFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editSymbolRate_Callback(hObject, eventdata, handles)
% hObject    handle to editSymbolRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSymbolRate as text
%        str2double(get(hObject,'String')) returns contents of editSymbolRate as a double
arbConfig = loadArbConfig();
symbolRate = [];
try
    symbolRate = evalin('base', get(handles.editSymbolRate, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(symbolRate) && symbolRate >= 1e3 && symbolRate <= 100e9)
    oldSampleRate = evalin('base',get(handles.editSampleRate, 'String'));
    numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
    % re-calculate oversampling & sampleRate - try to make it integer
    oversampling = floor(oldSampleRate / symbolRate);
    if (oversampling < 1)
        oversampling = 1;
    end
    sampleRate = symbolRate * oversampling;
    if (sampleRate < arbConfig.minimumSampleRate)
        % if sample rate is too small, try non-integer oversampling
        sampleRate = oldSampleRate;
%        sampleRate = arbConfig.maximumSampleRate;
%        set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
    end
    [n,d] = rat(sampleRate / symbolRate, handles.os_resolution);
    oversampling = n/d;
    if (d ~= 1)
        set(handles.editOversampling, 'String', sprintf('%d / %d', n, d));
    else
        set(handles.editOversampling, 'String', num2str(oversampling));
    end
    set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
    numSamples = calcNumSamples(numSymbols, oversampling, handles);
    set(handles.editNumSamples, 'String', num2str(numSamples));
end
checkfields(hObject, 0, handles);

% --- Executes during object creation, after setting all properties.
function editSymbolRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSymbolRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMagnitudes_Callback(hObject, eventdata, handles)
% hObject    handle to editMagnitudes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMagnitudes as text
%        str2double(get(hObject,'String')) returns contents of editMagnitudes as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isvector(value) && length(value) >= 1)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editMagnitudes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMagnitudes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxCorrection.
function checkboxCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCorrection
correction = get(handles.checkboxCorrection,'Value');
if (correction)
    set(handles.pushbuttonCalibrate, 'String', 'Re-calibrate');
else
    set(handles.pushbuttonCalibrate, 'String', 'Calibrate (VSA)');
end;




function editFilterNsym_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterNsym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterNsym as text
%        str2double(get(hObject,'String')) returns contents of editFilterNsym as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 1 && value <= 5000)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editFilterNsym_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterNsym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFilterBeta_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterBeta as text
%        str2double(get(hObject,'String')) returns contents of editFilterBeta as a double
value = [];
try
    value = evalin('base', get(handles.editFilterBeta, 'String'));
catch ex
    msgbox(ex.message);
end
filterList = get(handles.popupmenuFilter, 'String');
filterIdx = get(handles.popupmenuFilter, 'Value');
filterType = filterList{filterIdx};
if (isscalar(value) && value >= 0 && (value <= 1 || isempty(strfind(filterType, 'osine'))))
    set(handles.editFilterBeta, 'BackgroundColor', 'white');
else
    set(handles.editFilterBeta, 'BackgroundColor', 'red');
end


% --- Executes during object creation, after setting all properties.
function editFilterBeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxMulti.
function checkboxMulti_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMulti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMulti
multiCarrier = get(handles.checkboxMulti,'Value');
offset = evalin('base', ['[' get(handles.editCarrierOffset, 'String') ']']);
if (multiCarrier)
    if (length(offset) > 1)
        set(handles.editNumCarriers, 'Enable', 'off');
        set(handles.editCarrierSpacing, 'Enable', 'off');
    else
        set(handles.editNumCarriers, 'Enable', 'on');
        set(handles.editCarrierSpacing, 'Enable', 'on');
    end
    set(handles.editMagnitudes, 'Enable', 'on');
else
    set(handles.editNumCarriers, 'Enable', 'off');
    set(handles.editCarrierSpacing, 'Enable', 'off');
    set(handles.editMagnitudes, 'Enable', 'off');
end;
checkCarrierSpacingSymbolRate(handles);



function editFc_Callback(hObject, eventdata, handles)
% hObject    handle to editFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFc as text
%        str2double(get(hObject,'String')) returns contents of editFc as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
% allow positive and negative Fc, negative ones indicate that
% the spectrum is inverted
if (isscalar(value) && value >= -50e9 && value <= 50e9)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editFc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFilterLength_Callback(hObject, eventdata, handles)
% hObject    handle to editFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilterLength as text
%        str2double(get(hObject,'String')) returns contents of editFilterLength as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 1 && value <= 99 && (round(value) == value))
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editFilterLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilterLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editResultLength_Callback(hObject, eventdata, handles)
% hObject    handle to editResultLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editResultLength as text
%        str2double(get(hObject,'String')) returns contents of editResultLength as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 1 && value <= 10000 && (round(value) == value))
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editResultLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editResultLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editConvergence_Callback(hObject, eventdata, handles)
% hObject    handle to editConvergence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editConvergence as text
%        str2double(get(hObject,'String')) returns contents of editConvergence as a double
value = [];
try
    value = evalin('base', get(hObject, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value > 0 && value <= 1)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end



function editSegment_Callback(hObject, eventdata, handles)
% hObject    handle to editSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSegment as text
%        str2double(get(hObject,'String')) returns contents of editSegment as a double
checkfields(hObject, 0, handles);

% --- Executes during object creation, after setting all properties.
function editSegment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editConvergence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editConvergence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonShowVSA.
function pushbuttonShowVSA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonShowVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showInVSA(hObject, eventdata, handles);



function showInVSA(hObject, eventdata, handles)
handles.lastDownload = 'VSA';
guidata(hObject, handles);
fc = evalin('base', ['[' get(handles.editCarrierOffset, 'String') ']']);
fc = fc(1);
symbolRate = evalin('base',get(handles.editSymbolRate, 'String'));
modTypeList = get(handles.popupmenuModType, 'String');
modTypeIdx = get(handles.popupmenuModType, 'Value');
filterList = get(handles.popupmenuFilter, 'String');
filterIdx = get(handles.popupmenuFilter, 'Value');
filterBeta = evalin('base',get(handles.editFilterBeta, 'String'));
resultLength = evalin('base', get(handles.editResultLength, 'String'));
filterLength = evalin('base', get(handles.editFilterLength, 'String'));
convergence = evalin('base', get(handles.editConvergence, 'String'));
[iqdata sampleRate oversampling marker] = calcModIQ(handles);
vsaApp = vsafunc([], 'open');
if (~isempty(vsaApp))
    hMsgBox = msgbox('Configuring VSA software. Please wait...');
    vsafunc(vsaApp, 'preset');
    vsafunc(vsaApp, 'input', 1);
    vsafunc(vsaApp, 'load', iqdata, sampleRate);
    vsafunc(vsaApp, 'DigDemod', modTypeList{modTypeIdx}, symbolRate, filterList{filterIdx}, filterBeta, resultLength);
    vsafunc(vsaApp, 'equalizer', false, filterLength, convergence);
    if (strcmp(filterList{filterIdx}, 'Gaussian'))
        spanScale = 9 * filterBeta;
    else
        spanScale = 1.6;
    end
    vsafunc(vsaApp, 'freq', fc, symbolRate * spanScale, 51201, 'flattop', 3);
    vsafunc(vsaApp, 'trace', 4, 'DigDemod');
    vsafunc(vsaApp, 'start', 1);
    vsafunc(vsaApp, 'autoscale');
    try
        close(hMsgBox);
    catch
    end
end


% --- Executes on button press in pushbuttonSetupVSA.
function pushbuttonSetupVSA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetupVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbuttonCalibrate.
downloadAndSetupVSA(hObject, eventdata, handles, 0);


function pushbuttonCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
downloadAndSetupVSA(hObject, eventdata, handles, 1);


function downloadAndSetupVSA(hObject, eventdata, handles, doCal)
symbolRate = evalin('base',get(handles.editSymbolRate, 'String'));
modTypeList = get(handles.popupmenuModType, 'String');
modTypeIdx = get(handles.popupmenuModType, 'Value');
filterList = get(handles.popupmenuFilter, 'String');
filterIdx = get(handles.popupmenuFilter, 'Value');
filterBeta = evalin('base',get(handles.editFilterBeta, 'String'));
carrierOffset = evalin('base',get(handles.editCarrierOffset, 'String'));
fc = evalin('base',get(handles.editFc, 'String'));
filterLength = evalin('base', get(handles.editFilterLength, 'String'));
convergence = evalin('base', get(handles.editConvergence, 'String'));
resultLength = evalin('base', get(handles.editResultLength, 'String'));
multiCarrier = get(handles.checkboxMulti, 'Value');
recal = get(handles.checkboxCorrection, 'Value');
if (multiCarrier && doCal)
    errordlg('VSA Calibration is only possible with single carrier', 'Error');
    return;
end
if (isfield(handles, 'lastDownload') && strcmp(handles.lastDownload, 'VSA'))
    useHW = 0;
else
    useHW = 1;
end
if (~recal && doCal)
    [ampCorr perChannelCorr] = iqcorrection([]);
    if (~isempty(perChannelCorr))
        res = questdlg({'You have per-channel corrections defined, but they are not applied.' ...
            'Do you want to continue?? ' ...
            '(If you click "Yes", the per-channel corrections will be erased)'}, ...
            'Calibration', 'Yes', 'No', 'No');
        if (strcmp(res, 'Yes') == 0)
            return;
        end
    end
end
doLastDownload(hObject, eventdata, handles);
result = iqvsacal('symbolRate', symbolRate, ...
    'modType', modTypeList{modTypeIdx}, ...
    'filterType', filterList{filterIdx}, ...
    'filterBeta', filterBeta, ...
    'carrierOffset', carrierOffset, ...
    'fc', fc, ...
    'filterLength', filterLength, ...
    'convergence', convergence, ...
    'resultLength', resultLength, ...
    'recalibrate', recal, ...
    'useHW', useHW, ...
    'doCal', doCal);
if (result == 0 && doCal)
    set(handles.checkboxCorrection, 'Value', 1);
    checkboxCorrection_Callback(hObject, eventdata, handles);
    doLastDownload(hObject, eventdata, handles);
    try
        close(10);
    catch
    end
    updateCorrWindow();
end


function doLastDownload(hObject, eventdata, handles)
% perform the "last" download action: either download to HW or to VSA
if (isfield(handles, 'lastDownload') && strcmp(handles.lastDownload, 'VSA'))
    pushbuttonShowVSA_Callback(hObject, eventdata, handles);
else
    pushbuttonDownload_Callback(hObject, eventdata, handles);
end


function updateCorrWindow()
% If Correction Mgmt Window is open, refresh it
try
    TempHide = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    figs = findobj(0, 'Type', 'figure', 'Name', 'Correction Management');
    set(0, 'ShowHiddenHandles', TempHide);
    if (~isempty(figs))
        iqcorrmgmt();
    end
catch ex
end


% --------------------------------------------------------------------
function menuPreset_Callback(hObject, eventdata, handles)
% hObject    handle to menuPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_QAM16_1GSym_Callback(hObject, eventdata, handles)
% hObject    handle to menu_QAM16_1GSym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
symbolRate = 1e9;
overSampling = floor(arbConfig.maximumSampleRate / symbolRate);
sampleRate = symbolRate * overSampling;
if (overSampling < 1)
    errordlg('symbol rate too high for this instrument');
    return;
end
set(handles.editSymbolRate, 'String', iqengprintf(symbolRate));
set(handles.editOversampling, 'String', iqengprintf(overSampling));
set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
set(handles.popupmenuModType, 'Value', 8);  % QAM16
set(handles.popupmenuFilter, 'Value', 1); % RRC
set(handles.editFilterNsym, 'String', '20');
set(handles.editFilterBeta, 'String', '0.35');
set(handles.editCarrierOffset, 'String', '2e9');
set(handles.editFc, 'String', '2e9');
set(handles.checkboxMulti, 'Value', 0);
editSymbolRate_Callback(hObject, eventdata, handles);
checkboxMulti_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menu_QAM16_1_76GSym_Callback(hObject, eventdata, handles)
% hObject    handle to menu_QAM16_1_76GSym (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
symbolRate = 1.76e9;
overSampling = floor(arbConfig.maximumSampleRate / symbolRate);
sampleRate = symbolRate * overSampling;
if (overSampling < 1)
    errordlg('symbol rate too high for this instrument');
    return;
end
fc = 2e9;
set(handles.editSymbolRate, 'String', iqengprintf(symbolRate));
set(handles.editOversampling, 'String', iqengprintf(overSampling));
set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
set(handles.popupmenuModType, 'Value', 8);  % QAM16
set(handles.popupmenuFilter, 'Value', 1); % RRC
set(handles.editFilterNsym, 'String', '20');
set(handles.editFilterBeta, 'String', '0.35');
set(handles.editCarrierOffset, 'String', iqengprintf(fc));
set(handles.editFc, 'String', iqengprintf(fc + arbConfig.defaultFc));
set(handles.checkboxMulti, 'Value', 0);
editSymbolRate_Callback(hObject, eventdata, handles);
checkboxMulti_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function MultiCarrier_Callback(hObject, eventdata, handles)
% hObject    handle to MultiCarrier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
symbolRate = 6e6;
carrierSpacing = 8e6;
overSampling = floor(arbConfig.maximumSampleRate / symbolRate);
sampleRate = symbolRate * overSampling;
if (overSampling < 1)
    errordlg('symbol rate too high for this instrument');
    return;
end
fc = 100e6;
set(handles.editSymbolRate, 'String', iqengprintf(symbolRate));
set(handles.editOversampling, 'String', iqengprintf(overSampling));
set(handles.editSampleRate, 'String', iqengprintf(sampleRate));
set(handles.editNumSymbols, 'String', iqengprintf(192));
set(handles.popupmenuModType, 'Value', 8);  % QAM16
set(handles.popupmenuFilter, 'Value', 1); % RRC
set(handles.editFilterNsym, 'String', '20');
set(handles.editFilterBeta, 'String', '0.35');
set(handles.editCarrierOffset, 'String', iqengprintf(fc));
set(handles.editFc, 'String', iqengprintf(fc + arbConfig.defaultFc));
set(handles.checkboxMulti, 'Value', 1);
set(handles.editCarrierSpacing, 'String', iqengprintf(carrierSpacing));
set(handles.editNumCarriers, 'String', '50');
set(handles.editMagnitudes, 'String', '0 0 0 0 0 -300');
editSymbolRate_Callback(hObject, eventdata, handles);
checkboxMulti_Callback(hObject, eventdata, handles);



function [iqdata sampleRate oversampling marker] = calcModIQ(handles, doCode, clockPat)
% handles    structure with handles and user data (see GUIDATA)
marker = [];
sampleRate = evalin('base',get(handles.editSampleRate, 'String'));
autoSamples = get(handles.checkboxAutoSamples, 'Value');
numSymbols = evalin('base',get(handles.editNumSymbols, 'String'));
modTypeList = get(handles.popupmenuModType, 'String');
modType = modTypeList{get(handles.popupmenuModType, 'Value')};
dataTypeList = get(handles.popupmenuData, 'String');
dataType = dataTypeList{get(handles.popupmenuData, 'Value')};
% overwrite dataType with clockPat if it is given
if (exist('clockPat', 'var'))
    dataType = clockPat;
end
filename = get(handles.editFilename, 'String');
dataContent = evalin('base', ['[' get(handles.editData, 'String') ']']);
oversampling = evalin('base',get(handles.editOversampling, 'String'));
filterList = get(handles.popupmenuFilter, 'String');
filterIdx = get(handles.popupmenuFilter, 'Value');
filterNsym = evalin('base',get(handles.editFilterNsym, 'String'));
filterBeta = evalin('base',get(handles.editFilterBeta, 'String'));
numCarriers = evalin('base',get(handles.editNumCarriers, 'String'));
carrierSpacing = evalin('base',get(handles.editCarrierSpacing, 'String'));
carrierOffset = evalin('base', ['[' get(handles.editCarrierOffset, 'String') ']']);
magnitudes = evalin('base', ['[' get(handles.editMagnitudes, 'String') ']']);
quadErr = evalin('base', ['[' get(handles.editQuadErr, 'String') ']']);
iqskew = evalin('base', ['[' get(handles.editIQSkew, 'String') ']']);
gainImbalance = evalin('base', ['[' get(handles.editGainImbalance, 'String') ']']);
correction = get(handles.checkboxCorrection, 'Value');
multiCarrier = get(handles.checkboxMulti, 'Value');
if (multiCarrier && length(carrierOffset) == 1)
    carrierOffset = carrierOffset:carrierSpacing:(carrierOffset + (numCarriers - 1) * carrierSpacing + 0.01);
end

if (autoSamples)
    numSamples = 0;
end
if (exist('doCode', 'var') && doCode ~= 0)
    channelMapping = iqchannelsetup('arraystring', get(handles.pushbuttonChannelMapping, 'UserData'));
    segmentNum = evalin('base', get(handles.editSegment, 'String'));
    magnitudes = ['[' strtrim(sprintf('%g ', magnitudes)) ']'];
    fsStr = sprintf('fs = %s;\n', iqengprintf(sampleRate));
    if (length(carrierOffset) > 1)
        coStr = ['carrierOffset = [' strtrim(sprintf('%.7g ', carrierOffset)) '];\n'];
        carrierOffset = 'carrierOffset';
    else
        coStr = '';
        carrierOffset = strtrim(sprintf('%.7g', carrierOffset));
    end
    if (~isempty(strfind(dataType, 'User defined')))
        contentStr = sprintf(' ...\n    ''dataContent'', [%s],', strtrim(sprintf('%g ', dataContent)));
    elseif (~isempty(strfind(dataType, 'from file')))
        contentStr = sprintf(' ...\n    ''filename'', ''%s''', filename);
    else
        contentStr = '';
    end
    iqdata = [sprintf([fsStr coStr 'iqdata = iqmod(''sampleRate'', fs, ''numSymbols'', %d, ...\n' ...
    '    ''data'', ''%s'', ''modType'', ''%s'', ''oversampling'', %g,%s ...\n' ...
    '    ''filterType'', ''%s'', ''filterNsym'', %g, ...\n' ...
    '    ''filterBeta'', %g, ''carrierOffset'', %s, ''magnitude'', %s, ...\n' ...
    '    ''quadErr'', %g, ''iqskew'', %g, ''gainImbalance'', %g, ''correction'', %d);\n' ...
    'iqdownload(iqdata, fs, ''channelMapping'', %s, ...\n' ...
    '    ''segmentNumber'', %d, ''marker'', []);\n'], ...
        numSymbols, dataType, modType, oversampling, contentStr, ...
        filterList{filterIdx}, filterNsym, filterBeta, carrierOffset, ...
        magnitudes, quadErr, iqskew, gainImbalance, correction, channelMapping, segmentNum)];
else
    hMsgBox = msgbox('Calculating Waveform. Please wait...', 'Please wait...', 'replace');
    [iqdata, newSampleRate, newNumSymbols] = iqmod('sampleRate', sampleRate, ...
        'numSymbols', numSymbols, ...
        'data', dataType, ...
        'modType', modType, ...
        'oversampling', oversampling, ...
        'dataContent', dataContent, ...
        'filename', filename, ...
        'filterType', filterList{filterIdx}, ...
        'filterNsym', filterNsym, ...
        'filterBeta', filterBeta, ...
        'carrierOffset', carrierOffset, ...
        'magnitude', magnitudes, ...
        'quadErr', quadErr, ...
        'iqSkew', iqskew, ...
        'gainImbalance', gainImbalance, ...
        'correction', correction);
    try close(hMsgBox); catch; end
    if (~exist('clockPat', 'var') || isempty(clockPat))
        assignin('base', 'iqdata', iqdata);
        assignin('base', 'fs', newSampleRate);
    end
    numSamples = length(iqdata);
    set(handles.editNumSamples, 'String', sprintf('%d', numSamples));
    set(handles.editNumSymbols, 'String', sprintf('%d', newNumSymbols));
    if (newSampleRate ~= sampleRate)
        msgbox(sprintf(['Waveform was re-sampled to match AWG granularity requirements.\n' ...
            'Sample Rate of %s will be used'], iqengprintf(newSampleRate, 8)), 'Note', 'replace');
        sampleRate = newSampleRate;
    end
    % set(handles.editSampleRate, 'String', iqengprintf(newSampleRate));
    [overN overD] = rat(oversampling);
    % for 1x oversampling, set marker every other symbol
    overN = max(overN, 2);
    % don't send markers faster than 10 GHz (DCA)
    maxTrig = 5e9;
    if (floor(sampleRate / maxTrig / overN) > 1)
        overN = overN * floor(sampleRate / maxTrig / overN);
    end
    h1 = floor(overN / 2);
    h2 = overN - h1;
    marker = repmat([15*ones(1,h1) zeros(1,h2)], 1, ceil(numSamples / overN));
    marker = marker(1:numSamples);
end

% --------------------------------------------------------------------
function menuLoadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqloadsettings(handles);
popupmenuData_Callback([], [], handles);


% --------------------------------------------------------------------
function menuSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqsavesettings(handles);


% --------------------------------------------------------------------
function menuSaveWaveform_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveWaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Y sampleRate oversampling marker] = calcModIQ(handles);
iqsavewaveform(Y, sampleRate);


function result = checkfields(hObject, eventdata, handles)
% This function verifies that all the fields have valid and consistent
% values. It is called from inside this script as well as from the
% iqconfig script when arbConfig changes (i.e. a different model or mode is
% selected). Returns 1 if all fields are OK, otherwise 0
result = 1;
arbConfig = loadArbConfig();

% --- generic checks
if (arbConfig.maxSegmentNumber <= 1)
    set(handles.editSegment, 'Enable', 'off');
    set(handles.textSegment, 'Enable', 'off');
else
    set(handles.editSegment, 'Enable', 'on');
    set(handles.textSegment, 'Enable', 'on');
end
% --- channel mapping
iqchannelsetup('setup', handles.pushbuttonChannelMapping, arbConfig);
% --- editSampleRate
value = [];
try
    value = evalin('base', get(handles.editSampleRate, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= arbConfig.minimumSampleRate && value <= arbConfig.maximumSampleRate)
    set(handles.editSampleRate,'BackgroundColor','white');
else
    set(handles.editSampleRate,'BackgroundColor','red');
end
% --- oversampling
oversampling = evalin('base',get(handles.editOversampling, 'String'));
if (isscalar(oversampling) && oversampling >= 1 && oversampling <= 100000)
    set(handles.editOversampling, 'BackgroundColor', 'white');
else
    set(handles.editOversampling, 'BackgroundColor', 'red');
end
% --- editSymbolRate
value = [];
try
    value = evalin('base', get(handles.editSymbolRate, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 1e3 && value <= 100e9)
end
checkCarrierSpacingSymbolRate(handles);
% --- editSegment
value = [];
try
    value = evalin('base', get(handles.editSegment, 'String'));
catch ex
    msgbox(ex.message);
    result = 0;
end
if (isscalar(value) && value >= 1 && value <= arbConfig.maxSegmentNumber)
    set(handles.editSegment,'BackgroundColor','white');
else
    set(handles.editSegment,'BackgroundColor','red');
    result = 0;
end



function editQuadErr_Callback(hObject, eventdata, handles)
% hObject    handle to editQuadErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuadErr as text
%        str2double(get(hObject,'String')) returns contents of editQuadErr as a double
value = [];
arbConfig = loadArbConfig();
try
    value = evalin('base', get(handles. editQuadErr, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= -360 && value <= 360)
    set(handles. editQuadErr, 'Background', 'white');
else
    set(handles. editQuadErr, 'Background', 'red');
end




% --- Executes during object creation, after setting all properties.
function editQuadErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuadErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuGenerateCode_Callback(hObject, eventdata, handles)
% hObject    handle to menuGenerateCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
code = calcModIQ(handles, 1);
iqgeneratecode(handles, code);


% --- Executes on button press in pushbuttonChannelMapping.
function pushbuttonChannelMapping_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonChannelMapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arbConfig = loadArbConfig();
[val, str] = iqchanneldlg(get(handles.pushbuttonChannelMapping, 'UserData'), arbConfig, handles.iqtool);
if (~isempty(val))
    set(handles.pushbuttonChannelMapping, 'UserData', val);
    set(handles.pushbuttonChannelMapping, 'String', str);
end


% --- Executes on selection change in popupmenuData.
function popupmenuData_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataTypeList = cellstr(get(handles.popupmenuData, 'String'));
dataType = dataTypeList{get(handles.popupmenuData, 'Value')};
if (~isempty(strfind(dataType, 'User defined')))
    set(handles.textData, 'String', 'Data content');
    set(handles.editFilename, 'Visible', 'off');
    set(handles.editData, 'Visible', 'on');
    set(handles.editData, 'Enable', 'on');
    set(handles.pushbuttonFilename, 'Enable', 'off');
elseif (~isempty(strfind(dataType, 'from file')))
    set(handles.textData, 'String', 'Filename');
    set(handles.editData, 'Visible', 'off');
    set(handles.editFilename, 'Visible', 'on');
    set(handles.editFilename, 'Enable', 'on');
    set(handles.pushbuttonFilename, 'Enable', 'on');
else
    set(handles.editData, 'Enable', 'off');
    set(handles.editFilename, 'Enable', 'off');
    set(handles.pushbuttonFilename, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupmenuData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editIQSkew_Callback(hObject, eventdata, handles)
% hObject    handle to editIQSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIQSkew as text
%        str2double(get(hObject,'String')) returns contents of editIQSkew as a double
value = [];
arbConfig = loadArbConfig();
try
    value = evalin('base', get(handles.editIQSkew, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= -1 && value <= 1)
    set(handles.editIQSkew, 'Background', 'white');
else
    set(handles.editIQSkew, 'Background', 'red');
end



% --- Executes during object creation, after setting all properties.
function editIQSkew_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIQSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editGainImbalance_Callback(hObject, eventdata, handles)
% hObject    handle to editGainImbalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGainImbalance as text
%        str2double(get(hObject,'String')) returns contents of editGainImbalance as a double
value = [];
arbConfig = loadArbConfig();
try
    value = evalin('base', get(handles.editGainImbalance, 'String'));
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= -30 && value <= 30)
    set(handles.editGainImbalance, 'Background', 'white');
else
    set(handles.editGainImbalance, 'Background', 'red');
end


% --- Executes during object creation, after setting all properties.
function editGainImbalance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGainImbalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editData_Callback(hObject, eventdata, handles)
% hObject    handle to editData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editData as text
%        str2double(get(hObject,'String')) returns contents of editData as a double


% --- Executes during object creation, after setting all properties.
function editData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFilename.
function pushbuttonFilename_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isfield(handles, 'LastFileName'))
    lastFilename = handles.LastFileName;
else
    lastFilename = '';
end
types = '*.ptrn;*.txt;*.csv';
try
[FileName,PathName] = uigetfile(types, 'Select pattern file to load', lastFilename);
if(FileName~=0)
   FileName = strcat(PathName,FileName);
   set(handles.editFilename, 'String', FileName);
   editFilename_Callback([], eventdata, handles);
   % remember pathname for next time
   handles.LastFileName = FileName;
   guidata(hObject, handles);
end   
catch ex
end


function editFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = get(handles.editFilename, 'String');
try
    f = fopen(filename, 'r');
    fclose(f);
catch ex
    errordlg(sprintf('Can''t open %s', filename'));
end


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

function menuClock_Callback(hObject, eventdata, handles)
set(handles.menuNoClock, 'Checked', 'off');
set(handles.menuClock2, 'Checked', 'off');
set(handles.menuClock4, 'Checked', 'off');
set(handles.menuClock8, 'Checked', 'off');
set(handles.menuClock16, 'Checked', 'off');
set(handles.menuClockOnce, 'Checked', 'off');
set(hObject, 'Checked', 'on');
if (hObject ~= handles.menuNoClock)
    chm = get(handles.pushbuttonChannelMapping, 'UserData');
    if (length(find(sum(chm'))) == size(chm,1) && size(chm,1) > 1)
        hMsgBox = msgbox(['In order to generate a clock signal, please un-check at least one channel in the "Download" window. ' ...
                          'The clock signal will be generated on the unchecked channel(s)']);
        pushbuttonChannelMapping_Callback([], [], handles);
        try
            close(hMsgBox);
        catch
        end
    end
end


% --------------------------------------------------------------------
function menuClock2_Callback(hObject, eventdata, handles)
% hObject    handle to menuClock2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuClock4_Callback(hObject, eventdata, handles)
% hObject    handle to menuClock4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuClock8_Callback(hObject, eventdata, handles)
% hObject    handle to menuClock8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuClock16_Callback(hObject, eventdata, handles)
% hObject    handle to menuClock16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuClockOnce_Callback(hObject, eventdata, handles)
% hObject    handle to menuClockOnce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuNoClock_Callback(hObject, eventdata, handles)
% hObject    handle to menuNoClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuClock_Callback(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonPlotConstellation.
function pushbuttonPlotConstellation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlotConstellation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modTypeList = get(handles.popupmenuModType, 'String');
modTypeIdx = get(handles.popupmenuModType, 'Value');
iqmod('modType', modTypeList{modTypeIdx}, 'plotConstellation', 1);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuShowInVSA_Callback(hObject, eventdata, handles)
% hObject    handle to menuShowInVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showInVSA(hObject, eventdata, handles);
