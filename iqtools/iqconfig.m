function varargout = iqconfig(varargin)
% IQCONFIG M-file for iqconfig.fig
%      IQCONFIG, by itself, creates a new IQCONFIG or raises the existing
%      singleton*.
%
%      H = IQCONFIG returns the handle to a new IQCONFIG or the handle to
%      the existing singleton*.
%
%      IQCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQCONFIG.M with the given input arguments.
%
%      IQCONFIG('Property','Value',...) creates a new IQCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iqconfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iqconfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iqconfig

% Last Modified by GUIDE v2.5 08-Jun-2016 10:41:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iqconfig_OpeningFcn, ...
                   'gui_OutputFcn',  @iqconfig_OutputFcn, ...
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


% --- Executes just before iqconfig is made visible.
function iqconfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iqconfig (see VARARGIN)

% Choose default command line output for iqconfig
handles.output = hObject;
set(handles.popupmenuConnectionType, 'Value', 2);

% Update handles structure
guidata(hObject, handles);

arbModels = get(handles.popupmenuModel, 'String');
if (exist('iqdownload_AWG7xxx.m', 'file'))
    arbModels{end+1} = 'AWG7xxx';
    set(handles.popupmenuModel, 'String', arbModels);
end
if (exist('iqdownload_AWG7xxxx.m', 'file'))
    arbModels{end+1} = 'AWG7xxxx';
    set(handles.popupmenuModel, 'String', arbModels);
end
if (exist('iqdownload_M8195A_Rev0.m', 'file') || exist('iqdownload_M8195A_Rev0.p', 'file'))
    arbModels(2:end+1) = arbModels(1:end);
    arbModels{1} = 'M8195A_Rev0';
    set(handles.popupmenuModel, 'String', arbModels);
end

try
    arbCfgFile = iqarbConfigFilename();
catch
    arbCfgFile = 'arbConfig.mat';
end
try
    load(arbCfgFile);
catch e
    % if there is no arbConfig file, assume default values
    arbConfig.model = 'M8190A_12bit';
end
%try
    if (exist('arbConfig', 'var'))
        if (isfield(arbConfig, 'model'))
            idx = find(strcmp(arbModels, arbConfig.model));
            if (isempty(idx) && strcmp(arbConfig.model, 'M8190A'))
                idx = 2;  % special case: M8190A turns into M8190A_14bit
            end
            if (idx > 0)
                set(handles.popupmenuModel, 'Value', idx);
            end
        end
        if (isfield(arbConfig, 'connectionType'))
            connTypes = get(handles.popupmenuConnectionType, 'String');
            idx = find(strcmp(connTypes, arbConfig.connectionType));
            if (idx > 0)
                set(handles.popupmenuConnectionType, 'Value', idx);
            end
            popupmenuConnectionType_Callback([], [], handles);
        end
        if (isfield(arbConfig, 'visaAddr'))
            set(handles.editVisaAddr, 'String', arbConfig.visaAddr);
        end
        if (isfield(arbConfig, 'ip_address'))
            set(handles.editIPAddress, 'String', arbConfig.ip_address);
        end
        if (isfield(arbConfig, 'port'))
            set(handles.editPort, 'String', num2str(arbConfig.port));
        end
        if (isfield(arbConfig, 'skew'))
            set(handles.editSkew, 'String', num2str(arbConfig.skew));
            set(handles.editSkew, 'Enable', 'on');
            set(handles.checkboxSetSkew, 'Value', 1);
        else
            set(handles.editSkew, 'Enable', 'off');
            set(handles.checkboxSetSkew, 'Value', 0);
        end
        if (isfield(arbConfig, 'gainCorrection'))
            set(handles.editGainCorr, 'String', num2str(arbConfig.gainCorrection));
            set(handles.editGainCorr, 'Enable', 'on');
            set(handles.checkboxSetGainCorr, 'Value', 1);
        else
            set(handles.editGainCorr, 'Enable', 'off');
            set(handles.checkboxSetGainCorr, 'Value', 0);
        end
        s = 1;  % use continuous as default
        if (isfield(arbConfig, 'triggerMode'))
            s = find(strcmp(get(handles.popupmenuTrigger, 'String'), arbConfig.triggerMode));
            if (s == 0)
                s = 1;
            end
        end
        set(handles.popupmenuTrigger, 'Value', s);
        if (isfield(arbConfig, 'amplitude'))
            set(handles.editAmpl, 'String', iqengprintf(arbConfig.amplitude));
            set(handles.checkboxSetAmpl, 'Value', 1);
        else
            set(handles.checkboxSetAmpl, 'Value', 0);
        end
        if (isfield(arbConfig, 'offset'))
            set(handles.editOffs, 'String', iqengprintf(arbConfig.offset));
            set(handles.checkboxSetOffs, 'Value', 1);
        else
            set(handles.checkboxSetOffs, 'Value', 0);
        end
        if (isfield(arbConfig, 'ampType'))
            ampTypes = get(handles.popupmenuAmpType, 'String');
            idx = find(strcmp(ampTypes, arbConfig.ampType));
            if (idx > 0)
                set(handles.popupmenuAmpType, 'Value', idx);
            end
            set(handles.checkboxSetAmpType, 'Value', 1);
        else
            set(handles.checkboxSetAmpType, 'Value', 0);
        end
        if (isfield(arbConfig, 'clockSource'))
            clkSourceList = {'Unchanged', 'IntRef', 'AxieRef', 'ExtRef', 'ExtClk'};
            idx = find(strcmpi(clkSourceList, arbConfig.clockSource));
            if (idx >= 1 && idx <= length(get(handles.popupmenuClockSource, 'String')))
                set(handles.popupmenuClockSource, 'Value', idx);
            end
            popupmenuClockSource_Callback([], [], handles);
        elseif (isfield(arbConfig, 'extClk') && arbConfig.extClk) % legacy: extClk used to be a separate field
            set(handles.popupmenuClockSource, 'Value', 4);
            popupmenuClockSource_Callback([], [], handles);
        end
        if (isfield(arbConfig, 'clockFreq'))
            set(handles.editClockFreq, 'String', iqengprintf(arbConfig.clockFreq));
        end
        set(handles.checkboxRST, 'Value', (isfield(arbConfig, 'do_rst') && arbConfig.do_rst));
        set(handles.checkboxInterleaving, 'Value', (isfield(arbConfig, 'interleaving') && arbConfig.interleaving));
        if (isfield(arbConfig, 'defaultFc'))
            set(handles.editDefaultFc, 'String', iqengprintf(arbConfig.defaultFc));
        end
        tooltips = 1;
        if (isfield(arbConfig, 'tooltips') && arbConfig.tooltips == 0)
            tooltips = 0;
        end
        set(handles.checkboxTooltips, 'Value', tooltips);
        if (isfield(arbConfig, 'amplScale'))
            set(handles.editAmplScale, 'String', iqengprintf(arbConfig.amplScale));
        end
        if (isfield(arbConfig, 'amplScaleMode'))
            amplScaleModes = get(handles.popupmenuAmplScale, 'String');
            idx = find(strcmp(amplScaleModes, arbConfig.amplScaleMode));
            if (idx > 0)
                set(handles.popupmenuAmplScale, 'Value', idx);
            end
            popupmenuAmplScale_Callback([], [], handles);
        end
        if (isfield(arbConfig, 'DACRange'))
            set(handles.editDACRange, 'String', iqengprintf(round(1000 * arbConfig.DACRange)/10));
        end
        if (isfield(arbConfig, 'carrierFrequency'))
            set(handles.editCarrierFreq, 'String', iqengprintf(arbConfig.carrierFrequency));
            set(handles.checkboxSetCarrierFreq, 'Value', 1);
        else
            set(handles.textCarrierFreq, 'Enable', 'off');
            set(handles.editCarrierFreq, 'Enable', 'off');
            set(handles.checkboxSetCarrierFreq, 'Value', 0);
        end
        if (isfield(arbConfig, 'peaking'))
            set(handles.editPeaking, 'String', sprintf('%d', arbConfig.peaking));
        end
        if (isfield(arbConfig, 'M8195Acorrection'))
            set(handles.checkboxM8195Acorr, 'Value', arbConfig.M8195Acorrection)
        end
        popupmenuModel_Callback([], [], handles);
        if (isfield(arbConfig, 'visaAddr2'))
            set(handles.checkboxVisaAddr2, 'Value', 1);
            set(handles.editVisaAddr2, 'String', arbConfig.visaAddr2);
            set(handles.editVisaAddr2, 'Enable', 'on');
            set(handles.pushbuttonTestAWG2, 'Enable', 'on');
            set(handles.pushbuttonSwapAWG, 'Enable', 'on');
        else
            set(handles.checkboxVisaAddr2, 'Value', 0);
            set(handles.editVisaAddr2, 'Enable', 'off');
            set(handles.pushbuttonTestAWG2, 'Enable', 'off');
            set(handles.pushbuttonSwapAWG, 'Enable', 'off');
        end
        %--- M8192A
        if (isfield(arbConfig, 'visaAddrM8192A'))
            set(handles.editVisaAddrM8192A, 'String', arbConfig.visaAddrM8192A);
            if (isfield(arbConfig, 'useM8192A') && (arbConfig.useM8192A ~= 0))
                set(handles.checkboxVisaAddrM8192A, 'Value', 1);
                set(handles.editVisaAddrM8192A, 'Enable', 'on');
                set(handles.pushbuttonTestM8192A, 'Enable', 'on');
            else
                set(handles.checkboxVisaAddrM8192A, 'Value', 0);
                set(handles.editVisaAddrM8192A, 'Enable', 'off');
                set(handles.pushbuttonTestM8192A, 'Enable', 'off');
            end
        end
        %--- Scope
        if (isfield(arbConfig, 'visaAddrScope'))
            set(handles.editVisaAddrScope, 'String', arbConfig.visaAddrScope);
            if (~isfield(arbConfig, 'isScopeConnected') || (isfield(arbConfig, 'isScopeConnected') && arbConfig.isScopeConnected ~= 0))
                set(handles.checkboxVisaAddrScope, 'Value', 1);
                set(handles.editVisaAddrScope, 'Enable', 'on');
                set(handles.pushbuttonTestScope, 'Enable', 'on');
            else
                set(handles.checkboxVisaAddrScope, 'Value', 0);
                set(handles.editVisaAddrScope, 'Enable', 'off');
                set(handles.pushbuttonTestScope, 'Enable', 'off');
            end
        end
        %--- VSA
        if (isfield(arbConfig, 'visaAddrVSA'))
            set(handles.editVisaAddrVSA, 'String', arbConfig.visaAddrVSA);
            if (~isfield(arbConfig, 'isVSAConnected') || (isfield(arbConfig, 'isVSAConnected') && arbConfig.isVSAConnected ~= 0))
                set(handles.checkboxRemoteVSA, 'Value', 1);
                set(handles.editVisaAddrVSA, 'Enable', 'on');
                set(handles.pushbuttonTestVSA, 'Enable', 'on');
            else
                set(handles.checkboxRemoteVSA, 'Value', 0);
                set(handles.editVisaAddrVSA, 'Enable', 'off');
                set(handles.pushbuttonTestVSA, 'Enable', 'off');
            end
        end
        %--- DCA
        if (isfield(arbConfig, 'visaAddrDCA'))
            set(handles.editVisaAddrDCA, 'String', arbConfig.visaAddrDCA);
            if (~isfield(arbConfig, 'isDCAConnected') || (isfield(arbConfig, 'isDCAConnected') && arbConfig.isDCAConnected ~= 0))
                set(handles.checkboxDCA, 'Value', 1);
                set(handles.editVisaAddrDCA, 'Enable', 'on');
                set(handles.pushbuttonTestDCA, 'Enable', 'on');
            else
                set(handles.checkboxDCA, 'Value', 0);
                set(handles.editVisaAddrDCA, 'Enable', 'off');
                set(handles.pushbuttonTestDCA, 'Enable', 'off');
            end
        end
        guidata(hObject, handles);
    end
    % spectrum analyzer
    if (exist('saConfig', 'var'))
        if (isfield(saConfig, 'connected'))
            set(handles.checkboxSAattached, 'Value', saConfig.connected);
        end
        checkboxSAattached_Callback([], [], handles);
        if (isfield(saConfig, 'visaAddr'))
            set(handles.editVisaAddrSA, 'String', saConfig.visaAddr);
        end
    end
%catch e
%    errordlg(e.message);
%end

if (~exist('arbConfig', 'var') || ~isfield(arbConfig, 'tooltips') || arbConfig.tooltips == 1)
set(handles.popupmenuModel, 'TooltipString', sprintf([ ...
    'Select the instrument model. For M8190A, you have to select in which\n', ...
    'mode the AWG will operate because the maximum sample rate and segment\n', ...
    'granularity are different for each mode. The "DUC" (digital upconversion)\n' ...
    'modes require a separate software license']));
set(handles.popupmenuConnectionType, 'TooltipString', sprintf([ ...
    'Use ''visa'' for connections through the VISA library.\n'...
    'Use ''tcpip'' for direct socket connections.\n' ...
    'For the 81180A ''tcpip'' is recommended. For the M8190A,\n' ...
    'a ''visa'' connection using the hislip protocol is recommended']));
set(handles.editVisaAddr, 'TooltipString', sprintf([ ...
    'Enter the VISA address as given in the Keysight Connection Expert.\n' ...
    'Examples:  TCPIP0::134.40.175.228::inst0::INSTR\n' ...
    '           TCPIP0::localhost::hislip0::INSTR\n' ...
    '           GPIB0::18::INSTR\n' ...
    'Note, that the M8190A and M8195A can ONLY be connected through TCPIP.\n' ...
    'Do NOT attempt to connect via the PXIxx:x:x address.']));
set(handles.editIPAddress, 'TooltipString', sprintf([ ...
    'Enter the numeric IP address or hostname. For connection to the same\n' ...
    'PC, use ''localhost'' or 127.0.0.1']));
set(handles.editPort, 'TooltipString', sprintf([ ...
    'Specify the IP Port number for tcpip connection. Usually this is 5025.']));
set(handles.checkboxSetSkew, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the skew between I and Q\n' ...
    '(i.e. channel 1 and channel 2). If unchecked, the skew will remain unchanged.\n' ...
    'In case of the M8195A, the skew is used to delay the I waveform mathematically.']));
set(handles.editSkew, 'TooltipString', sprintf([ ...
    'Enter the skew between I and Q (i.e. channel 1 and 2) in units of seconds.\n' ...
    'Positive values will delay ch1 vs. ch2, negative values do the opposite.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetGainCorr, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to apply gain correction between I and Q.\n' ...
    'If unchecked, the waveforms will be downloaded unchanged. In case of the M8195A,\n' ...
    'the gain correction is used to modify the I waveform mathematically.']));
set(handles.editGainCorr, 'TooltipString', sprintf([ ...
    'Enter the gain correction between I and Q in units of dB.\n' ...
    'Positive values will boost I vs. Q, negative values do the opposite.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetAmpl, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the amplitude.\n' ...
    'If unchecked, the previously configured amplitude will remain unchanged']));
set(handles.editAmpl, 'TooltipString', sprintf([ ...
    'Enter the single ended amplitude Volts. If you enter a single value, that value will' ...
    'be used for all channels. If you enter multiple values separated by space, comma' ...
    'or semicolon, the first value will be used for ch1, the second for ch2 and so on.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetOffs, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the common mode offset.\n' ...
    'If unchecked, the previously configured offset will remain unchanged']));
set(handles.editOffs, 'TooltipString', sprintf([ ...
    'Enter the common mode offset. If you enter a single value, that value will be' ...
    'used for all channels. If you enter multiple values separated by space, comma' ...
    'or semicolon, the first value will be used for ch1, the second for ch2 and so on.' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxSetAmpType, 'TooltipString', sprintf([ ...
    'Check this box if you want the script to set the amplifier type.' ...
    'If unchecked, the previously configured amplifier type will remain unchanged.']));
set(handles.popupmenuAmpType, 'TooltipString', sprintf([ ...
    'Select the type of output amplifier you want to use. ''DAC'' is the direct output\n'...
    'from the DAC, which typically has the best signal performance, but limited\n' ...
    'amplitude/offset range. Note, that only some AWGs have switchable amplifiers:\n' ...
    '81180A, M8190A_12bit and M8190A_14bit']));
set(handles.popupmenuClockSource, 'TooltipString', sprintf([ ...
    'Select the sample clock resp. reference clock source for the AWG.\n' ...
    'When you select external sample clock or external reference clock, you must\n' ...
    'also specify the frequency of the input signal. Make sure that you have connected \n' ...
    'a clock signal to the external input before turning this function on. Also, when \n' ...
    'using external sample clock, make sure that you specify the external clock\n' ...
    'frequency in the "sample rate" field of the waveform generation utilities.\n' ...
    'Changes in the hardware will be made upon the next download of a waveform.']));
set(handles.checkboxRST, 'TooltipString', sprintf([ ...
    'Check this box if you want to reset the AWG prior to downloading a new waveform.\n' ...
    'Do not check this checkbox if you plan to use multiple segments or sequence mode.']));
set(handles.checkboxSAattached, 'TooltipString', sprintf([ ...
    'Check this box if you have a spectrum analyzer (PSA, MXA, PXA) connected\n' ...
    'and would like to use it for amplitude flatness correction']));
set(handles.editVisaAddrSA, 'TooltipString', sprintf([ ...
    'Enter the VISA address of the SA as given in the Keysight Connection Expert.\n' ...
    'Examples:  TCPIP0::134.40.175.228::inst0::INSTR\n' ...
    '           GPIB0::18::INSTR']));
% set(handles.popupmenuSAAlgorithm, 'TooltipString', sprintf([ ...
%     'Select the algorithm to use for amplitude correction on the SA.\n'...
%     '''Zero span'' is the preferred method. It works reliable and is\n' ...
%     'the most accurate. ''List sweep'' is only possible with MXA and PXA.\n' ...
%     'It works a little faster than zero span, but is not as accurate.\n' ...
%     '''Marker'' only works reliable if the resolution BW on the SA is set\n' ...
%     'wide enough. It is not recommended in the general case.']));
set(handles.checkboxTooltips, 'TooltipString', sprintf([ ...
    'Enable/disable tooltips throughout the ''iqtools''.']));
set(handles.editDefaultFc, 'TooltipString', sprintf([ ...
    'If you are using the AWG with external upconversion, enter the\n' ...
    'LO frequency here. This value will be used in the multi-tone and\n' ...
    'digital modulation scripts to set the default center frequency.']));
set(handles.editDACRange, 'TooltipString', sprintf([ ...
    'Set this to 100 to use the DAC to full range. Values less than 100\n' ...
    'cause the waveform to be scaled to the given ratio and use less\n' ...
    'than the full scale DAC.']));
set(handles.editAmplScale, 'TooltipString', sprintf([ ...
    'In M8190A DUC mode, this parameter determines the amplitude scaling\n' ...
    'after interpolation and up-conversion. Valid range is from 1 to 2.83.\n' ...
    'Ideally, select the largest value you can without getting distortions.\n' ...
    '(See M8190A user guide for more information)']));
set(handles.checkboxInterleaving, 'TooltipString', sprintf([ ...
    'Check this checkbox to distribute even and odd samples to both\n' ...
    'channels. This can be used to virtually double the sample rate\n' ...
    'of the AWG. You have to manually adjust the delay of channel 2\n' ...
    'to one half of a sample period.']));
set(handles.checkboxM8195Acorr, 'TooltipString', sprintf([ ...
    'Check this checkbox to apply the M8195A built-in frequency and\n' ...
    'phase response correction to each channel when downloading waveforms.\n' ...
    'You will probably have to reduce the "DAC range" to avoid clipping\n' ...
    'of DAC values. If clipping occurs, an error message will tell you\n' ...
    'to which value the "DAC range" has to be set']));
set(handles.editPeaking, 'TooltipString', sprintf([ ...
    'The amount of peaking for the M8196A amplifier can be adjusted.\n' ...
    'Positive values increase the peaking (i.e. higher gain at high frequencies)\n' ...
    'The values are unit-less. An increments of 1000 corresponds to approx. 1 dB\n' ...
    'gain at 30 GHz. Try a value of 2000 or 3000 for a noticable effect']));
end

% UIWAIT makes iqconfig wait for user response (see UIRESUME)
% uiwait(handles.iqtool);


% --- Outputs from this function are returned to the command line.
function varargout = iqconfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editIPAddress_Callback(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIPAddress as text
%        str2double(get(hObject,'String')) returns contents of editIPAddress as a double


% --- Executes during object creation, after setting all properties.
function editIPAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIPAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPort_Callback(hObject, eventdata, handles)
% hObject    handle to editPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPort as text
%        str2double(get(hObject,'String')) returns contents of editPort as a double


% --- Executes during object creation, after setting all properties.
function editPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSkew_Callback(hObject, eventdata, handles)
% hObject    handle to editSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSkew as text
%        str2double(get(hObject,'String')) returns contents of editSkew as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editSkew_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAmpl_Callback(hObject, eventdata, handles)
% hObject    handle to editAmpl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmpl as text
%        str2double(get(hObject,'String')) returns contents of editAmpl as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editAmpl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmpl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editOffs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuConnectionType.
function popupmenuConnectionType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuConnectionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuConnectionType
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
set(handles.pushbuttonTestAWG1, 'Background', [.9 .9 .9]);
switch (connType)
    case 'tcpip'
        set(handles.editVisaAddr, 'Enable', 'off');
        set(handles.editIPAddress, 'Enable', 'on');
        set(handles.editPort, 'Enable', 'on');
    case 'visa'
        set(handles.editVisaAddr, 'Enable', 'on');
        set(handles.editIPAddress, 'Enable', 'off');
        set(handles.editPort, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupmenuConnectionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetSkew.
function checkboxSetSkew_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetSkew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetSkew
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editSkew, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxSetAmpl.
function checkboxSetAmpl_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetAmpl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetAmpl
val = get(handles.checkboxSetAmpl,'Value');
onoff = {'off' 'on'};
set(handles.editAmpl, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxSetAmpType.
function checkboxSetAmpType_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetAmpType
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.popupmenuAmpType, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkVisaAddr(handles);
[arbConfig saConfig] = makeArbConfig(handles);
try
    arbCfgFile = iqarbConfigFilename();
catch
    arbCfgFile = 'arbConfig.mat';
end
try
    save(arbCfgFile, 'arbConfig', 'saConfig');
    notifyIQToolWindows(handles);
    close(handles.output);
catch
    msgbox(sprintf('Can''t write "%s". Please make sure the file is writeable.', arbCfgFile));
end


% --- Executes on selection change in popupmenuAmpType.
function popupmenuAmpType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAmpType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAmpType
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuAmpType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAmpType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [arbConfig saConfig] = makeArbConfig(handles)
% retrieve all the field values
clear arbConfig;
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
arbConfig.model = arbModel;
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
arbConfig.connectionType = connType;
arbConfig.visaAddr = strtrim(get(handles.editVisaAddr, 'String'));
arbConfig.ip_address = get(handles.editIPAddress, 'String');
arbConfig.port = evalin('base', get(handles.editPort, 'String'));
arbConfig.defaultFc = evalin('base', get(handles.editDefaultFc, 'String'));
arbConfig.tooltips = get(handles.checkboxTooltips, 'Value');
arbConfig.DACRange = evalin('base', get(handles.editDACRange, 'String')) / 100;
arbConfig.amplScale = evalin('base', get(handles.editAmplScale, 'String'));
amplScaleList = cellstr(get(handles.popupmenuAmplScale, 'String'));
amplScaleMode = amplScaleList{get(handles.popupmenuAmplScale, 'Value')};
arbConfig.amplScaleMode = amplScaleMode;
if (get(handles.checkboxSetCarrierFreq, 'Value'))
    arbConfig.carrierFrequency = evalin('base', get(handles.editCarrierFreq, 'String'));
end
if (get(handles.checkboxSetSkew, 'Value'))
    arbConfig.skew = evalin('base', get(handles.editSkew, 'String'));
end
if (get(handles.checkboxSetGainCorr, 'Value'))
    arbConfig.gainCorrection = evalin('base', get(handles.editGainCorr, 'String'));
end
trigList = get(handles.popupmenuTrigger, 'String');
trigVal = trigList{get(handles.popupmenuTrigger, 'Value')};
arbConfig.triggerMode = trigVal;
if (get(handles.checkboxSetAmpl, 'Value'))
    arbConfig.amplitude = evalin('base', ['[' get(handles.editAmpl, 'String') ']']);
end
if (get(handles.checkboxSetOffs, 'Value'))
    arbConfig.offset = evalin('base', ['[' get(handles.editOffs, 'String') ']']);
end
if (get(handles.checkboxSetAmpType, 'Value'))
    ampTypes = cellstr(get(handles.popupmenuAmpType, 'String'));
    ampType = ampTypes{get(handles.popupmenuAmpType, 'Value')};
    arbConfig.ampType = ampType;
end
if (get(handles.checkboxRST, 'Value'))
    arbConfig.do_rst = true;
end
clkSourceList = {'Unchanged', 'IntRef', 'AxieRef', 'ExtRef', 'ExtClk'};
clkSourceIdx = get(handles.popupmenuClockSource, 'Value');
arbConfig.clockSource = clkSourceList{clkSourceIdx};
arbConfig.clockFreq = evalin('base', get(handles.editClockFreq, 'String'));
arbConfig.peaking = evalin('base', get(handles.editPeaking, 'String'));
if (get(handles.checkboxInterleaving, 'Value'))
    arbConfig.interleaving = true;
end
if (get(handles.checkboxVisaAddr2, 'Value'))
    arbConfig.visaAddr2 = strtrim(get(handles.editVisaAddr2, 'String'));
end
if (get(handles.checkboxVisaAddrM8192A, 'Value'))
    arbConfig.useM8192A = 1;
else
    arbConfig.useM8192A = 0;
end
arbConfig.visaAddrM8192A = strtrim(get(handles.editVisaAddrM8192A, 'String'));
arbConfig.isScopeConnected = get(handles.checkboxVisaAddrScope, 'Value');
arbConfig.visaAddrScope = strtrim(get(handles.editVisaAddrScope, 'String'));
arbConfig.isVSAConnected = get(handles.checkboxRemoteVSA, 'Value');
arbConfig.visaAddrVSA = strtrim(get(handles.editVisaAddrVSA, 'String'));
arbConfig.isDCAConnected = get(handles.checkboxDCA, 'Value');
arbConfig.visaAddrDCA = strtrim(get(handles.editVisaAddrDCA, 'String'));
if (get(handles.checkboxM8195Acorr, 'Value'))
    arbConfig.M8195Acorrection = 1;
end
% spectrum analyzer connections
clear saConfig;
saConfig.connected = get(handles.checkboxSAattached, 'Value');
saConfig.connectionType = 'visa';
saConfig.visaAddr = get(handles.editVisaAddrSA, 'String');
% saAlgoIdx = get(handles.popupmenuSAAlgorithm, 'Value');
% switch (saAlgoIdx)
%     case 1 % zero span
%         saConfig.useListSweep = 0;
%         saConfig.useMarker = 0;
%     case 2 % marker
%         saConfig.useListSweep = 0;
%         saConfig.useMarker = 1;
%     case 3 % list sweep
%         saConfig.useListSweep = 1;
%         saConfig.useMarker = 0;
% end


function notifyIQToolWindows(handles)
% Notify all open iqtool utilities that arbConfig has changed 
% Figure windows are recognized by their "iqtool" tag
try
    TempHide = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    figs = findobj(0, 'Type', 'figure', 'Tag', 'iqtool');
    set(0, 'ShowHiddenHandles', TempHide);
    for i = 1:length(figs)
        fig = figs(i);
        [path file ext] = fileparts(get(fig, 'Filename'));
        handles = guihandles(fig);
        feval(file, 'checkfields', fig, 'red', handles);
    end
catch ex
    errordlg({ex.message, [ex.stack(1).name ', line ' num2str(ex.stack(1).line)]});
end


function editVisaAddr_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddr as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddr as a double
checkVisaAddr(handles);


% --- Executes during object creation, after setting all properties.
function editVisaAddr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkboxSAattached.
function checkboxSAattached_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSAattached (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxSAattached
saConnected = get(handles.checkboxSAattached, 'Value');
if (~saConnected)
    set(handles.editVisaAddrSA, 'Enable', 'off');
    set(handles.pushbuttonTestSA, 'Enable', 'off');
    set(handles.pushbuttonTestSA, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrSA, 'Enable', 'on');
    set(handles.pushbuttonTestSA, 'Enable', 'on');
end


function editVisaAddrSA_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrSA as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrSA as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrSA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuModel.
function popupmenuModel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuModel
onoff = {'off' 'on'};
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
% we don't use global frequency/phase correction any more
set(handles.checkboxM8195Acorr, 'Visible', 'off');
set(handles.checkboxM8195Acorr, 'Value', 0);
% show peaking only for M8196A
isM8196A = ~isempty(strfind(arbModel, 'M8196A'));
set(handles.textPeaking, 'Visible', onoff{1 + isM8196A});
set(handles.editPeaking, 'Visible', onoff{1 + isM8196A});
% show M8190A DUC controls only when they are relevant
showDUC = ~isempty(strfind(arbModel, 'DUC'));
set(handles.textAmplScale, 'Visible', onoff{1 + showDUC});
set(handles.popupmenuAmplScale, 'Visible', onoff{1 + showDUC});
set(handles.editAmplScale, 'Visible', onoff{1 + showDUC});
set(handles.textCarrierFreq, 'Visible', onoff{1 + showDUC});
set(handles.editCarrierFreq, 'Visible', onoff{1 + showDUC});
set(handles.checkboxSetCarrierFreq, 'Visible', onoff{1 + showDUC});
% fields that are only available for M8190A DUC mode
if (showDUC)
    set(handles.textCarrierFreq, 'Enable', 'on');
    set(handles.checkboxSetCarrierFreq, 'Enable', 'on');
    checkboxSetCarrierFreq_Callback(hObject, eventdata, handles);
else
    set(handles.textCarrierFreq, 'Enable', 'off');
    set(handles.editCarrierFreq, 'Enable', 'off');
    set(handles.checkboxSetCarrierFreq, 'Enable', 'off');
end
% M8195A_Rev0 does not use VISA addressing
if (~isempty(strfind(arbModel, 'M8195A_Rev0')))
    set(handles.editVisaAddr, 'Enable', 'off');
    set(handles.editIPAddress, 'Enable', 'off');
    set(handles.editPort, 'Enable', 'off');
    set(handles.popupmenuConnectionType, 'Enable', 'off');
else
    set(handles.popupmenuConnectionType, 'Enable', 'on');
    popupmenuConnectionType_Callback(hObject, eventdata, handles);
end
% trigger, interleaving, ext ref clk are only implemented for M8190A and
% M8195A Rev. 2
if (~isempty(strfind(arbModel, 'M8190A')) || ...
    (~isempty(strfind(arbModel, 'M8195A')) && isempty(strfind(arbModel, 'M8195A_Rev1')) && isempty(strfind(arbModel, 'M8195A_Rev0'))))
    set(handles.popupmenuTrigger, 'Enable', 'on');
    set(handles.textTrigger, 'Enable', 'on');
    set(handles.checkboxInterleaving, 'Enable', 'on');
    set(handles.textInterleaving, 'Enable', 'on');
    set(handles.popupmenuClockSource, 'Enable', 'on');
    set(handles.textClockSource, 'Enable', 'on');
else
    set(handles.popupmenuTrigger, 'Enable', 'off');
    set(handles.textTrigger, 'Enable', 'off');
    set(handles.checkboxInterleaving, 'Enable', 'off');
    set(handles.textInterleaving, 'Enable', 'off');
    set(handles.popupmenuClockSource, 'Enable', 'off');
    set(handles.textClockSource, 'Enable', 'off');
end
% RST is only implemented for M8190A, M8195A and 81180A/B
if ((~isempty(strfind(arbModel, 'M8195A'))) || ...
    (~isempty(strfind(arbModel, 'M8190A'))) || ...
    (~isempty(strfind(arbModel, '81180'))))
    set(handles.checkboxRST, 'Enable', 'on');
    set(handles.textRST, 'Enable', 'on');
else
    set(handles.checkboxRST, 'Enable', 'off');
    set(handles.textRST, 'Enable', 'off');
end
% amplifier type only for M8190A and 81180A/B
if ((~isempty(strfind(arbModel, 'M8190A')) || ~isempty(strfind(arbModel, '81180'))))
    set(handles.checkboxSetAmpType, 'Enable', 'on');
    if (get(handles.checkboxSetAmpType, 'Value'))
        set(handles.popupmenuAmpType, 'Enable', 'on');
        set(handles.textAmpType, 'Enable', 'on');
    else
        set(handles.popupmenuAmpType, 'Enable', 'off');
        set(handles.textAmpType, 'Enable', 'off');
    end
else
    set(handles.checkboxSetAmpType, 'Enable', 'off');
    set(handles.popupmenuAmpType, 'Enable', 'off');
    set(handles.textAmpType, 'Enable', 'off');
end
% amplitude/offset for M8196A, M8195A, M8190A, 81180A, 81150A, 81160A, 33xxx
if (~isempty(strfind(arbModel, 'M8196A')) || ...
    ~isempty(strfind(arbModel, 'M8195A')) || ...
    ~isempty(strfind(arbModel, 'M8190A')) || ~isempty(strfind(arbModel, '81180')) || ...
    ~isempty(strfind(arbModel, '335')) || ~isempty(strfind(arbModel, '336')) || ...
    ~isempty(strfind(arbModel, '81150A')) || ~isempty(strfind(arbModel, '81160A')))
    set(handles.checkboxSetAmpl, 'Enable', 'on');
    set(handles.textAmpl, 'Enable', 'on');
    set(handles.checkboxSetOffs, 'Enable', 'on');
    set(handles.textOffset, 'Enable', 'on');
    val = get(handles.checkboxSetAmpl,'Value');
    onoff = {'off' 'on'};
    set(handles.editAmpl, 'Enable', onoff{val+1});
    val = get(handles.checkboxSetOffs,'Value');
    set(handles.editOffs, 'Enable', onoff{val+1});
else
    set(handles.checkboxSetAmpl, 'Enable', 'off');
    set(handles.textAmpl, 'Enable', 'off');
    set(handles.checkboxSetOffs, 'Enable', 'off');
    set(handles.textOffset, 'Enable', 'off');
end
popupmenuAmplScale_Callback([], [], handles);
% skew and gain generally available only for M819x and 811xx
if (~isempty(strfind(arbModel, 'M819')) || ~isempty(strfind(arbModel, '811')) || ...
        ~isempty(strfind(arbModel, 'AWG7')))
    set(handles.checkboxSetSkew, 'Enable', 'on');
    set(handles.checkboxSetGainCorr, 'Enable', 'on');
    set(handles.textSkew, 'Enable', 'on');
    set(handles.textGainCorr, 'Enable', 'on');
else
    set(handles.checkboxSetSkew, 'Enable', 'off');
    set(handles.checkboxSetGainCorr, 'Enable', 'off');
    set(handles.textSkew, 'Enable', 'off');
    set(handles.textGainCorr, 'Enable', 'off');
end
% skew has a different meaning in M8195A
if (~isempty(strfind(arbModel, 'M8195')))
    set(handles.textSkew, 'String', 'Skew (I vs. Q)');
else
    set(handles.textSkew, 'String', 'Skew (Ch1 vs Ch2)');
end
% Second M8190A and Sync module are only available with M8190A, otherwise
% DCA panel is visible
if (~isempty(strfind(arbModel, 'M8190A')))
    set(handles.uipanelM8192A, 'Visible', 'on');
    set(handles.uipanelSecondM8190A, 'Visible', 'on');
    set(handles.uipanelDCA, 'Visible', 'off');
else
    set(handles.uipanelM8192A, 'Visible', 'off');
    set(handles.uipanelSecondM8190A, 'Visible', 'off');
    pos = get(handles.uipanelSecondM8190A, 'Position');
    set(handles.uipanelDCA, 'Position', pos);
    set(handles.uipanelDCA, 'Visible', 'on');
end
checkVisaAddr(handles);
checkboxSAattached_Callback([], [], handles);


% --- Executes during object creation, after setting all properties.
function popupmenuModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editOffs_Callback(hObject, eventdata, handles)
% hObject    handle to editOffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOffs as text
%        str2double(get(hObject,'String')) returns contents of editOffs as a double
paramChangedNote(handles);



% --- Executes on button press in checkboxSetOffs.
function checkboxSetOffs_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetOffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.checkboxSetOffs,'Value');
onoff = {'off' 'on'};
set(handles.editOffs, 'Enable', onoff{val+1});
paramChangedNote(handles);


% --- Executes on button press in checkboxRST.
function checkboxRST_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRST
paramChangedNote(handles);


function editDefaultFc_Callback(hObject, eventdata, handles)
% hObject    handle to editDefaultFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDefaultFc as text
%        str2double(get(hObject,'String')) returns contents of editDefaultFc as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 0)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editDefaultFc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDefaultFc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxTooltips.
function checkboxTooltips_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxTooltips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTooltips



function editDACRange_Callback(hObject, eventdata, handles)
% hObject    handle to editDACRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDACRange as text
%        str2double(get(hObject,'String')) returns contents of editDACRange as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value <= 100 && value >= 0)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editDACRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDACRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqloadsettings(handles);
popupmenuModel_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqsavesettings(handles);


% --- Executes on button press in checkboxInterleaving.
function checkboxInterleaving_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxInterleaving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxInterleaving
if (get(hObject,'Value'))
    msgbox({'Please use the GUI or Soft Front Panel of the AWG to adjust' ...
            'channel 2 to be delayed by 1/2 sample period with respect to' ...
            'channel 1. An easy way to check the correct delay is to generate' ...
            'a multitone signal with tones between DC and fs/4, observe the' ...
            'signal on a spectrum analyzer and adjust the channel 2 delay' ...
            'until the images in the second Nyquist band are minimial.'}, 'Note');
end



function editCarrierFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCarrierFreq as text
%        str2double(get(hObject,'String')) returns contents of editCarrierFreq as a double
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function editCarrierFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetCarrierFreq.
function checkboxSetCarrierFreq_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetCarrierFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxSetCarrierFreq
val = get(handles.checkboxSetCarrierFreq, 'Value');
onoff = {'off' 'on'};
set(handles.editCarrierFreq, 'Enable', onoff{val+1});
%paramChangedNote(handles);


function paramChangedNote(handles)
% at least one parameter has changed --> notify user that the change will
% only be sent to hardware on the next waveform download
set(handles.textNote, 'Background', 'yellow');


function checkVisaAddr(handles)
visaAddr = upper(strtrim(get(handles.editVisaAddr, 'String')));
connTypes = cellstr(get(handles.popupmenuConnectionType, 'String'));
connType = connTypes{get(handles.popupmenuConnectionType, 'Value')};
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
if (~isempty(strfind(arbModel, 'M819')) && ...
    strcmpi(connType, 'visa') && ...
    isempty(strfind(visaAddr, 'TCPIP')))
    msgbox({'For M8190A and M8195A, you have to use a VISA address that starts' ...
            'with "TCPIP". You can find the correct VISA address for the M8190A' ...
            'in the firmware window. For the M8195A, please check the "Help->About" window'}, 'replace');
end


% --- Executes on button press in checkboxVisaAddrScope.
function checkboxVisaAddrScope_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddrScope
scopeConnected = get(handles.checkboxVisaAddrScope, 'Value');
if (~scopeConnected)
    set(handles.editVisaAddrScope, 'Enable', 'off');
    set(handles.pushbuttonTestScope, 'Enable', 'off');
    set(handles.pushbuttonTestScope, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrScope, 'Enable', 'on');
    set(handles.pushbuttonTestScope, 'Enable', 'on');
end



function editVisaAddrScope_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrScope as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrScope as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrScope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxVisaAddr2.
function checkboxVisaAddr2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddr2
awg2Connected = get(handles.checkboxVisaAddr2, 'Value');
if (~awg2Connected)
    set(handles.editVisaAddr2, 'Enable', 'off');
    set(handles.pushbuttonTestAWG2, 'Enable', 'off');
    set(handles.pushbuttonTestAWG2, 'Background', [.9 .9 .9]);
    set(handles.pushbuttonSwapAWG, 'Enable', 'off');
else
    set(handles.editVisaAddr2, 'Enable', 'on');
    set(handles.pushbuttonSwapAWG, 'Enable', 'on');
    set(handles.pushbuttonTestAWG2, 'Enable', 'on');
    % try to guess the address for the slave AWG if it has never been set
    if (~isempty(strfind(get(handles.editVisaAddr2, 'String'), 'Enter')))
        addr = get(handles.editVisaAddr, 'String');
        addr2 = regexprep(addr, '::inst([0-9]*)', '::inst${num2str(str2double($1)+1)}');
        addr2 = regexprep(addr2, '::hislip([0-9]*)', '::hislip${num2str(str2double($1)+1)}');
        addr2 = regexprep(addr2, '::([0-9]*)::', '::${num2str(str2double($1)+1)}::');
        set(handles.editVisaAddr2, 'String', addr2);
    end
end


function editVisaAddr2_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddr2 as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddr2 as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTestScope.
function pushbuttonTestScope_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scopeCfg.connectionType = 'visa';
scopeCfg.visaAddr = get(handles.editVisaAddrScope, 'String');
if (~isempty(strfind(scopeCfg.visaAddr, 'Enter VISA')))
    errordlg({'Please enter a valid VISA Address for the Scope. Typically something' ...
        'like: TCPIP0::ComputerName::inst0::INSTR.  You can find the correct' ...
        'address on the scope under Utilities -> Remote Connection'});
    return;
end
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
instrreset();
f = iqopen(scopeCfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, 'DSO')) || ...
            ~isempty(strfind(res, 'DSA')) || ...
            ~isempty(strfind(res, 'MSO')))
            found = 1;
        else
            errordlg({'Unexpected scope model:' '' res ...
                'Supported models are DSO, DSA or MSO'});
        end
    catch ex
        errordlg({'Error reading scope IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


% --- Executes on button press in pushbuttonTestAWG2.
function pushbuttonTestAWG2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestAWG2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[cfg dummy] = makeArbConfig(handles);
cfg.connectionType = 'visa';
cfg.visaAddr = strtrim(get(handles.editVisaAddr2, 'String'));
testConnection(hObject, cfg);


% --- Executes on button press in pushbuttonTestAWG1.
function pushbuttonTestAWG1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestAWG1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[cfg dummy] = makeArbConfig(handles);
testConnection(hObject, cfg);



function result = testConnection(hObject, arbConfig)
model = arbConfig.model;
checkmodel = [];
checkfeature = [];
if (~isempty(strfind(model, 'M8190')))
    checkmodel = 'M8190A';
elseif (~isempty(strfind(model, 'M8195A')))
    checkmodel = 'M8195A';
elseif (~isempty(strfind(model, 'M8196A')))
    checkmodel = 'M8196A';
elseif (~isempty(strfind(model, '81180')))
    checkmodel = '81180';
elseif (~isempty(strfind(model, '81150')))
    checkmodel = '81150';
elseif (~isempty(strfind(model, '81160')))
    checkmodel = '81160';
elseif (~isempty(strfind(model, 'N5182A')))
    checkmodel = 'N5182A';
elseif (~isempty(strfind(model, 'N5182B')))
    checkmodel = 'N5182B';
elseif (~isempty(strfind(model, 'N5172B')))
    checkmodel = 'N5172B';
elseif (~isempty(strfind(model, 'E4438C')))
    checkmodel = 'E4438C';
elseif (~isempty(strfind(model, 'E8267D')))
    checkmodel = 'E8267D';
elseif (~isempty(strfind(model, '335')))
    checkmodel = '335';
elseif (~isempty(strfind(model, '336')))
    checkmodel = '336';
else
    msgbox({'The "Test Connection" function is not yet implemented for this model.' ...
            'Please download a waveform and observe error messages'});
    result = 1;
    return;
end
if (~isempty(strfind(model, 'DUC')))
    checkfeature = 'DUC';
end
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
instrreset();
if (iqoptcheck(arbConfig, [], checkfeature, checkmodel))
    set(hObject, 'Background', 'green');
    result = 1;
else
    set(hObject, 'Background', 'red');
    result = 0;
end
try close(hMsgBox); catch ex; end


% --- Executes on button press in pushbuttonTestSA.
function pushbuttonTestSA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dummy saCfg] = makeArbConfig(handles);
if (~isempty(strfind(saCfg.visaAddr, 'Enter VISA')))
    errordlg({'Please enter a valid VISA Address for the Spectrum Analyzer. Typically' ...
        'something like: TCPIP0::IP-Address::inst0::INSTR.  You can find the correct' ...
        'IP address in the control panel of the spectrum analyzer'});
    return;
end
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(saCfg);
try close(hMsgBox); catch ex; end
found = 0;
if (~isempty(f))
    res = query(f, '*IDN?');
    if (~isempty(strfind(res, 'E444')) || ...
        ~isempty(strfind(res, 'N9000')) || ...
        ~isempty(strfind(res, 'N9010')) || ...
        ~isempty(strfind(res, 'N9020')) || ...
        ~isempty(strfind(res, 'N9030')) || ...
        ~isempty(strfind(res, 'N9040')))
        found = 1;
    else
        errordlg({'Unexpected spectrum analyzer type:' '' res ...
            'Supported models are PSA (E444xA), MXA (N9020A) and PXA (N9030A)'});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


% --- Executes on button press in pushbuttonSwapAWG.
function pushbuttonSwapAWG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSwapAWG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
awg1 = get(handles.editVisaAddr, 'String');
awg2 = get(handles.editVisaAddr2, 'String');
set(handles.editVisaAddr2, 'String', awg1);
set(handles.editVisaAddr, 'String', awg2);
set(handles.popupmenuConnectionType, 'Value', 2);
popupmenuConnectionType_Callback([], [], handles);


% --- Executes on button press in pushbuttonTestM8192A.
function pushbuttonTestM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
M8192ACfg.connectionType = 'visa';
M8192ACfg.visaAddr = strtrim(get(handles.editVisaAddrM8192A, 'String'));
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(M8192ACfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, 'M8192A')))
            found = 1;
        else
            errordlg({'Unexpected IDN response:' '' res ...
                'Please specify the VISA address of an M8192A module' ...
                'and make sure the corresponding firmware is running'});
        end
    catch ex
        errordlg({'Error reading IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


function editVisaAddrM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrM8192A as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrM8192A as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrM8192A_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxVisaAddrM8192A.
function checkboxVisaAddrM8192A_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxVisaAddrM8192A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxVisaAddrM8192A
M8192AConnected = get(handles.checkboxVisaAddrM8192A, 'Value');
if (~M8192AConnected)
    set(handles.editVisaAddrM8192A, 'Enable', 'off');
    set(handles.pushbuttonTestM8192A, 'Enable', 'off');
    set(handles.pushbuttonTestM8192A, 'Background', [.9 .9 .9]);
    answer = questdlg({'Do you want to re-configure the M8192A to let'
        'the M8190A modules run individually?'}, 'M8192A configuration');
    switch (answer)
        case 'Yes'
            hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
            try
                arbConfig = loadArbConfig();
                arbConfig.visaAddr = arbConfig.visaAddrM8192A;
                fsync = iqopen(arbConfig);
                fprintf(fsync, ':ABOR');
                fprintf(fsync, ':inst:mmod:conf 1');
                fprintf(fsync, ':inst:slave:del:all');
                fprintf(fsync, ':inst:mast ""');
                query(fsync, '*opc?');
                fclose(fsync);
            catch ex
                msgbox(ex.message);
            end
            try close(hMsgBox); catch ex; end
        case 'No'
            % do nothing
        case 'Cancel'
            set(handles.checkboxVisaAddrM8192A, 'Value', 1);
    end
else
    if (~get(handles.checkboxVisaAddr2, 'Value'))
        msgbox({'Please configure a second M8190A module first'});
        set(handles.checkboxVisaAddrM8192A, 'Value', 0);
    else
        set(handles.editVisaAddrM8192A, 'Enable', 'on');
        set(handles.pushbuttonTestM8192A, 'Enable', 'on');
        msgbox({'NOTE: When this checkbox is checked, the two M8190A modules' ...
            '(all 4 channels) will run synchronously. Please make sure you load' ...
            'waveforms to all 4 channels. In order to improve the skew, please use' ...
            'the "4-channel sync" utility' ...
            'If you want to use the M8190A individually, please uncheck this checkbox'});
    end
end


% --- Executes on selection change in popupmenuTrigger.
function popupmenuTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTrigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTrigger
paramChangedNote(handles);


% --- Executes during object creation, after setting all properties.
function popupmenuTrigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSetGainCorr.
function checkboxSetGainCorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSetGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSetGainCorr
val = get(hObject,'Value');
onoff = {'off' 'on'};
set(handles.editGainCorr, 'Enable', onoff{val+1});
paramChangedNote(handles);



function editGainCorr_Callback(hObject, eventdata, handles)
% hObject    handle to editGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGainCorr as text
%        str2double(get(hObject,'String')) returns contents of editGainCorr as a double


% --- Executes during object creation, after setting all properties.
function editGainCorr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGainCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuAmplScale.
function popupmenuAmplScale_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAmplScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAmplScale
amplScaleList = cellstr(get(handles.popupmenuAmplScale, 'String'));
amplScaleVal = get(handles.popupmenuAmplScale, 'Value');
% !!! as long as it is not implemented - always set to 'Leave Unchanged'
if (amplScaleVal ~= 3)
    set(handles.popupmenuAmplScale, 'Value', 3);
    msgbox({'Setting the Amplitude Scale is not yet implemented in IQTools.' 
           'In the meantime, please use the Soft Front Panel to set it'});
end
amplScaleMode = amplScaleList{amplScaleVal};
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
if (~isempty(strfind(arbModel, 'M8190A_DUC')))
    set(handles.popupmenuAmplScale, 'Enable', 'on');
    set(handles.textAmplScale, 'Enable', 'on');
    if (strcmp(amplScaleMode, 'User Defined'))
        set(handles.editAmplScale, 'Enable', 'on');
    else
        set(handles.editAmplScale, 'Enable', 'off');
    end
else
    set(handles.popupmenuAmplScale, 'Enable', 'off');
    set(handles.editAmplScale, 'Enable', 'off');
    set(handles.textAmplScale, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupmenuAmplScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAmplScale_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmplScale as text
%        str2double(get(hObject,'String')) returns contents of editAmplScale as a double
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && isempty(find(value < 2.83)) && isempty(find(value > 1)))
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editAmplScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxRemoteVSA.
function checkboxRemoteVSA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRemoteVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxRemoteVSA
VSAConnected = get(handles.checkboxRemoteVSA, 'Value');
if (~VSAConnected)
    set(handles.editVisaAddrVSA, 'Enable', 'off');
    set(handles.pushbuttonTestVSA, 'Enable', 'off');
    set(handles.pushbuttonTestVSA, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrVSA, 'Enable', 'on');
    set(handles.pushbuttonTestVSA, 'Enable', 'on');
%    msgbox('Note: Remote VSA access is not completely implemented. Some functions are not yet available. Please continue to use "local" VSA in the meantime');
end



function editVisaAddrVSA_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrVSA as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrVSA as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrVSA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTestVSA.
function pushbuttonTestVSA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestVSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSACfg.connectionType = 'visa';
VSACfg.visaAddr = get(handles.editVisaAddrVSA, 'String');
if (~isempty(strfind(VSACfg.visaAddr, 'Enter VISA')))
    errordlg({'Please enter a valid VISA Address for VSA. Typically something' ...
        'like: TCPIP0::ComputerName::5026::SOCKET.  You can find the correct' ...
        'address in the VSA software under Utilities -> SCPI Configuration'});
    return;
end
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(VSACfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, '8960')) || ~isempty(strfind(res, 'N4391')))
            found = 1;
        else
            errordlg({'Unexpected reponse from VSA: ' '' res});
        end
    catch ex
        errordlg({'Error reading VSA IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end


% --- Executes on button press in checkboxM8195Acorr.
function checkboxM8195Acorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxM8195Acorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkboxM8195Acorr
val = get(hObject, 'Value');
if (val)
    msgbox(['Note, this method of applying the M8195A correction is NOT recommended. ' ...
        'Instead, please open any of the waveform generation windows, click on "Show ' ...
        'Correction" and then on "Read M8195A built-in corrections"']);
end


% --- Executes on button press in pushbuttonTestDCA.
function pushbuttonTestDCA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestDCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DCACfg.connectionType = 'visa';
DCACfg.visaAddr = get(handles.editVisaAddrDCA, 'String');
if (~isempty(strfind(DCACfg.visaAddr, 'Enter VISA')))
    errordlg({'Please enter a valid VISA Address for DCA. Typically something' ...
        'like: TCPIP0::ComputerName::inst0::INSTR.  You can find the address' ...
        'of the DCA under Tools -> SCPI Programming -> SCPI Server setup'});
    return;
end
found = 0;
hMsgBox = msgbox('Trying to connect, please wait...', 'Please wait...', 'replace');
f = iqopen(DCACfg);
try close(hMsgBox); catch ex; end
if (~isempty(f))
    try
        res = query(f, '*IDN?');
        if (~isempty(strfind(res, 'N1010')) || ~isempty(strfind(res, '86100')))
            found = 1;
        else
            errordlg({'Unexpected IDN reponse from DCA: ' '' res});
        end
    catch ex
        errordlg({'Error reading DCA IDN:' '' ex.message});
    end
    fclose(f);
end
if (found)
    set(hObject, 'Background', 'green');
else
    set(hObject, 'Background', 'red');
end



function editVisaAddrDCA_Callback(hObject, eventdata, handles)
% hObject    handle to editVisaAddrDCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVisaAddrDCA as text
%        str2double(get(hObject,'String')) returns contents of editVisaAddrDCA as a double


% --- Executes during object creation, after setting all properties.
function editVisaAddrDCA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVisaAddrDCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxDCA.
function checkboxDCA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxDCA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DCAConnected = get(handles.checkboxDCA, 'Value');
if (~DCAConnected)
    set(handles.editVisaAddrDCA, 'Enable', 'off');
    set(handles.pushbuttonTestDCA, 'Enable', 'off');
    set(handles.pushbuttonTestDCA, 'Background', [.9 .9 .9]);
else
    set(handles.editVisaAddrDCA, 'Enable', 'on');
    set(handles.pushbuttonTestDCA, 'Enable', 'on');
%    msgbox('Note: Remote VSA access is not completely implemented. Some functions are not yet available. Please continue to use "local" VSA in the meantime');
end


function result = checkfields(hObject, eventdata, handles)
% do nothing
result = [];


% --- Executes on selection change in popupmenuClockSource.
function popupmenuClockSource_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuClockSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = get(handles.popupmenuClockSource, 'Value');
arbModels = cellstr(get(handles.popupmenuModel, 'String'));
arbModel = arbModels{get(handles.popupmenuModel, 'Value')};
switch (idx)
    case 1 % leave unchanged
        freqFlag = 'off';
    case 2 % int ref clk
        freqFlag = 'off';
    case 3 % axie ref clk
        freqFlag = 'off';
    case 4 % ext ref clk
        freqFlag = 'on';
    case 5 % ext sample clk
        if (~isempty(strfind(arbModel, '8195')) || ...
                ~isempty(strfind(arbModel, '8196')))
            errordlg('M8195A / M8196A AWGs do not support external sample clock');
            set(handles.popupmenuClockSource, 'Value', 2);
            freqFlag = 'off';
        else
            freqFlag = 'on';
        end
end
set(handles.editClockFreq, 'Enable', freqFlag);
set(handles.textClockFreq, 'Enable', freqFlag);


% --- Executes during object creation, after setting all properties.
function popupmenuClockSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuClockSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editClockFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editClockFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value) && value >= 0)
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editClockFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClockFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqloadsettings(handles);
popupmenuModel_Callback(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iqsavesettings(handles);



function editPeaking_Callback(hObject, eventdata, handles)
% hObject    handle to editPeaking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = [];
try
    value = evalin('base', ['[' get(hObject, 'String') ']']);
catch ex
    msgbox(ex.message);
end
if (isscalar(value))
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor','red');
end


% --- Executes during object creation, after setting all properties.
function editPeaking_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPeaking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
close(handles.output);
