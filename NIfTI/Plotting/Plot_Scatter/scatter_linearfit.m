function scatter_linearfit(x,y,title1)
%散点图及最小二乘拟合直线
%input：两列序列，必要时可以输入标题
if nargin ==2
    title1='scatter figure and fitting linear';
end
sz = 120;%marker大小
%figure;
h=scatter(x,y,sz,'Marker','o',...
        'MarkerEdgeColor',[.3 .3 .3],'MarkerFaceColor','w','LineWidth',3);

% scatter(x,y,sz,'Marker','o',...
%         'MarkerEdgeColor',[0.2 0.8 0.7],'MarkerFaceColor','w','LineWidth',2);
h1=lsline;
set(h1,'LineWidth',2,'LineStyle','-','Color',[.5 .5 .5])
set(gca,'FontSize',30);%坐标轴字体大小
set(gca,'linewidth',2);%坐标轴粗细
set(gca,'XColor','black');set(gca,'YColor','black');%坐标轴的颜色
set(gca,'XLim',[-1,1]);%x轴范围
set(gca,'YLim',[0,15]);%y轴范围
% axis square %方形坐标框
axis normal %自动调整坐标框
title(title1,'fontname','Times New Roman','Color','k','FontSize',20);%标题
% grid on;
% saveas(gcf,['title1','.tif'])
end
