close all; clear;
%% generate data w/o impairment
M = 16;
original_signal = gendata(255, M, 'QAM');
data_svm16 = qamdemod(original_signal, 16);
data_svm4 = dec2bin(data_svm16);
% data_svm4 = zeros(256,1);
% for k = 1:length(original_signal)
%     if imag(original_signal(k)) < -2
%         data_svm4(k) = 1;
%     elseif imag(original_signal(k)) > 2
%         data_svm4(k) = 2;
%     end
% end

%% data with impairments
distorted_data = original_signal;
% Phase Noise
pnoise = comm.PhaseNoise('Level',-40,'FrequencyOffset',20);
distorted_data = step(pnoise, distorted_data);
% IQ Imbalance
% distorted_data = iqimbal(distorted_data, 30, 10);
% Multipath
% H = [0.32+0.21*1j,-0.3+0.7*1j,0.5-0.8*1j,0.2+0.5*1j].';
% distorted_data = conv(H, distorted_data);
% distorted_data = distorted_data(4:length(distorted_data));

gscatter(real(distorted_data), imag(distorted_data), data_svm4);
%% SVM
% X = [real(distorted_data), imag(distorted_data)];
% y = data_svm2;
% SVMModel = fitcsvm(X,y);
% sv = SVMModel.SupportVectors;
% figure
% gscatter(X(:,1),X(:,2),y)
% hold on
% % plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
% legend('versicolor','virginica','Support Vector')
% hold off
% Y = num2cell(data_svm4);
Y = cell(size(distorted_data,1), log2(M));
double_Y = zeros(size(distorted_data,1), log2(M));
for k = 1:log2(M)
    double_Y(:,k) = str2num(data_svm4(:,k));
end
for k = 1:log2(M)
    Y (:,k) = num2str(double_Y);
end

X = [real(distorted_data), imag(distorted_data)];

tic;
classes = unique(Y(:,1));
rng(1); % For reproducibility
SVMModels = cell(log2(M),1);

for j = 1:log2(M);
    indx = strcmp(Y(:,j),1); % Create binary classes for each classifier
    SVMModels{j} = fitcsvm(X,indx,'ClassNames',[false true],'Standardize',true,...
        'KernelFunction','rbf','BoxConstraint',1);
end
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

toc;
%%
% Color in the regions of the plot based on which class the
% corresponding new observation belongs.

figure
color = rand(16,3);
% color = [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1];
% color = [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1;...
%         0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1;...
%         0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1];
h(1:numel(classes)) = gscatter(xGrid(:,1),xGrid(:,2),maxScore, color);
hold on
h(numel(classes)+1:2*numel(classes)) = gscatter(X(:,1),X(:,2),Y);
title('{\bf SVM Training Result}');
xlabel('In-Phase');
ylabel('Quadrature');
legend(h,{'setosa region','versicolor region','virginica region',...
    'observed setosa','observed versicolor','observed virginica'},...
    'Location','Southeast');
axis tight
hold off