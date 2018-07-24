clear all
close all
clc

load('C:\Users\st144690\Documents\MATLAB\myself\data\5GB_withoutfilter.mat','-mat');
Data=Y(1:100);
refData=Data(1:100);
for k=1:length(Data)
    refData(k)=sign(real(Data(k)))+1j*sign(imag(Data(k)));
end
refData=0.707*refData;

refData_r=real(refData);
refData_i=imag(refData);
Data_r=real(Data);
Data_i=imag(Data);

%%
%   Computing:
ensemble=200;
N=2;
K=100;
mu=0.1;
Wr       = ones(N,(K+1),ensemble);   % coefficient vector for each iteration and realization; w(0) = [1 1 1 1].'
Wi       = rand(N,(K+1),ensemble);   % coefficient vector for each iteration and realization; w(0) = [1 1 1 1].'

for l=1:ensemble,

    Sr   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',Wr(:,1,l));
    [y_r,e_r,Wr(:,:,l)]  =   LMS(refData_r,transpose(Data_r),Sr);

    Si   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',Wi(:,1,l));
    [y_i,e_i,Wi(:,:,l)]  =   LMS(refData_i,transpose(Data_i),Si);
    
end
W_av_r = sum(Wr,3)/ensemble;
W_av_i = sum(Wi,3)/ensemble;


%%
figure;
plot(Y,'.');
figure;
plot(W_av_r,'.');
figure;
plot(y_r+1j*y_i,'.');
% L=length(Y);
% item=Y;
% for k=1:L
%     Y(k)=item(L+1-k);
% end
% Y=W_av_r(101)*real(Y)+1j*W_av_i(101)*imag(Y);
% plot(Y,'.')