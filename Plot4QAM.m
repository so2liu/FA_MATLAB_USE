function Plot4QAM(input, dirty_x)
dirty_x = dirty_x./mean(abs(dirty_x));
thetaVector = -pi:0.1:pi;
constellation = qammod(0:3, 4)/sqrt(2);       % symbols from 4-QAM constellation
MAX = max(max(real(dirty_x)),max(real(dirty_x)));
figure(2);
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(input),imag(input),'bx');
plot(real(dirty_x),imag(dirty_x),'k.');
plot(real(constellation),imag(constellation),'ro',...
         'MarkerSize',10,'LineWidth',3);
hold off;
axis([-MAX MAX -MAX MAX]*1.2);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');