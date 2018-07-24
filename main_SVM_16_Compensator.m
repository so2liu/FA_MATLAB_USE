close all; clear;
%% generate data w/o impairment
M = 16;
N = 1024;
original_signal = gendata(N, M, 'QAM');
data_svm4 = qamdemod(original_signal, M);
color_background = [141,211,199; 255,255,179;190,186,218;251,128,114;128,177,211;
         253,180,98;179,222,105;252,205,229;217,217,217;188,128,189;
         204,235,197;255,237,111]/256;
%% data with impairments
distorted_data = original_signal;

% Phase Noise
pnoise = comm.PhaseNoise('Level',-40,'FrequencyOffset',20);
distorted_data = step(pnoise, distorted_data);

% IQ Imbalance
% distorted_data = iqimbal(distorted_data, 30, 10);

% Multipath
% H = [0.32+0.21*1j,-0.3+0.7*1j].';
% H = H/mean(abs(H));
% distorted_data = conv(H, distorted_data);
% distorted_data = distorted_data(length(distorted_data)-N:length(distorted_data));

% Rotation
theta = 30; % to rotate 90 counterclockwise
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
X = [real(distorted_data), imag(distorted_data)];
X = X*R;
gscatter(X(:,1), X(:,2), data_svm4);
%%
load('x_record.mat');
X = [real(x_record(1025:2048,2)), imag(x_record(1025:2048,2))];
data_svm4 = qamdemod(y_desired(1025:2048,1), M);

%% SVM
Y = cellstr(num2str(data_svm4));

tic;
classes = unique(Y);
rng(1); % For reproducibility
SVMModels = cell(numel(classes),1);

for j = 1:numel(classes);
    indx = strcmp(Y,classes(j)); % Create binary classes for each classifier
    SVMModels{j} = fitcsvm(X,indx,...
        'ClassNames',[false true],'Standardize',true,...
        'KernelFunction','rbf','BoxConstraint',3,...
        'KernelScale', 0.5);
end
toc;
%%
% |SVMModels| is a 3-by-1 cell array, with each cell containing a
% |ClassificationSVM| classifier.  For each cell, the positive class is
% setosa, versicolor, and virginica, respectively.
%%
% Define a fine grid within the plot, and treat the coordinates as new observations
% from the distribution of the training data.  Estimate the score of the new
% observations using each classifier.
d = 0.02;
[x1Grid,x2Grid] = meshgrid(min(X(:,1)):d:max(X(:,1)),...
    min(X(:,2)):d:max(X(:,2)));
xGrid = [x1Grid(:),x2Grid(:)];
N = size(xGrid,1);
Scores = zeros(N,numel(classes));

for j = 1:numel(classes);
    [~,score] = predict(SVMModels{j},xGrid);
    Scores(:,j) = score(:,2); % Second column contains positive-class scores
end
%%
% Each row of |Scores| contains three scores.  The index of the element
% with the largest score is the index of the class to which the new class
% observation most likely belongs.
%%
% Associate each new observation with the classifier that gives it the
% maximum score.  
[~,maxScore] = max(Scores,[],2);

%%
% Color in the regions of the plot based on which class the
% corresponding new observation belongs.

figure
color = rand(16,3);
% color = [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1];
% color = [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1;...
%         0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1;...
%         0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1];
h(1:numel(classes)) = gscatter(xGrid(:,1),xGrid(:,2),maxScore, color_background);
hold on
h(numel(classes)+1:2*numel(classes)) = gscatter(X(:,1),X(:,2),Y, 'k');
title('{\bf SVM Training Result}');
xlabel('In-Phase');
ylabel('Quadrature');
axis tight
hold off