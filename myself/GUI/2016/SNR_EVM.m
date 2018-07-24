% prove IQ_remover filter can only remove IQ Imbalance,
% it will do nothing to AWGN
% it will reduce EVM from 'IQ Im without filter' to
% 'IQ Im with Filter', which is almost same as without IQ Imbalance

clear
close all

excel=xlsread('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\SNR_EVM.xlsx');
evm_rx=excel(12:17,1:4);
evm_flt=excel(1:6,1:4);

plot(evm_rx(:,1),evm_rx(:,3))
hold on
% plot(evm_rx(:,1),evm_rx(:,4))


plot(evm_flt(:,1),evm_flt(:,3),'-o')
plot(evm_flt(:,1),evm_flt(:,4),'-s')
legend('Ideal Signal','with Filter','IQ Im without Filter','IQ Im with Filter');
title('Before/After Compensator Constellation with 3dB/3dB IQ Imbanlance')
% xlabel('SNR/dB') % x-axis label
xlabel('EbNo/dB') % x-axis label
ylabel('EVM/%') % y-axis label
grid on; grid minor;
%% constellation plot EbNo=10dB

load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\snr_evm\snr_10.mat','Y');
scatterplot(Y)
hold on

thetaVector = -pi:0.1:pi+0.1;
constellation = qammod(0:3, 4)/sqrt(2);       % symbols from 4-QAM constellation   
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',0.1);
plot(real(constellation),imag(constellation),'ro',...
                     'MarkerSize',10,'LineWidth',1);
hold off
grid on; grid minor;
xlim([-1.2 1.2])
ylim([-1.2 1.2])
title('Constellation with 3dB/3dB IQ Im, EbNo=10dB')

load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\snr_evm\snr_10_after.mat','compSig');
scatterplot(compSig)
hold on
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',0.1);
plot(real(constellation),imag(constellation),'ro',...
                     'MarkerSize',10,'LineWidth',1);
hold off
grid on; grid minor;
xlim([-1.2 1.2])
ylim([-1.2 1.2])
title('After Compensator Constellation with 3dB/3dB IQ Im, EbNo=10dB')

%% constellation plot EbNo=30dB

load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\snr_evm\snr_30.mat','Y');
scatterplot(Y)
hold on

plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',0.1);
plot(real(constellation),imag(constellation),'ro',...
                     'MarkerSize',10,'LineWidth',1);
hold off
grid on; grid minor;
xlim([-1.2 1.2])
ylim([-1.2 1.2])
title('Constellation with 3dB/3dB IQ Im, EbNo=30dB')

load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\snr_evm\snr_30_after.mat','compSig');
figure
hold on
grid on
plot(compSig,'r.')
plot(Y,'.')
% scatterplot(compSig)
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',0.1);
plot(real(constellation),imag(constellation),'ro',...
                     'MarkerSize',10,'LineWidth',1);
hold off
grid on; grid minor;
xlim([-1.2 1.2])
ylim([-1.2 1.2])
xlabel('In-Phase')
ylabel('Quadrature')
title('After Compensator Constellation with 3dB/3dB IQ Im, EbNo=30dB')
