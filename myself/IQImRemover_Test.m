clear
clc
%fileName='1dB3Degree.mat';
%data='Y';
%sampleFreq=16e9;
%centerFreq=0;
%savevsarecording(fileName, data, sampleFreq, centerFreq); %savevsarecording(fileName, data, sampleFreq, centerFreq)

load('2dB7Degree.mat','-mat');

rxSig=Y;

hMod = comm.QPSKModulator;
hScope = comm.ConstellationDiagram(...
    'SymbolsToDisplaySource','Property', ...
    'SymbolsToDisplay',2048);

%%
% Create an I/Q imbalance compensator. 
hIQComp = comm.IQImbalanceCompensator;

%%
% Plot the constellation diagram of the received signal. Observe that the
% received signal experienced an amplitude and phase shift.
step(hScope,rxSig);
%%
% Apply the I/Q compensation algorithm and view the constellation. The
% compensated signal constellation is nearly aligned with the reference
% constellation.
compSig = step(hIQComp,rxSig);
step(hScope,compSig)


