function [signal, y_goal] = GenerateQAMData(numSym, Nqam)

y_goal = randi([0 Nqam-1],numSym,1);
signal = qammod(y_goal, Nqam);
