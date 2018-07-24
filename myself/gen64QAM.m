clear
close all
clc
creation_date = date;
signal_gen_version = 3.2;

% %% loop to generate all symbol rates
% for PSRB7
%  sps_sweep =           [64,32,20,16,13,10, 9, 8, 7, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2];  
%  sampleRate_sweep =    [64,64,60,64,65,60,63,64,63,60,60,65,56,60,64,57,60,63,56,58,60,62,64]*1e9;
% 
% % only for PRBS 15
%  sps_sweep =           [ 8, 7, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2];  
%  sampleRate_sweep =    [64,63,60,60,65,56,60,64,57,60,63,56,58,60,62,64]*1e9;
%  for t=1:length(sps_sweep)

%% parameters
saveFile = 2;       % 1: AWG M8195A .mat-v6, 2: to VSA .mat, 0: don't save
format = 'QAM';     % possible Options 'PSK', 'QAM'
polynom = 15;       % PRBS order (7, 15, 23, or 31)
shape = 'Raised_Cosine'; % pulse shape  ['Raised Cosine' 'Rect']
beta = 0.35; 		% roll-off factor for raised cosine
filterOrder = 512;  % filter order
n = 1;              % number of channels
unc = 'Yes';        % uncorrelated channels ['Yes' ''No']
shiftingFactor = 0; % percentage of NumSym time shifted regarding the previous signal generated
FGap = 'No';
GapPercent = 0.35;   % percentage of signal bandwith for frequency gap between two contiguous channels
Nqam = [128 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4]; % number of symbol states for each channel starting at most negative frequency
Fc = [0];
powN = 'Yes';
bit8 = 'No';
%% sampling 
% sps = sps_sweep(t);
% sampleRate = sampleRate_sweep(t);

sps = 32;                        % samples per symbol
% stop;
sampleRate = 64e9;              % AWG M8195A sample rate (56e9 - 65e9)
XDelta = 1/sampleRate;          % AWG time step = 1/sample rate
symRate = sampleRate/sps;       % symbol rate
fprintf('Vs = %d GBd \n',symRate/1e9);
BW = (1+beta)*symRate;          % filter bandwidth
fprintf('BW = %d GHz \n',double(BW/1e9)); 
fG = BW*GapPercent;
fprintf('fG = %d GHz \n \n',fG/1e9);

% necessary for saving to VSA
if saveFile == 2
   sps = 2*sps;
   sampleRate = 2*sampleRate;
end

% necessary for plotting the signal spectrum
Nfft = 2048; 					% Size of the FFT. Frequency bins Fb = Nfft:Fs
f = -sampleRate/2:sampleRate/Nfft:sampleRate/2-sampleRate/Nfft; % Frequency axis for plotting the spectra

%% signal length
numSym = (2^polynom-1);       % watch out for sps and Nqam! signal length = sps*numSym
numSamples = sps*(numSym);    % must be an integer multiple of 128 and not exceed 2^18 = 262144

%% mapped
Nqam = Nqam(1,1:n); %change when deciding number of channels!!!! otherwise everything's done for the desire number of channels but not for the real ones
if strcmp(unc, 'Yes')
    if polynom == 7
        y1 = zeros (numSym,n);
    else
        y1 = zeros (numSym + 1,n);
    end
    for m = 1:n
        y1 (:,m) = (gendata(numSym, Nqam(m), format));                  % generate data
        y1 (:,m) = circshift(y1(:,m), round(numSym*shiftingFactor*m));  % shifting the signal in time
        y1 (:,m) = y1(:,m)/sqrt(max(real(y1(:,m)))^2 + (max(imag(y1(:,m))))^2); 
    end
else
    y1 = (gendata(numSym, Nqam(1), format));    
end

plot(y1,'*');
title([num2str(Nqam(1)),'-' format ' Constelation']);
axis([-Nqam(1) Nqam(1) -Nqam(1) Nqam(1)]);
xlabel('Re');ylabel('Im');

%% create filter 
switch (shape)
    case 'Rect'
         y3 = rectpulse(y1,sps);
        beta = 0;
    otherwise
        h = rcosdesign(beta, filterOrder/sps, sps, 'normal');   % raised cosine filter
        y2 = upfirdn(y1, h, sps);                               % upsample with sps and filtering
        
        ext_length = length(y2) - sps*length(y1) + 1;           % additional length due to filter's rise and falltime
        
        y3 = y2((ceil(ext_length/2) : length(y2) - floor(ext_length/2)),:);        % cut away filter's rise and falltime  
end


% normalise Y to 1
amplitude = max(max(abs(real(y3(:,1)))),max(abs(imag(y3(:,1)))));
y3 = y3/amplitude;

%power normalization
if strcmp(powN, 'Yes')
    for m = 1:n
            pow = sum(real (y3(:,m)).^2 + imag (y3(:,m)).^2)/length(y3);
            y3(:,m) = y3(:,m)./sqrt(pow);   
    end
end

Y=0;
    for m = 1:n
        Yl = y3.*exp(-1j*Fc(m)*2*pi*(0:length(y3)-1)./sampleRate)'; 
        Y = Yl+Y;
    end
    
%% save signal to file
n=1;%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Nqam = Nqam(1,1:n);
format = 'Modulation_';
for i = log2(min(Nqam)): log2(max(Nqam))
    m= 2^i;
    a = length (find (Nqam == m));
    if a ~= 0
        if m == 2
            nformat = [num2str(a) '_BPSK_'];
        elseif m == 4
            nformat = [num2str(a) '_QPSK_'];
        else
            nformat = [num2str(a) '_' num2str(m) 'QAM_']; 
        end
            format = [format nformat];
    end
end

if strcmp (bit8 , 'Yes')
    Y = int8(Y*127);
end

fileName = [format num2str(symRate*1e-9) 'GBd_PRBS' num2str(polynom) '_'];
    switch (shape)        
        case 'Rect'    
            fileName = [fileName shape '_nChannels_' num2str(n) '_Fgap_0p' num2str(100*GapPercent) 'BW' '_unc_' unc];
        otherwise
            fileName = [fileName 'Raised_Cosine_beta_0p' num2str(100*beta) '_nChannels_' num2str(n) '_Fgap_0p' num2str(100*GapPercent) 'BW' '_unc_' unc];
    end
    
switch saveFile
    
    case 1  %% save for Agilent AWG M8195A
        folder = ['signals/to_AWG/' shape '/PRBS' num2str(polynom) '/'];
		mkdir(folder);
		       
        if length(Y) <= 2^18        
            save([folder fileName], 'Y', 'XDelta', '-v6')
            fprintf(['file saved to: ' folder fileName, '\n']);
        else
            fprintf(['could not save file ' fileName ' due to wrong signal length: ', num2str(length(Y)) ' > ' num2str(2^18) '\n']);
        end
        
    case 2  % save for VSA
        XUnit = 'Sec';
        FreqSample = sampleRate;
        XDelta = 1/FreqSample;
        InputZoom = 1;  
                
        while (length(Y)/sps < 2^13)    % for having at least 8192 Symbols in the recording
           Y = repmat(Y,2,1);
        end
        
        % fit to VSA
        Y1 = single(real(Y));
        Y2 = single(imag(Y));
        Y1(1) = Y1(1)+1e-30*1i;
        Y2(1) = Y2(1)+1e-30*1i;
        

        folder = ['signals/to_VSA/' shape '/PRBS' num2str(polynom)  '/' datestr(date) '/'];
        if exist(folder)==0
                        mkdir(folder);
        end

	
        save([folder fileName])
        fprintf(['file saved to: ' folder fileName, '\n']);
        
    otherwise   % don't save
        fileName = [format '_' num2str(symRate*1e-9) 'GBd_PRBS' num2str(polynom) '_' shape datetime];
        fprintf(['signal generated without saving: ' fileName '\n']);
end