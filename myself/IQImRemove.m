clear
clc
%fileName='matlab_manuell.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('1dB3Degree.mat','-mat');


hScope = comm.ConstellationDiagram(...
    'SymbolsToDisplaySource','Property', ...
    'SymbolsToDisplay',4096);
% Create an I/Q imbalance compensator. 
hIQComp = comm.IQImbalanceCompensator;

step(hScope,Y)

compSig = step(hIQComp,Y);
step(hScope,compSig)
figure;
plot(real(Y),imag(Y),'.', real(compSig),imag(compSig),'.');
