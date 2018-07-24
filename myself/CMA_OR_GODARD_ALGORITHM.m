    %IMPLEMENTATION OF BLIND CHANNEL USING CMA OR GODARD ALGORITHM IMPLEMENTED

clc;
clear all;
close all;
N=3000;    % number of sample data
dB=25;     % Signal to noise ratio(dB)

L=20; % smoothing length L+1
ChL=1;  % length of the channel= ChL+1
EqD=round((L+ChL)/2);  %  channel equalization delay

i=sqrt(-1);
%Ch=randn(1,ChL+1)+sqrt(-1)*randn(1,ChL+1);   % complex channel

%%
% %Ch=[0.0545+j*0.05 .2832-.1197*j -.7676+.2788*j -.0641-.0576*j .0566-.2275*j .4063-.0739*j];
 Ch=[0.8+i*0.1 .9-i*0.2]; %complex channel
     Ch=Ch/norm(Ch);% normalize
 TxS=round(rand(1,N))*2-1;  % QPSK symbols are transmitted symbols
 TxS=TxS+sqrt(-1)*(round(rand(1,N))*2-1);
% x=filter(Ch,1,TxS); %channel distortion
% 
% n=randn(1,N)+sqrt(-1)*randn(1,N);   % additive white gaussian noise (complex)
%  n=n/norm(n)*10^(-dB/20)*norm(x);  % scale noise power
% x1=x+n;  % received noisy signal
%%

load('.\data\5GB_withoutfilter.mat','-mat');
x1=Y;
%estimation using CMA
K=N-L;   %% Discard initial samples for avoiding 0's and negative
X=zeros(L+1,K);  %each vector
for i=1:K
    X(:,i)=x1(i+L:-1:i).';
end

e=zeros(1,K);  % to store the error signal
c=zeros(L+1,1); c(EqD)=1;    % initial condition
R2=2;                  % constant modulous of QPSK symbols
mu=0.001;      % step size
for i=1:K
   e(i)=abs(c'*X(:,i))^2-R2;                  % initial error
   c=c-mu*2*e(i)*X(:,i)*X(:,i)'*c;     % update equalizer co-efficients
   c(EqD)=1;
end   
   
sym=c'*X;   % symbol estimation

%calculate SER
H=zeros(L+1,L+ChL+1); 
for i=1:L+1
    H(i,i:i+ChL)=Ch; 
end  % channel matrix
fh=c'*H; % channel equalizer
temp=find(abs(fh)==max(abs(fh))); %find maximum

sb1=sym/(fh(temp));  % normalize the output
 sb1=sign(real(sb1))+sqrt(-1)*sign(imag(sb1));  % perform symbol detection
strt=6;  
sb2=sb1-TxS(strt+1:strt+length(sb1));  % detecting error symbols
SER=length(find(sb2~=0))/length(sb2);% SER calculations
disp(SER);

% plot of transmitted bits
    subplot(2,2,1), 
    plot(TxS,'*');
    grid on,title('Transmitted bits');  xlabel('real'),ylabel('imaginary')
    axis([-3 3 -3 3])
    
% plot of received symbols  
    subplot(2,2,2),
    plot(x1,'.');
    grid on, title('Received symbols');  xlabel('real'), ylabel('imaginary')

 % plot of the equalized symbols
    subplot(2,2,3),
    plot(sym,'.');
    grid on, title('After Equalization'), xlabel('real'), ylabel('imaginary')

% convergence of algorithm
    subplot(2,2,4),
    plot(abs(e));   
    grid on, title('Convergence'), xlabel('n'), ylabel('error signal');
    axis([0 2000 0 4]);