% x1 = [0:.1:40]; 
% y1 = 4.*cos(x1)./(x1+2); 
% x2 = [1:.2:20]; 
% y2 = x2.^2./x2.^3; 
close all
N=107;
m=10;%move
s=1;%start

V_BE_5=[V_BE5,g3_bjt5];
V_BE_5=V_BE_5(s+m:m+length(V_BE_2(:,1)),:);
V_BE_2=[V_BE2,g3_bjt2];

figure
% hl1 = line(V_BE_2(:,1),V_BE_2(:,2),'Color','c'); 
ax1 = gca; 
set(ax1,'YLim',[-30 60],'XTick',0.72:0.02:0.84); 
hl1 = line(V_BE_2(:,1),V_BE_2(:,2),'Color','m','LineWidth',2.5); 
legend('y = sin(x)','y = cos(x)','southwest')

% figure
% hl_1 = line(V_BE_2(:,1),V_BE_2(:,2),'Color','c','Parent',ax1); 
ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','left',...
           'Color','none',...
           'XColor','k','YColor','k','XTick',0.8:0.02:0.96);
hl2 = line(V_BE_5(:,1),V_BE_5(:,2),'Color','b','LineWidth',2.5,'Parent',ax2); 

avg=[V_BE_2(:,1),(V_BE_5(:,2)+V_BE_2(:,2))/2];
hl3=line(avg(:,1),avg(:,2),'Color','r','LineStyle','--','LineWidth',2.5,'Parent',ax1); 
grid on
title('Graph of Sine and Cosine Between -2\pi and 2\pi')
xlabel('-2\pi < x < 2\pi') % x-axis label
ylabel('sine and cosine values') % y-axis label
% legend('y = sin(x)','y = cos(x)','southwest')
