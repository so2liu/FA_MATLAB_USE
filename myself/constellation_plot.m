function constellation_plot(original, flted)
figure
plot(original, 'kx');
hold on
theta=-pi:0.1:pi;
constellation=qammod(0:3,4)/sqrt(2);
plot(cos(theta), sin(theta),'r-','LineWidth',0.1);
plot(real(constellation), imag(constellation),'ro','MarkerSize',10,'LineWidth',3);

plot(flted, '.');
grid on
grid minor

