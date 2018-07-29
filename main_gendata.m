clear;close all
%% Parameters
ensemble = 1;
Length = 1e5;
iteration = Length;
M = 16; % If N > 16, filter isn't probably stable anymore
MSE = zeros(iteration, ensemble);
% IQ Imbalance Parameters
GainIm = 1; % in dB if N >= 16, GainIm max is 2.5, otherweise divergence
PhaseIm = 10; % in degree
real_iqim = 10^(0.5*GainIm/20)*exp(-i*0.5*PhaseIm*pi/180);
imag_iqim = 10^(-0.5*GainIm/20)*exp(i*0.5*PhaseIm*pi/180);
% AWGN
PowerAWGN = -30; % in dB 0
% Channel Distortion
H = [1.1 + j*0.5, 0.1-j*0.3, -0.2-j*0.1]; % 3 Taps
% Phase Noise
Level = -40;
FrequencyOffset = 10;
% LMS
S = struct('step',0.001, 'filterOrderNo',11,'initialCoefficients',randn(4,1), 'modulationNo', M);
e = 0;
% Record x's changes
x_record = zeros(Length, 6);
%% Do
w = 0;
for k = 1:ensemble
    [x, data] = GenerateQAMData(Length, M); % Generate Data
    y_desired = x;
    x = conv(x, H, 'same'); % Channel Distortion
    x_record(:,1) = x;
    x = iqimbal(x, GainIm, PhaseIm); % IQ Imbalance
    x_record(:,2) = x;
    x = AddPhaseNoise(x, Level, FrequencyOffset); % Phase Noise
    x_record(:,3) = x;
    x = x+wgn(Length, 1, PowerAWGN, 'complex'); % AWGN
    x_record(:,4) = x;
    dirty_x = x;
    
    [x, e, w]  =  LMSCompensator(x, y_desired, S); % for channel distortion
    x_record(:,5) = x;
    [x, e, w] = CircularityBasedApproach(x, 1, 1e-5, iteration); % for IQ Imbalance
    x_record(:,6) = x;     
    [x_knn, ser] = AddKNNClassifier(x, y_desired);
    ser_no_KNN = size(find(qamdemod(dirty_x, M)-data ~= 0), 1)/length(data);
    MSE(:,k) = e;
end



MSE_av = sum(MSE, 2)/ensemble;

% scatterplot(x(S.filterOrderNo:end))
normalized_x = Normalization(x(S.filterOrderNo:end-4));
Plot16QAM(normalized_x, dirty_x);
PlotWeightChange(transpose(w));
PlotMSEindB(MSE_av);


save('x_record.mat', 'x_record', 'y_desired');
