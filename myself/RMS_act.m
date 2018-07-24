clear
clc
%fileName='1dB3Degree.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('.\data\1dB7Degree.mat','-mat');
%load('.\data\5GB_withoutfilter.mat','-mat');
%Y=Y1(1:4096)+Y2(1:4096)*1i;
figure;
plot(Y,'.');
%find the positive element, ideal value is 0.707

M=100; %length of filter
oder=10;
dn=zeros(M,1);
ensemble=200;
for i=1:M
    dn(i)=0.707*sign(real(Y(i)))+1j*0.707*sign(imag(Y(i)));
end

% S   =   struct('filterOrderNo',oder,'delta',0.2,'lambda',0.97);
% [outputVector,...
%              errorVector,...
%              coefficientVector,...
%              outputVectorPost,...
%              errorVectorPost] =   RLS(dn,Y(1:M).',S);

S   =   struct('step',0.01,'filterOrderNo',oder,'initialCoefficients',zeros(oder+1,1));
[outputVector,...
             errorVector,...
             coefficientVector] =   LMS(dn,Y(1:M).',S);


%%
yn=zeros(length(Y)-oder,1);
for i=oder+1:length(Y)
    yn(i)=coefficientVector(:,M+1)'*Y(i-oder:i);
end

%%
%presentation
close all;
figure;
thetaVector = -pi:0.01:pi;
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(dn),imag(dn),'ro',...
         'MarkerSize',10,'LineWidth',3);
plot(real(Y),imag(Y),'.',real(yn),imag(yn),'r.');
hold off;
axis([-1.5 1.5 -1.5 1.5]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('OutputVector-Wiener Filter')


