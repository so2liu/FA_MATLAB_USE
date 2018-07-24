y_iq = compSig;
close all

% scatterplot(y_iq(:,1))
% hold on
% for i = [2:82]
%     scatterplot(y_iq(:,i))
% end
figure
plot(y_iq, 'kx');
hold on
theta=-pi:0.1:pi;
constellation=qammod(0:3,4)/sqrt(2);
plot(cos(theta), sin(theta),'r-','LineWidth',0.1);
plot(real(constellation), imag(constellation),'ro','MarkerSize',10,'LineWidth',1);
grid on
xlim([-1.5,1.5]); 
ylim([-1.5,1.5]);
hold off

figure
plot(original, 'k.');
hold on
theta=-pi:0.1:pi;
constellation=qammod(0:3,4)/sqrt(2);
plot(cos(theta), sin(theta),'r-','LineWidth',0.1);
plot(real(constellation), imag(constellation),'ro','MarkerSize',10,'LineWidth',3);
grid on

