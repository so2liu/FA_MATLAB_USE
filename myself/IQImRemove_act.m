clear
clc
%fileName='1dB3Degree.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('C:\Users\st144690\Documents\MATLAB\myself\data\5GB_withoutfilter.mat','-mat');

%Y=Y1(1:4096)+Y2(1:4096)*1i;
figure;
plot(Y,'.');
%find the positive element, ideal value is 0.707

dn=qammod(0:3, 4)/sqrt(2);
M=100; %length of filter

xn_c1=[];
xn_c2=[];
xn_c3=[];
xn_c4=[];

for k=1:length(Y)
    if ((real(Y(k))>0) && (imag(Y(k))>0))
        xn_c1=[xn_c1;Y(k)];
    elseif ((real(Y(k))>0) && (imag(Y(k))<0))
        xn_c2=[xn_c2;Y(k)];
    elseif ((real(Y(k))<0) && (imag(Y(k))<0))
        xn_c3=[xn_c3;Y(k)];
    elseif ((real(Y(k))<0) && (imag(Y(k))>0))
        xn_c4=[xn_c4;Y(k)];
    end 
end

%%
%error of original data
% figure;
% subplot(2,2,1)
% plot(20*log(abs(xn_c1-(0.707+0.707*1i))),'r') ;
% subplot(2,2,2)
% plot(20*log(abs(xn_c2-(0.707-0.707*1i))),'g') ;
% subplot(2,2,3)
% plot(20*log(abs(xn_c3-(-0.707-0.707*1i))),'b') ;
% subplot(2,2,4)
% plot(20*log(abs(xn_c4-(-0.707+0.707*1i))),'c') ;

%%

[yn1,W_r1,W_i1,error_r1,error_i1,error1]=IQImRemover (xn_c1,dn(1),M);
[yn2,W_r2,W_i2,error_r2,error_i2,error2]=IQImRemover (xn_c2,dn(2),M);
[yn3,W_r3,W_i3,error_r3,error_i3,error3]=IQImRemover (xn_c3,dn(3),M);
[yn4,W_r4,W_i4,error_r4,error_i4,error4]=IQImRemover (xn_c4,dn(4),M);
 
%% convergence speed

% nstep=1;
% error=error1(1:5*M)+error2(1:5*M)+error3(1:5*M)+error4(1:5*M);
% while error(M+nstep)>1e-6
%     nstep=nstep+1;
% end
% figure;
% 
% subplot(2,1,2);
% %plot([1:50],20*log10(abs(error_r1(1:50))),[1:50],20*log10(abs(error_r2(1:50))),...
% %     [1:50],20*log10(abs(error_r3(1:50))),[1:50],20*log10(abs(error_r4(1:50))),...
% %     [1:50],20*log10(abs(error_i1(1:50))),[1:50],20*log10(abs(error_i2(1:50))),...
% %     [1:50],20*log10(abs(error_i3(1:50))),[1:50],20*log10(abs(error_i4(1:50))));
% 
% n=nstep+20;
% plot([M:M+n],20*log10(abs(error1(M:M+n))),'r',[M:M+n],20*log10(abs(error2(M:M+n))),'g',...
%      [M:M+n],20*log10(abs(error3(M:M+n))),'b',[M:M+n],20*log10(abs(error4(M:M+n))),'c')
% xlabel('Step');
% ylabel('Error in dB');
% 

%%
%subplot(2,1,1);

%%
%presentation
close all;
figure;
thetaVector = -pi:0.01:pi;
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(dn),imag(dn),'ro',...
         'MarkerSize',10,'LineWidth',3);
plot(real(Y),imag(Y),'.',real(yn1),imag(yn1),'.',real(yn2),imag(yn2),...
'.',real(yn3),imag(yn3),'.',real(yn4),imag(yn4),'.'...
);
hold off;
axis([-1.5 1.5 -1.5 1.5]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('OutputVector-Wiener Filter')
