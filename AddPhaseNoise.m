function x = AddPhaseNoise(input, Level, FrequencyOffset)
% Phase noise level in decibels relative to carrier per hertz (dBc/Hz), 
% specified as a vector of negative scalars. 
% Frequency offset in Hz, specified as a vector of positive increasing values.

%%
% Create a phase noise object.
pnoise = comm.PhaseNoise('Level',Level,'FrequencyOffset',FrequencyOffset);

% Apply phase noise and plot the result.
x = step(pnoise, input);
