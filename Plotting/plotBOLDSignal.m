"""
This file is
"""
subplot(2,1,1);
plot(mean(a),'LineWidth',2,'color',[1 0.5 0]);
xlabel('Time Point');
ylabel('BOLD Signal');
box off
% title('ventral rAI');
set(gca,'FontSize',15);%坐标轴字体大小
set(gca,'linewidth',2);%坐标轴粗细
set(gca,'XLim',[0,230]);%x轴范围
% set(gca,'YLim',[0,15]);%y轴范围
%%
subplot(2,1,2);
plot(mean(b),'LineWidth',2,'color',[0 0.5 0]);
xlabel('Time Point');
ylabel('BOLD Signal');
box off
% title('dorsal rAI');
set(gca,'FontSize',15);%坐标轴字体大小
set(gca,'linewidth',2);%坐标轴粗细
set(gca,'XLim',[0,230]);%x轴范围
% set(gca,'YLim',[0,15]);%y轴范围
% 总标题
title=suptitle('Temporal-Domain BOLD Signals');
set(title,'FontSize',20);%坐标轴字体大小