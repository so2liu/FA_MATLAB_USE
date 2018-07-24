clc;
clear;close all;
load('.\data\5GB_withoutfilter.mat','-mat');

L=20; % smoothing length L+1
ChL=3;  % length of the channel= ChL+1
N=length(Y);
EqD=round((L+ChL)/2);  %  channel equalization delay
constellation = qammod(0:3, 4)/sqrt(2);       % symbols from 4-QAM constellation
%%
%estimation using CMA
K=N-L;   %% Discard initial samples for avoiding 0's and negative
X=zeros(L+1,K);  %each vector
for i=1:K
    X(:,i)=Y(i+L:-1:i).';
end

e=zeros(1,K);  % to store the error signal
c=zeros(L+1,1); 
c(EqD)=1;    % initial condition

R2=2;                  % constant modulous of QPSK symbols
mu=0.00001;      % step size

for em=1:200
for i=1:K
   e(i)=abs(c'*X(:,i))^2-R2;                  % initial error
   c=c-mu*2*e(i)*X(:,i)*X(:,i)'*c;     % update equalizer co-efficients
end  
end 
%%

sym=c'*X;   % symbol estimation

%%
%presentation
figure;
thetaVector = -pi:0.01:pi;
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(constellation),imag(constellation),'ro',...
         'MarkerSize',10,'LineWidth',3);
plot(real(Y),imag(Y),'.',real(sym),imag(sym),'.');
hold off;
axis([-2 2 -2 2]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('equlizerOutputVector')

