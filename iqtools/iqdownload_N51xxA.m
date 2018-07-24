function f = iqdownload_N51xxA(arbConfig, fs, data, marker1, marker2, segmNum, keepOpen, channelMapping, sequence)
% Download IQ to MXG/MXG-X/EXG/ESG/PSG
% Ver 1.1, Robin Wang, Feb 2013
if (~isempty(sequence))
    errordlg('Sequence mode is not available for the Keysight VSG');
    f = [];
    return;
end

f = iqopen(arbConfig);
if (isempty(f))
    return;
end

if ((strcmp(arbConfig.connectionType, 'visa')) || (strcmp(arbConfig.connectionType, 'tcpip')))
    f.ByteOrder = 'bigEndian';
else
    f.ByteOrder = 'littleEndian';
end
    
if (isfield(arbConfig,'do_rst') && arbConfig.do_rst)
    xfprintf(f, '*RST');
end

% prompt the user for center frequency and power
% defaults are the current settings
fCenter      = query(f, ':freq? ');
amplitude    = query(f, ':power?');
prompt       = {'Amplitude of Signal (dBm):', 'Carrier Frequency (Hz): '};
defaultVal   = {sprintf('%g', eval(amplitude)), sprintf('%g', eval(fCenter))};
dlg_title    = 'Inputs for VSG';
user_vals    = inputdlg(prompt, dlg_title, 1, defaultVal);
drawnow;

if (isempty(user_vals{1})) && (isempty(user_vals{2}))
    amplitude = 0;
    fCenter   = 1e9;
    warndlg('The amplitude is set to 0 dBm, and carrier frequency to 1 GHz')
else
    amplitude = user_vals{1};
    fCenter   = user_vals{2};
end

if (isempty(user_vals{1})) && ~(isempty(user_vals{2}))
    amplitude = 0;
    warndlg('The amplitude is set to 0 dBm')
else     
    amplitude = user_vals{1};
end

if ~(isempty(user_vals{1})) && (isempty(user_vals{2}))
    fCenter = 1e9;    
    warndlg('Carrier frequency is set to 1 GHz')
else
    fCenter = user_vals{2};
end

ArbFileName = sprintf('IQTools%04d', segmNum);       % filename for the data in the ARB

downloadSignal(f, data.', ArbFileName, fs, fCenter, amplitude);

if (~keepOpen)
    fclose(f);delete(f); 
end
end


function downloadSignal(deviceObject, IQData, ArbFileName, sampleRate, centerFrequency, outputPower)
% This function downloads IQ Data to the signal generator's non-volatile memory
% This function takes 2 inputs,
% * instrument object
% * The waveform which is a row vector.
% Syntax: downloadWaveform(instrObject, Test_IQData)

% Copyright 2012 The MathWorks, Inc.

if ~isvector(IQData)
    error('downloadWaveform: invalidInput');
else
    IQsize = size(IQData);
    % User gave input as column vector. Reshape it to row vector.
    if ~isequal(IQsize(1),1)
        IQData = reshape(IQData,1,IQsize(1));
    end
end


%% Download signal
% Seperate out the real and imaginary data in the IQ Waveform
wave = [real(IQData);imag(IQData)];
wave = wave(:)';    % transpose the waveform

% Scale the waveform if necessary
tmp = max(abs([max(wave) min(wave)]));
if (tmp == 0)
    tmp = 1;
end

% ARB binary range is 2's Compliment -32768 to + 32767
% So scale the waveform to +/- 32767 not 32768
scale  = 2^15-1;
scale  = scale/tmp;
wave   = round(wave * scale);
modval = 2^16;
% Get data from double to unsigned int
wave = uint16(mod(modval + wave, modval));

% Some settings commands to make sure we don't damage the instrument
% fprintf(deviceObject,':OUTPut:STATe OFF');
% fprintf(deviceObject,':SOURce:RADio:ARB:STATe OFF');
% fprintf(deviceObject,':OUTPut:MODulation:STATe OFF');

% Write the data to the instrument
binblockwrite(deviceObject,wave,'uint16',[':MEMory:DATa:UNProtected "WFM1:' ArbFileName '", ']);
fprintf(deviceObject,'\n');

% Set the scaling to 75%
fprintf(deviceObject, ':SOURce:RADio:ARB:RSCaling 75');

% Set the sample rate (Hz) for the signal.
% You can get this info for the standard signals by looking at the data in the 'waveforms' variable
fprintf(deviceObject,[':SOURce:RADio:ARB:SCLock:RATE ' num2str(sampleRate)]);
% set center frequency (Hz)
fprintf(deviceObject, ['SOURce:FREQuency ' num2str(centerFrequency)]);
% set output power (dBm)
fprintf(deviceObject, ['POWer ' num2str(outputPower)]);

% make sure output protection is turned on
fprintf(deviceObject,':OUTPut:PROTection ON');
% turn off internal AWGN noise generation
% fprintf(deviceObject,':SOURce:RADio:ARB:NOISe:STATe OFF');

% Play back the selected waveform
fprintf(deviceObject, [':SOURce:RAD:ARB:WAV "WFM1:' ArbFileName '"']);

opcComp = query(deviceObject, '*OPC?');
while str2double(opcComp)~= 1
    pause(0.5);
    opcComp = query(deviceObject, '*OPC?');
end

% ARB Radio on
xfprintf(deviceObject, ':SOURce:RADio:ARB:STATe ON');
% modulator on
xfprintf(deviceObject, ':OUTPut:MODulation:STATe ON');
% RF output on
xfprintf(deviceObject, ':OUTPut:STATe ON');

end


function xfprintf(f, s)
% Send the string s to the instrument object f
% and check the error status

% un-comment the following line to see a trace of commands
%    fprintf('cmd = %s\n', s);
    fprintf(f, s);
    
    result = query(f, ':syst:err?');

    if (isempty(result))
        fclose(f);
        errordlg('Instrument did not respond to :SYST:ERR query. Check the instrument.', 'Error');
        error('Instrument did not respond to :SYST:ERR query. Check the instrument.');
    end

    if (~strncmpi(result, '+0,no error', 10) && ~strncmpi(result, '+0,"no error"', 12))
        errordlg(sprintf('Instrument returns error on cmd "%s". Result = %s\n', s, result));
    end

end
