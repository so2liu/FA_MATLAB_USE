
function mpulse_demo()
%
% demo a variety of pulses on M8195A
%
arbConfig = loadArbConfig();
if (strcmp(arbConfig.model, 'M8195A_Rev1') || strcmp(arbConfig.model, 'M8195A_2ch_256k') || strcmp(arbConfig.model, 'M8195A_4ch_256k'))
    mpulse_demo1();
elseif (strcmp(arbConfig.model, 'M8195A_2ch') || strcmp(arbConfig.model, 'M8195A_2ch_mrk') || strcmp(arbConfig.model, 'M8195A_4ch'))
    mpulse_demo2();
else
    errordlg('This demo is only supported on M8195A Rev.1 or with M8195A Rev. 2 in 4-channel/256K mode');
end


function mpulse_demo2()
arbConfig = loadArbConfig();
fs = arbConfig.defaultSampleRate;
loopDuration = 10;
pri = 2e-6;
pw = 200e-9;
maxDelay = 100e-9;
nsteps = 200;
numSegmentLoops = round(loopDuration / nsteps / pri);
wfms = cell(4);
clear seq;
for k = 1:nsteps
    hMsgBox = msgbox(sprintf('Downloading Waveform %d of %d', k, nsteps), 'Please wait...', 'replace');
    delay = maxDelay * sin(2*pi*(k/nsteps)) * [0 1 2 3]/3;
    delay = delay + abs(min(delay));
    for i = 1:4
        % calculate waveform with variable delay
        wfms{i} = imag(iqpulse('pri', pri, 'pw', pw, 'offset', 200e6, 'span', 390e6, 'sampleRate', fs, 'delay', delay(i)));
        % add some amplitude variation
        wfms{i} = wfms{i} .* ((sin(2*pi*(k/nsteps)) * (i-1)/3) / 4 + 0.75);
    end
    if (arbConfig.numChannels == 4)
        iqdownload(complex(wfms{1}, wfms{2}), fs, 'segmentNumber', k, 'channelMapping', [1 0; 0 1; 0 0; 0 0], 'run', 0, 'keepopen', 1);
        iqdownload(complex(wfms{3}, wfms{4}), fs, 'segmentNumber', k, 'channelMapping', [0 0; 0 0; 1 0; 0 1], 'run', 0, 'keepopen', 1);
    else
        iqdownload(complex(wfms{1}, wfms{4}), fs, 'segmentNumber', k, 'channelMapping', [1 0; 0 0; 0 0; 0 1], 'run', 0, 'keepopen', 1);
    end
end
try 
    close(hMsgBox);
catch
end
i = 1;
for k = 1:nsteps
    seq(i).sequenceInit = 1;
    seq(i).sequenceEnd = 1;
    seq(i).markerEnable = 1;
    if (k == nsteps)
        seq(i).scenarioEnd = 1;
    end
    seq(i).segmentNumber = k;
    seq(i).segmentLoops = numSegmentLoops;
    seq(i).sequenceAdvance = 'Auto';
    i = i + 1;
end
iqseq('define', seq, 'keepOpen', 1, 'run', 0);
iqseq('mode', 'STSC');
%
% set up real-time scope if available
%
arbConfig = loadArbConfig();
if ((isfield(arbConfig, 'isScopeConnected') && arbConfig.isScopeConnected == 0) || ~isfield(arbConfig, 'visaAddrScope'))
    errordlg('Connection to realtime scope address is not configured. Please set up the scope manually');
    return;
end
hMsgBox = msgbox('Setting up the Oscilloscope, please wait...', 'Please wait...', 'replace');
f = iqopen(arbConfig.visaAddrScope);
if (isempty(f))
    try 
        close(hMsgBox);
    catch
    end
    return;
end
xfprintf(f, '*RST');
xfprintf(f, sprintf(':TIMEbase:SCale %g', 50e-9));
xfprintf(f, sprintf(':TIMEbase:DELay %g', 100e-9));
trigChan = 1;
xfprintf(f, sprintf(':TRIGger:EDGE:SOURce CHAN%d', trigChan));
xfprintf(f, sprintf(':TRIGger:LEVel CHAN%d,%g', trigChan, 50e-3));
xfprintf(f, sprintf(':TRIGger:HOLD %g', pri * 0.9));
xfprintf(f, sprintf(':DISPlay:GRAT:NUMB %d', 4));
if (arbConfig.numChannels == 4)
    xfprintf(f, sprintf(':DISPlay:GRAT:NUMB %d', 4));
    for i = 1:4
        xfprintf(f, sprintf(':CHAN%d:DISP ON', i));
        xfprintf(f, sprintf(':CHAN%d:RANGe %g', i, 560e-3));
        xfprintf(f, sprintf(':CHAN%d:OFFS %g', i, 0));
        xfprintf(f, sprintf(':DISPlay:GRAT:SETGrat CHN%d,%d', i, i));
    end
else
    xfprintf(f, sprintf(':DISPlay:GRAT:NUMB %d', 2));
    for i = [1 4]
        xfprintf(f, sprintf(':CHAN%d:DISP ON', i));
        xfprintf(f, sprintf(':CHAN%d:RANGe %g', i, 560e-3));
        xfprintf(f, sprintf(':CHAN%d:OFFS %g', i, 0));
        xfprintf(f, sprintf(':DISPlay:GRAT:SETGrat CHN%d,%d', i, (i+2)/3));
    end
    for i = [2 3]
        xfprintf(f, sprintf(':CHAN%d:DISP OFF', i));
    end
end
fclose(f);
try 
    close(hMsgBox);
catch
end


function mpulse_demo1()
hMsgBox = msgbox('Downloading waveform, please wait...', 'Please wait...', 'modal');
fs = 6.4e+10;
freq = { [2e9 8e9], 1e9, [8e9, 3.5e9], 16e9, 10e9 };
del = { [1e-9, 0], 2e-9, [3e-9, 0], 4e-9, 5e-9 };
pw = { [1.99e-9 1.6e-6], 1.6e-6, [2.99e-9 1.6e-6], 1.6e-6, 3e-9 };
pri = { [3e-9, 4e-6 - 3e-9], 4e-6, [6e-9, 4e-6 - 6e-9], 4e-6, 4e-6 };
tt = { 0.0e-9, 0.0e-9, 0.0e-9, 0.0e-9, 0.0e-9 };
clear iq;
for i = 1:5
iq(:,i) = imag(iqpulse('sampleRate', fs, ...
    'PRI', pri{i}, 'PW', pw{i}, ...
    'riseTime', tt{i}, 'fallTime', tt{i}, ...
    'pulseShape', 'Raised Cosine', 'span', 0, 'offset', freq{i}, ...
    'amplitude', 0, 'fmFormula', 'sin(2*pi*x)', 'pmFormula', '360*floor(x*4)/4', ...
    'modulationType', 'Increasing', 'correction', 0, 'delay', del{i}, 'phase', 0));
end
iq(:,2) = (iq(:,2) + iq(:,5)) / 2;

iqdownload(complex(iq(:,1), iq(:,2)), fs, 'channelMapping', [1 0; 0 1; 1 0; 1 0]);
iqdownload(complex(iq(:,3), iq(:,4)), fs, 'channelMapping', [0 0; 0 0; 1 0; 0 1]);
try delete(hMsgBox); catch; end

%
% set up real-time scope if available
%
arbConfig = loadArbConfig();
if ((isfield(arbConfig, 'isScopeConnected') && arbConfig.isScopeConnected == 0) || ~isfield(arbConfig, 'visaAddrScope'))
    errordlg('Connection to realtime scope address is not configured. Please set up the scope manually');
    return;
end
hMsgBox = msgbox('Setting up the Oscilloscope, please wait...', 'Please wait...', 'replace');
f = iqopen(arbConfig.visaAddrScope);
if (isempty(f))
    try 
        close(hMsgBox);
    catch
    end
    return;
end
xfprintf(f, '*RST');
xfprintf(f, sprintf(':TIMEbase:SCale %g', 1e-9));
xfprintf(f, sprintf(':TIMEbase:DELay %g', 3e-9));
trigChan = 2;
xfprintf(f, sprintf(':TRIGger:EDGE:SOURce CHAN%d', trigChan));
xfprintf(f, sprintf(':TRIGger:LEVel CHAN%d,%g', trigChan, 50e-3));
xfprintf(f, sprintf(':TRIGger:HOLD %g', 3.9e-6));
xfprintf(f, sprintf(':DISPlay:GRAT:NUMB %d', 4));
for i = 1:4
    xfprintf(f, sprintf(':CHAN%d:DISP ON', i));
    xfprintf(f, sprintf(':CHAN%d:RANGe %g', i, 560e-3));
    xfprintf(f, sprintf(':CHAN%d:OFFS %g', i, 0));
    xfprintf(f, sprintf(':DISPlay:GRAT:SETGrat CHN%d,%d', i, i));
end
fclose(f);
try 
    close(hMsgBox);
catch
end


function retVal = xfprintf(f, s, ignoreError)
% Send the string s to the instrument object f
% and check the error status
% if ignoreError is set, the result of :syst:err is ignored
% returns 0 for success, -1 for errors
retVal = 0;
if (evalin('base', 'exist(''debugScpi'', ''var'')'))
    fprintf('cmd = %s\n', s);
end
fprintf(f, s);
% result = query(f, ':syst:err?');
% if (isempty(result))
%     fclose(f);
%     errordlg({'The instrument did not respond to a :SYST:ERRor query.' ...
%         'Please check that the firmware is running and responding to commands.'}, 'Error');
%     retVal = -1;
%     return;
% end
% if (~exist('ignoreError', 'var') || ignoreError == 0)
%     if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12) && ~strncmp(result, '0', 1))
%         errordlg({'Instrument returns an error on command:' s 'Error Message:' result}, 'Error', 'replace');
%         retVal = -1;
%     end
% end
