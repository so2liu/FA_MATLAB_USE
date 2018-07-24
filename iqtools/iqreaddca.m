function [yval, fs] = iqreaddca(arbConfig, chan, ~, duration, avg, maxAmpl)
% read a waveform from DCA
%
% arguments:
% arbConfig - if empty, use DCA address configured in IQTools config
% chan - list of scope channels to be captured
% trigChan - not used (will always be front panel)
% duration - length of capture (in seconds)
% avg - number of averages (1 = no averaging)
% maxAmpl - amplitude of the signal (will be used to set Y scale)
%           0 means do not set ampltiude
%           -1 means use maximum amplitude supported by this instrument
%
yval = [];
fs = 1;
if (~exist('arbConfig', 'var'))
    arbConfig = [];
end
arbConfig = loadArbConfig(arbConfig);
if ((isfield(arbConfig, 'isDCAConnected') && arbConfig.isDCAConnected == 0) || ~isfield(arbConfig, 'visaAddrDCA'))
    error('DCA address is not configured, please use "Instrument Configuration" to set it up');
end
f = iqopen(arbConfig.visaAddrDCA);
if (isempty(f))
    return;
end
if (~exist('chan', 'var') || isempty(chan))
    chan = {'1A' '2A'};
end
if (~exist('duration', 'var') || isempty(duration))
    duration = 10e-9;
end
if (~exist('avg', 'var') || isempty(avg) || avg < 1)
    avg = 1;
end
if (~exist('maxAmpl', 'var') || isempty(maxAmpl))
    maxAmpl = 0;        % ampl = 0 means do not set amplitude
end
if (maxAmpl < 0)
    maxAmpl = 0.8;      % max value supported by 86108B
    dp = strfind(chan, 'DIFF');
    if (~isempty([dp{:}]))
        maxAmpl = 2 * maxAmpl;    % for differential ports, double amplitude
    end
end
numChan = length(chan);
xfprintf(f, '*CLS');
% find out which SCPI language to use: flex or old DCA style
flex = 1;
%frame = query(f, ':model? frame');
%if (strncmp(frame, '86100C', 6))
%    flex = 0;
%end
raw_idn = query(f, '*IDN?');
idn = regexp(raw_idn, ',\s*', 'split');
if (strncmp(idn{2}, '86100C', 6))
    flex = 0;
end
xfprintf(f, sprintf(':SYSTem:MODE OSC'));
xfprintf(f, sprintf(':STOP'));
xfprintf(f, sprintf(':TRIG:SOURce:AUTodetect OFF'));
xfprintf(f, sprintf(':TRIG:SOURce FPANEL'));
xfprintf(f, sprintf(':TRIG:PLOC OFF'));
if (flex)
    xfprintf(f, sprintf(':TIMebase:PTIMEbase:STATe OFF'));
    xfprintf(f, sprintf(':PTIMEbase:STATe OFF'));
    xfprintf(f, sprintf(':TIMEbase:UNITs SECond'));
    xfprintf(f, sprintf(':TRIG:BWLimit EDGE'));
else
    xfprintf(f, sprintf(':TRIG:BWLimit LOW'));
end
xfprintf(f, sprintf(':TRIG:LEVEL %g', 0));
xfprintf(f, sprintf(':TRIG:SLOPe POS'));
xfprintf(f, sprintf(':TIMEbase:REFerence LEFT'));
xfprintf(f, sprintf(':TIMEbase:POS %g', max(24e-9, 0)));
if (xfprintf(f, sprintf(':ACQuire:RSPec RLENgth')))
%    return;
end
xfprintf(f, sprintf(':TIMEbase:SCALe %g', duration / 10));
for i = 1:numChan
    if (~isempty(strfind(chan{i}, 'DIFF')))
        xfprintf(f, sprintf(':%s:DMODe ON', chan{i}));
    else
        if ((chan{i}(end) == 'A' || chan{i}(end) == 'C') && flex)
            xfprintf(f, sprintf(':DIFF%s:DMODe OFF', chan{i}));
        end
        if (length(chan{i}) <= 2)
            chan{i} = strcat('CHAN', chan{i});
        end
    end
    ampl = maxAmpl(min(i,length(maxAmpl)));
    if (flex)
        if (ampl ~= 0)
            % don't try to set the amplitude higher than the max. supported
            qmax = str2double(query(f, sprintf(':%s:YSCALE? MAX', chan{i})));
            xfprintf(f, sprintf(':%s:YSCALE %g', chan{i}, min(ampl/8, qmax)));
        end
        % Do not set offset to zero. User might want to set it differently
        %    xfprintf(f, sprintf(':%s:YOFFSET %g', chan{i}, 0));
        % Different modules use different ENUMs for setting bandwidth
        % So, let's try out all of them and ignore any errors
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND1', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND2', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND3', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND4', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth HIGH', chan{i}(end-1:end)), 1);
        xfprintf(f, sprintf(':%s:DISP ON', chan{i}));
    else
        if (ampl ~= 0)
            xfprintf(f, sprintf(':%s:SCALE %g', chan{i}(1:5), ampl / 8));
        end
    % Do not set offset to zero. User might want to set it differently
    %    xfprintf(f, sprintf(':%s:OFFSET %g', chan{i}(1:5), 0));
        % Different modules use different ENUMs for setting bandwidth
        % So, let's try out all of them and ignore any errors
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND1', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND2', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND3', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth BAND4', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':CHAN%s:BANDwidth HIGH', chan{i}(end-1:end-1)), 1);
        xfprintf(f, sprintf(':%s:DISP ON', chan{i}(1:5)));
    end
end
if (flex)
    if (xfprintf(f, sprintf(':ACQuire:RSPec RLENgth')))
        return;
    end
    xfprintf(f, sprintf(':ACQuire:RLENgth:MODE MANUAL'));
    xfprintf(f, sprintf(':ACQuire:RLENgth MAX'));
    numPts = str2double(query(f, ':ACQuire:RLENgth?'));
    if (numPts > 65536)
        numPts = 65536;
        xfprintf(f, sprintf(':ACQuire:RLENgth %f', numPts));
    end    
    xfprintf(f, sprintf(':ACQuire:WRAP OFF'));
    xfprintf(f, sprintf(':ACQuire:CDISplay'));
else
    if (xfprintf(f, sprintf(':CDISplay')))
        return;
    end
    numPts = 16384; % MAX value does not work on old DCA
    %xfprintf(f, sprintf(':ACQuire:POINts MAX'));
    %numPts = str2double(query(f, ':ACQuire:POINts?'));
    xfprintf(f, sprintf(':ACQuire:POINts %d', numPts));
end
if (avg > 1)
    if (flex)
        xfprintf(f, sprintf(':ACQuire:SMOOTHING AVER'));
        xfprintf(f, sprintf(':ACQuire:ECOunt %d', avg));
        xfprintf(f, sprintf(':LTESt:ACQuire:CTYPe:WAVeforms %d', avg));
        xfprintf(f, sprintf(':LTESt:ACQuire:STATe ON'));
        xfprintf(f, sprintf(':ACQuire:RUN'));
    else
        xfprintf(f, sprintf(':ACQuire:AVERAGE ON'));
        xfprintf(f, sprintf(':ACQuire:COUNT %d', avg));
        xfprintf(f, sprintf(':ACQuire:RUNTil WAVEforms,%d', avg));
        xfprintf(f, sprintf(':AEEN 1'));
        xfprintf(f, sprintf(':RUN'));
    end
else
    if (flex)
        xfprintf(f, sprintf(':ACQuire:SMOOTHING NONE'));
        xfprintf(f, sprintf(':LTESt:ACQuire:STATe OFF'));
        xfprintf(f, sprintf(':ACQuire:SINGLE'));
    else
        xfprintf(f, sprintf(':ACQuire:AVERAGE OFF'));
        xfprintf(f, sprintf(':AEEN 0'));
%        xfprintf(f, sprintf(':SINGLE'));   % with :SINGLE, ESR? does not work
        xfprintf(f, sprintf(':RUN'));
    end
end
% wait until capture has completed
% query(f, '*OPC?');    %% don't use a blocking wait!!
xfprintf(f, '*OPC');
pause(2);
count = round(avg * 2) + 10;
while count > 0
    esr = str2double(query(f, '*ESR?'));
    if (bitand(esr, 1) ~= 0)
        break;
    end
    pause(1);
    count = count - 1;
end
if (count <= 0)
    errordlg('Scope timeout during waveform capture. Please make sure that the trigger signal is connected to the front panel trigger input');
    return;
end
if (~flex)
    if (strcmp(f.type, 'tcpip'))
        xfprintf(f, ':WAVeform:BYTeorder MSBFIRST');
    else
        xfprintf(f, ':WAVeform:BYTeorder LSBFIRST');
    end
end
yval = zeros(numPts, numChan);
% read the waveform
for i=1:numChan
    if (flex)
        xfprintf(f, sprintf(':WAVeform:SOURce %s', chan{i}));
        xOrig = str2double(query(f, ':WAVeform:YFORmat:XORigin?'));
        xInc  = str2double(query(f, ':WAVeform:YFORmat:XINC?'));
        yOrig = str2double(query(f, ':WAVeform:YFORmat:WORD:ENC:YORigin?'));
        yInc  = str2double(query(f, ':WAVeform:YFORmat:WORD:ENC:YINC?'));
        tmp = binread(f, ':WAVeform:YFORmat:WORD:YDATA?', 'int16');
    else
        xfprintf(f, sprintf(':WAVeform:SOURce %s', chan{i}(1:5)));
        xfprintf(f, sprintf(':WAVeform:FORMAT WORD'));
        tmp = binread(f, ':WAVeform:DATA?', 'int16');
        xOrig = str2double(query(f, ':WAVeform:XORigin?'));
        xInc  = str2double(query(f, ':WAVeform:XINC?'));
        yOrig = str2double(query(f, ':WAVeform:YORigin?'));
        yInc  = str2double(query(f, ':WAVeform:YINC?'));
    end
    % check for overflow
    if (~isempty(find(tmp == 32256, 1)) || ~isempty(find(tmp == 32256, 1)))
        warndlg('Signal exceeds scope range. Consider reducing the scope amplitude scale or insert an attenuator in the signal path', 'Scope Amplitude exceeded', 'replace');
    end
    % replace negative overflow by a negative value
    tmp(tmp == 31744) = -32767;
    % convert to voltage values
    fs = 1 / xInc;
    xval = (1:numPts) * xInc + xOrig;
    yval(:,i) = tmp * yInc + yOrig;
end
if (flex)
    xfprintf(f, sprintf(':ACQuire:SMOOTHING NONE'));
    xfprintf(f, sprintf(':LTESt:ACQuire:STATe OFF'));
else
    xfprintf(f, sprintf(':ACQuire:AVERAGE OFF'));
    xfprintf(f, sprintf(':AEEN 0'));
end
fclose(f);
% if called without output arguments, plot the result
if (nargout == 0)
    figure(151);
    plot(xval, yval, '.-');
    yval = [];
end



function a = binread(f, cmd, fmt)
a = [];
fprintf(f, cmd);
r = fread(f, 1);
if (~strcmp(char(r), '#'))
    error('unexpected binary format');
end
r = fread(f, 1);
nch = str2double(char(r));
r = fread(f, nch);
nch = floor(str2double(char(r))/2);
if (nch > 0)
    a = fread(f, nch, 'int16');
else
    a = [];
end
fread(f, 1); % real EOL




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
result = query(f, ':syst:err?');
if (isempty(result))
    fclose(f);
    errordlg({'The DCA did not respond to a :SYST:ERRor query.' ...
        'Please check that the connection is established and the DCA is responding to commands.'}, 'Error');
    retVal = -1;
    return;
end
if (~exist('ignoreError', 'var') || ignoreError == 0)
    if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12) && ~strncmp(result, '0', 1))
        errordlg({'Instrument returns an error on command:' s 'Error Message:' result}, 'Error');
        retVal = -1;
    end
end
