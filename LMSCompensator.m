function [y, e, w] = LMSCompensator(x, d, S)
% S = struct('step',0.1,'filterOrderNo',5,'initialCoefficients',zeros(6,1), 'modulationNo', 64);

mu = S.step;
M = S.modulationNo;
N = S.filterOrderNo;
trainlen = 100;
refData = d;

eqlms = lineareq(N, lms(mu)); % Create an equalizer object.
eqlms.SigConst = step(comm.RectangularQAMModulator(M),(0:M-1)')';
% Maintain continuity between calls to equalize.
eqlms.ResetBeforeFiltering = 0;

% Equalize the received signal, in pieces.
equalize(eqlms, x, refData(1:trainlen));  %equalize(object,rx data,ref data)
y = equalize(eqlms,x); % Full output of equalizer
w = eqlms.Weights;
e = 0;


