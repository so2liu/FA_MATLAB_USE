% CHANNEL EQUALIZATION USING LMS 
clc;
clear all;
close all;
M=3000;    % number of data samples
T=2000;    % number of training symbols
dB=25;     % SNR in dB value

L=200; % length for smoothing(L+1)
ChL=5;  % length of the channel(ChL+1)
EqD=round((L+ChL)/2);  %delay for equalization

Ch=randn(1,ChL+1)+sqrt(-1)*randn(1,ChL+1);   % complex channel
Ch=Ch/norm(Ch);                     % scale the channel with norm

TxS=round(rand(1,M))*2-1;  % QPSK transmitted sequence
TxS=TxS+sqrt(-1)*(round(rand(1,M))*2-1);


x=filter(Ch,1,TxS);  %channel distortion
n=randn(1,M) +sqrt(-1)*randn(1,M);   %Additive white gaussian noise
 n=n/norm(n)*10^(-dB/20)*norm(x);  % scale the noise power in accordance with SNR
x=x+n;                           % received noisy signal

K=M-L;   %% Discarding several starting samples for avoiding 0's and negative
X=zeros(L+1,K);  % each vector column is a sample
for i=1:K
    X(:,i)=x(i+L:-1:i).';
end

%%
%adaptive LMS Equalizer
e=zeros(1,T-10);  % initial error
c=zeros(L+1,1);   % initial condition
mu=0.001;        % step size
for i=1:T-10
    e(i)=TxS(i+L+10-EqD)-c'*X(:,i+10);   % instant error
    c=c+mu*conj(e(i))*X(:,i+10);           % update filter or equalizer coefficient
end

%%
% e=zeros(1,T-L);  % initial error
% c=zeros(L+1,1);   % initial condition
% mu=0.001;        % step size
% for i=1:T-L
%     e(i)=TxS(i+L)-c'*X(:,i);
% %     TxS(i+L)
% %     X(:,i)
%     c=c+mu*conj(e(i))*X(:,i);
% end

%%
sb=c'*X;   % recieved symbol estimation

%SER(decision part)
sb1=sb/norm(c);  % normalize the output
sb1=sign(real(sb1))+sqrt(-1)*sign(imag(sb1));  %symbol detection
start=7;  
sb2=sb1-TxS(start+1:start+length(sb1));  % error detection
SER=length(find(sb2~=0))/length(sb2); %  SER calculation
disp(SER);

% plot of transmitted symbols
    subplot(2,2,1), 
    plot(TxS,'*');   
    grid,title('Input symbols');  xlabel('real part'),ylabel('imaginary part')
    axis([-2 2 -2 2])
    
% plot of received symbols
    subplot(2,2,2),
    plot(x,'.');
    grid, title('Received samples');  xlabel('real part'), ylabel('imaginary part')

% plots of the equalized symbols    
    subplot(2,2,3),
    plot(sb,'.');   
    grid, title('Equalized symbols'), xlabel('real part'), ylabel('imaginary part')

% convergence
    subplot(2,2,4),
    plot(abs(e));   
    grid, title('Convergence'), xlabel('n'), ylabel('error signal')
 