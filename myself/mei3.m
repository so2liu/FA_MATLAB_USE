V_BE_2_f=[V_BE_2(:,1)+0.1*ones(size(V_BE_2(:,1))),V_BE_2(:,2)];
N=30;
figure
ax1 = gca; 
set(ax1,'YLim',[-30 60],'FontSize',N,'XTick',0.72:0.02:0.86); 
% hl3 = line(V_BE_2(:,1),V_BE_2(:,2),'Color','m','LineWidth',2.5); 
xlabel('$$Vbe_{aux}/V$$','FontSize',N,'Interpreter', 'Latex','FontWeight','bold','Color','b') % x-axis label


ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','left',...
           'Color','none',...
           'XColor','b','YColor','k','FontSize',N,'XTick',0.8:0.02:0.96);
% ax2.YLim=-30:10:60;
hl2 = line(V_BE_5(:,1),V_BE_5(:,2),'Color','b','LineWidth',2.5,'Parent',ax2); 
hl1 = line(V_BE_2_f(:,1),V_BE_2_f(:,2),'Color','m','LineWidth',2.5,'Parent',ax2); 

avg=[V_BE_2_f(:,1),(V_BE_5(:,2)+V_BE_2(:,2))/2];
hl3=line(avg(:,1),avg(:,2),'Color','r','LineStyle','--','LineWidth',2.5,'Parent',ax2); 
grid on
title('Graph of Sine and Cosine Between -2\pi and 2\pi')
xlabel('$$Vbe_{main}/V$$','Interpreter', 'Latex','FontSize',N,'FontWeight','bold','Color','b') % x-axis label
ylabel('gm3/ $$mA\over {V^3}$$','Interpreter', 'Latex','FontWeight','bold') % y-axis label
% legend('y = sin(x)','y = cos(x)','southwest')
% legend('y = sin(x)','y = cos(x)','southwest')
