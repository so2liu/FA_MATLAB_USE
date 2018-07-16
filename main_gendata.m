clear;close all
%% Parameters
ensemble = 1;
iteration = 4096*4;
Length = 4096*4;
N = 16; % If N > 16, filter isn't stable anymore
MSE = zeros(iteration, ensemble);
% IQ Imbalance Parameters
GainIm = 5; % in dB
PhaseIm = 5; % in degree
% Channel Distortion
H = [1.1 + j*0.5, 0.1-j*0.3, -0.2-j*0.1]; % 3 Taps
% Phase Noise
Level = -50;
FrequencyOffset = 10;
% LMS
S = struct('step',0.01,'filterOrderNo',5,'initialCoefficients',zeros(6,1), 'modulationNo', N);
e = 0;

%% Do
for k = 1:ensemble
    [x, data] = GenerateQAMData(Length, N); % Generate Data
    y_desired = x;
%     x = conv(x, H, 'same'); % Channel Distortion
%     x = iqimbal(x, GainIm, PhaseIm); % IQ Imbalance
    x = AddPhaseNoise(x, Level, FrequencyOffset); % Phase Noise
    
    
%     [x, e, w]  =   LMSCompensator(x, y_desired, S); % for channel distortion
%     [x, e, w] = CircularityBasedApproach(x, 1, 1e-5, iteration); % for IQ Imbalance
    MSE(:,k) = e;
end



MSE_av = sum(MSE, 2);

scatterplot(x(S.filterOrderNo:end))
figure;
semilogy(abs(MSE_av))
grid on
grid minor
