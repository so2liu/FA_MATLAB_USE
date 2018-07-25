close all
clear
PowerAWGN = -30;
Length = 1000;
Fs = 1000;
t = 0:1/Fs:1-1/Fs;
x = 5*cos(2*pi*300*t);
% x = x + wgn(Length, 1, PowerAWGN); % AWGN
x = awgn(x, 10, 'measured');
[Pxx,F] = periodogram(x,[],length(x),Fs);
Pxx = 10*log10(Pxx);
plot(F,Pxx)
xlim([-100,1000])
figure
plot(x)
figure
plot(fft(x))
grid minor
save('awgn', 'F', 'Pxx')