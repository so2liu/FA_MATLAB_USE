function PlotWeightChange (p)
figure

p = abs(p);
s = size(p);
x = ndgrid(1:s(1),1:s(2));
axh = axes('ColorOrder',[0,0,1;0,1,0;1,0,0], 'NextPlot','add'); % colors
plot(axh,x,p); % plot lines
% lnh = plot(axh,x.',p.','.k'); % plot markers
% set(lnh,{'Marker'},{'*';'^';'+';'d'})
grid on 
grid minor
xlabel('Iteration');
ylabel('Weight Vector Change');

leg = [];
for k=1:size(p,1)
  leg{k}=sprintf('Weight No. %d',k);
end
legend(leg);
