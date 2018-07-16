function [signal, data] = GenerateQAMData(numSym, Nqam)

data = randi([0 Nqam-1],numSym,1);
signal = qammod(data, Nqam);
