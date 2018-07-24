function [result, fs] = iqreadscope(arbConfig, chan, trigChan, duration, avg, maxAmpl)
% read a waveform from scope
%
% arguments:
% arbConfig - if empty, use realtime scope address configured in IQTools config
% chan - cell array of scope channels to be captured ('1'-'4', 'DIFF1', 'DIFF2', 'REdge1', 'REdge3', 'DIFFREdge')
% trigChan - string with trigger channel ('1'-'4' = Chan 1-4 or 'AUX')
% duration - length of capture (in seconds)
% avg - number of averages (1 = no averaging)
% maxAmpl - amplitude of the signal (will be used to set Y scale)
%           if set to 0, will not set amplitude
%           if set to -1, will use maximum amplitude that is supported by
%           this scope
%
if (~exist('arbConfig', 'var'))
    arbConfig = [];
end
arbConfig = loadArbConfig(arbConfig);
if ((isfield(arbConfig, 'isScopeConnected') && arbConfig.isScopeConnected == 0) || ~isfield(arbConfig, 'visaAddrScope'))
    error('Scope address is not configured, please use "Instrument Configuration" to set it up');
end
if (~exist('chan', 'var'))
    chan = {'1' '2'};
end
if (~exist('trigChan', 'var'))
    trigChan = '4';
end
if (~exist('duration', 'var') || isempty(duration))
    duration = 1e-6;
end
if (~exist('avg', 'var') || isempty(avg) || avg < 1)
    avg = 1;
end
if (~exist('maxAmpl', 'var') || isempty(maxAmpl))
    maxAmpl = 800e-3;
end
numChan = length(chan);
result = [];
fs = 0;
f = iqopen(arbConfig.visaAddrScope);
if (isempty(f))
    return;
end
xfprintf(f, sprintf('*CLS'));
xfprintf(f, sprintf(':TIMEbase:SCale %g', duration / 10));
xfprintf(f, sprintf(':TIMEbase:REFerence LEFT'));
xfprintf(f, sprintf(':TIMEbase:DELay %g', 0));
%xfprintf(f, sprintf(':STOP'));   % do not stop, otherwise autoscale will not work
%xfprintf(f, sprintf(':ACQuire:BANDwidth MAX'));   % do not set max BW, user might not want that
if (avg > 1)
    xfprintf(f, sprintf(':ACQuire:AVERage:COUNT %d', avg));
    xfprintf(f, sprintf(':ACQuire:AVERage ON'));
else
    xfprintf(f, sprintf(':ACQuire:AVERage OFF'));
end
xfprintf(f, sprintf(':ACQuire:MODE RTIME'));
xfprintf(f, sprintf(':ACQuire:RESPonse FLATmag'));
for i = 1:numChan
    if (strncmpi(chan{i}, 'DIFF', 4))
        if (strncmpi(chan{i}, 'DIFFRE', 6))
            chan{i} = '1';      % differential real edge is only available on channel 1
            xfprintf(f, sprintf(':ACQuire:REDGE ON'), 1);
        else                    % differential signalling on a normal channel
            chan{i} = chan{i}(5);
        end
        xfprintf(f, sprintf(':CHAN%s:DIFF ON', chan{i}));
        % amplitude values seem to be specified per channel and NOT for the
        % differential channel
        ampl = maxAmpl(min(i,length(maxAmpl))) / 2;
    elseif (strncmpi(chan{i}, 'REdge', 5))  % real edge, single ended
        chan{i} = chan{i}(6);
        xfprintf(f, sprintf(':ACQuire:REDGE ON'), 1);
        ampl = maxAmpl(min(i,length(maxAmpl)));
    else                                    % normal channel, single ended
        chan{i} = chan{i}(1);
        xfprintf(f, sprintf(':CHAN%s:DIFF OFF', chan{i}));
        ampl = maxAmpl(min(i,length(maxAmpl)));
    end
    xfprintf(f, sprintf(':CHAN%s:DISP ON', chan{i}));
    if (ampl < 0) % autorange
        xfprintf(f, ':RUN');
        xfprintf(f, sprintf(':AUTOSCALE:VERT CHAN%s', chan{i}), 1);
        query(f, '*OPC?');
        ampl = 0;
    end
    if (ampl > 0) % zero means do not set amplitude
        xfprintf(f, sprintf(':CHAN%s:RANGe %g', chan{i}, ampl));
        xfprintf(f, sprintf(':CHAN%s:OFFS %g', chan{i}, 0));
    end
end
if (~isempty(trigChan))
    if (strncmpi(trigChan, 'REdge', 5))
        trigChan = trigChan(6:end);
    end
    trigLevel = 0;  % assume trigger level is always 0V
    xfprintf(f, sprintf(':TRIGger:MODE EDGE'));
    xfprintf(f, sprintf(':TRIGger:EDGE:SLOPe POS'));
    xfprintf(f, sprintf(':TRIGger:SWEEP TRIGgered'));
    if (strcmp(trigChan, 'AUX'))
        xfprintf(f, sprintf(':TRIGger:EDGE:SOURce AUX'));
        xfprintf(f, sprintf(':TRIGger:LEVel AUX,%g', trigLevel));
    else
        xfprintf(f, sprintf(':CHAN%s:DISP OFF', trigChan));
        xfprintf(f, sprintf(':TRIGger:EDGE:SOURce CHAN%s', trigChan));
        xfprintf(f, sprintf(':TRIGger:LEVel CHAN%s,%g', trigChan, trigLevel));
        ampl = maxAmpl(1);
        if (ampl < 0) % autorange
            xfprintf(f, sprintf(':CHAN%s:DISP ON', trigChan));
            xfprintf(f, sprintf(':AUTOSCALE:VERT CHAN%s', trigChan));
            query(f, '*OPC?');
            ampl = 0;
        end
        if (ampl > 0)
            xfprintf(f, sprintf(':CHAN%s:RANGe %g', trigChan, maxAmpl(1)));
            xfprintf(f, sprintf(':CHAN%s:OFFS %g', trigChan, 0));
        end
    end
end
%xfprintf(f, sprintf(':ACQuire:SRATE MAX'));     % hmmm, does not work...  assume it is already set to max
fs = str2double(query(f, ':ACQuire:SRATE?'));
numPts = round(duration * fs);
xfprintf(f, sprintf(':ACQuire:POINts %d', numPts));
xfprintf(f, sprintf(':ACQuire:INTerpolate OFF'));
% chaning the number of points might change the sample rate, so set it back
xfprintf(f, sprintf(':ACQuire:SRATE %g', fs));

xfprintf(f, ':WAVeform:FORMat WORD');
if (strcmp(f.type, 'tcpip'))
    xfprintf(f, ':WAVeform:BYTeorder MSBFIRST');
else
    xfprintf(f, ':WAVeform:BYTeorder LSBFIRST');
end
query(f, ':ADER?');  % clear acquisition done register
xfprintf(f, ':SINGLE');
retry = 0;
done = str2double(query(f, ':ADER?'));
% wait max. 1 sec for a trigger event - otherwise fail
while (~done && retry < 10)
    pause(0.1);
    done = str2double(query(f, ':ADER?'));
    retry = retry + 1;
end
if (~done)
    errordlg('Scope did not trigger. Please verify that the connections between AWG and scope match the configuration');
    fclose(f);
    return;
end
result = zeros(numPts, numChan);
for i = 1:numChan
    xfprintf(f, sprintf(':WAVeform:SOURce CHAN%s', chan{i}));
    pre = query(f, ':WAVeform:PREamble?');
    pre = eval(['{' regexprep(pre, '"', '''') '}']);
    fields = {'wav_form', 'acq_type', 'wfmpts', 'avgcnt', 'x_increment', 'x_origin', ...
    'x_reference', 'y_increment', 'y_origin', 'y_reference', 'coupling', ...
    'x_display_range', 'x_display_origin', 'y_display_range', ...
    'y_display_origin', 'date', 'time', 'frame_model', 'acq_mode', ...
    'completion', 'x_units', 'y_units', 'max_bw_limit', 'min_bw_limit'};
    prx = cell2struct(pre, fields, 2);
    fprintf(f, ':WAVeform:DATa?');
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
    xval = linspace(prx.x_origin, prx.x_origin + (prx.wfmpts-1)*prx.x_increment, prx.wfmpts);
    yval = a .* prx.y_increment + prx.y_origin;
    result(:,i) = yval;
end
xfprintf(f, sprintf(''));
fclose(f);
if (nargout == 0)
    figure(1);
    plot(xval, result, '.-');
    grid on;
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
result = query(f, ':syst:err?');
if (isempty(result))
    fclose(f);
    errordlg({'The instrument did not respond to a :SYST:ERRor query.' ...
        'Please check that the firmware is running and responding to commands.'}, 'Error');
    retVal = -1;
    return;
end
if (~exist('ignoreError', 'var') || ignoreError == 0)
    if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12) && ~strncmp(result, '0', 1))
        errordlg({'Instrument returns an error on command:' s 'Error Message:' result}, 'Error', 'replace');
        retVal = -1;
    end
end

