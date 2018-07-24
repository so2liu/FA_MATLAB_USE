%% Remove I/Q Imbalance from a QAM Signal
% Remove an I/Q imbalance from a 64-QAM signal and to make the estimated
% coefficients externally available while setting the algorithm step size
% from an input port.
%%
% Create 64-QAM modulator and constellation diagram System objects.
% Apply the |constellation| function to the modulator to determine its
% reference constellation. Use name-value pairs to ensure that the
% constellation diagram displays only the last 256 data symbols, set the
% axes limits, and specify the reference constellation.

% Copyright 2015 The MathWorks, Inc.
clear;
close all
load('5gb_after_lms.mat');
% equalizerOutputVector=equalizerOutputVector';

M = 4; % Modulation order
hMod = comm.RectangularQAMModulator(M);
refC = constellation(hMod);
hScope = comm.ConstellationDiagram(...
    'SymbolsToDisplaySource','Property', ...
    'SymbolsToDisplay',1024, ...
    'XLimits',[-3 3],'YLimits',[-3 3], ...
    'ReferenceConstellation',refC,'SamplesPerSymbol',1);
%%
% Create an I/Q imbalance compensator System object in which the step size
% is specified as an input argument to the |step| function and the
% estimated coefficients are made available through an output port.
hIQComp = comm.IQImbalanceCompensator('StepSizeSource','Input port', ...
    'CoefficientOutputPort',true);

%%
% Apply amplitude and phase imbalance to the transmitted signal.
% ampImb = 2; % dB
% phImb = 10; % deg
% gainI = 10.^(0.5*ampImb/20);
% gainQ = 10.^(-0.5*ampImb/20);
% imbI = real(txSig)*gainI*exp(-0.5i*phImb*pi/180);
% imbQ = imag(txSig)*gainQ*exp(1i*(pi/2 + 0.5*phImb*pi/180));
% rxSig = imbI + imbQ;
%%
% Plot the constellation diagram of the received signal.
step(hScope,equalizerOutputVector);
%%
% Specify the step size parameter for the I/Q imbalance compensator.
stepSize = 1e-2;
%%
% Apply the step function to compensate for the I/Q imbalance while setting
% the step size via an input argument. You can see that the compensated
% signal constellation is now nearly aligned with the reference
% constellation.
[compSig,estCoef] = step(hIQComp,equalizerOutputVector,stepSize);
step(hScope,compSig)
%%
% Plot the real and imaginary values of the estimated coefficients. You can
% see that they reach a steady-state solution.
% plot((1:nSym)'/1000,[real(estCoef),imag(estCoef)])
% grid
% xlabel('Symbols (thousands)')
% ylabel('Coefficient Value')
% legend('Real','Imag','location','best')

