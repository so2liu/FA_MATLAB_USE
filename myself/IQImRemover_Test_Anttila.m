clear
clc
%fileName='1dB3Degree.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('.\data\1dB3Degree.mat','-mat');


K=length(Y);
M=10;
w=ones(M,1);
xn=Y;
Mstep=0.00001;
n=0;
yn=ones(K,1);
for k=M:K
    x=xn(K:-1:K-M+1);
    y=yn(K:-1:K-M+1);
    yn(k)=x(1)+w'*conj(x);
    w=w-Mstep*y*yn(k);
    n=n+1;
end

yn=zeros(size(xn));
for k=M:K
    x=xn(k:-1:k-M+1);
    yn(k)=w'*x;
end
plot(yn,'.')

