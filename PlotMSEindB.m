function PlotMSEindB (x)
figure
y = mag2db(abs(x));
plot(y);
grid on;
grid minor
xlabel('Iteration');
ylabel('MSE in dB');