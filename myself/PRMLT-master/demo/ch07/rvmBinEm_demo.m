%% RVM for classification
clear; close all
k = 2;
d = 2;
n = 1000;
[X,t] = kmeansRnd(d,k,n);

[model, llh] = rvmBinEm(X,t-1);
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
