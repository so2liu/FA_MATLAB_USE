close all; clear;
% not work and wait for github answer
% generate data with phase noise
original_signal = gendata(999, 16, 'QAM');
data_svm2 = ones(size(original_signal));
for k = 1:length(original_signal)
    if abs(original_signal(k)) < 0
        data_svm2(k) = 0;
    end
end
pnoise = comm.PhaseNoise('Level',-50,'FrequencyOffset',20);
distorted_data = step(pnoise, original_signal);
scatterplot(distorted_data);


%% RVM for classification
X = transpose([real(distorted_data), imag(distorted_data)]);
[model, llh] = rvmBinFp(X, transpose(data_svm2));
% Input:
%   X: d x n data matrix
%   t: 1 x n label (0/1)
%   alpha: prior parameter
% Output:
%   model: trained model structure
%   llh: loglikelihood
plot(llh);
y = rvmBinPred(model,X)+1;
figure;
binPlot(model,X,y);
