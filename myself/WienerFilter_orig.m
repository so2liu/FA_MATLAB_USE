clear
clc
%fileName='1dB3Degree.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('.\data\1dB3Degree.mat','-mat');
L=5
d=zeros(L,1);
for k=1:L
    d(k)=sign(real(Y(k)))+1i*sign(imag(Y(k)));
end

R=xcorr(Y(1:L),2);
p=xcorr(d,Y(1:L),2);
R=R*R';
w_o=inv(R)*p;

yn=Y(1:9)'*w_o;

plot(yn,'.');