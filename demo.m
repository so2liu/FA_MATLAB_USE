% w1 = w(1,1:end-1);
% w2 = w(1,2:end);
% p1 = [real(w1) imag(w1)];                         % First Point
% p2 = [real(w2) imag(w2)];                         % Second Point
% dp = p2-p1;                         % Difference
% 
% figure(1)
% quiver(p1,p2,dp,0)
% grid
% axis([-10  10    -10  10])
% text(p1(1),p1(2), sprintf('(%.0f,%.0f)',p1))
% text(p2(1),p2(2), sprintf('(%.0f,%.0f)',p2))

% arrowPlot(real(w(1,:)), imag(w(1,:)))


% plot_dir(transpose(real(w(1,:))), transpose(imag(w(1,:))))
figure
% arrowPlot(real(w(4,:)), imag(w(4,:)), 'number', 5, 'color', 'k', 'LineWidth', 1, 'scale', 1.4, 'ratio', 'equal')
plot(real(w(2,:)), imag(w(2,:)))
grid on
grid minor