clear;close all
%% Parameters
ensemble = 100;
iteration = 1000;
Length = 1000;
N = 4; % If N > 16, filter isn't stable anymore
MSE = zeros(iteration, ensemble);
% IQ Imbalance Parameters
GainIm = 5; % in dB
PhaseIm = 5; % in degree
% AWGN
PowerAWGN = -20;
% Channel Distortion
H = [1.1 + j*0.5, 0.1-j*0.3, -0.2-j*0.1]; % 3 Taps
% Phase Noise
Level = -50;
FrequencyOffset = 10;
% LMS
S = struct('step',0.001,'filterOrderNo',7,'initialCoefficients',randn(8,1), 'modulationNo', N);
e = 0;

%% Do
for k = 1:ensemble
    [x, data] = GenerateQAMData(Length, N); % Generate Data
    y_desired = x;
    x = conv(x, H, 'same'); % Channel Distortion
    x = x+wgn(Length, 1, PowerAWGN, 'complex'); % AWGN
%     x = iqimbal(x, GainIm, PhaseIm); % IQ Imbalance
%     x = AddPhaseNoise(x, Level, FrequencyOffset); % Phase Noise
    
    dirty_x = x;
    
    [x, e, w]  =   ModifiedCMA(x, S); % for channel distortion
%     [x, e, w] = CircularityBasedApproach(x, 1, 1e-5, iteration); % for IQ Imbalance
    MSE(:,k) = e;
end



MSE_av = sum(MSE, 2)/ensemble;

% scatterplot(x(S.filterOrderNo:end))
normalized_x = Normalization(x(S.filterOrderNo:end-4));
Plot4QAM(normalized_x, dirty_x);
PlotWeightChange(transpose(w));
PlotMSEindB(MSE_av);

