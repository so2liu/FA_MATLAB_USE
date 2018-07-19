function PlotMSEinDifferentTap (p)
figure

p = mag2db(p);
p = movmean(p,11);
s = size(p);
x = ndgrid(1:s(1),1:s(2));
axh = axes( 'NextPlot','add'); % colors
plot(axh,x,p); % plot lines
% lnh = plot(axh,x.',p.','.k'); % plot markers
% set(lnh,{'Marker'},{'*';'^';'+';'d'})
grid on 
grid minor
xlabel('Iteration');
ylabel('MSE in dB');

leg = [];
for k=1:size(p,1)
  leg{k}=sprintf('Filter Length No. %d',2*k-1);
end
legend(leg);