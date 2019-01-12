Mean=Mean';
Std=Std';
h = bar(1:2,Mean,0.7);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
x_kedu=f(get(h,{'xoffset','xdata'}));%获取每一个柱状图中线的x坐标。
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std是误差矩阵
ax = gca;
ax.XTickLabels = {'Occipital-Mid-L',...
    'Postcentral-L'};%改为你需要的横坐标名称，比如age/education等等
set(ax,'Fontsize',10);%设置ax标尺大小
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[0 Yrang_max+Yrang_max/3];%设置y轴范围
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%设置x轴范围
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('','FontName',' ','FontSize',10);
h=legend('HC','MDD','BD','SZ','Location','NorthOutside');
set(h,'Orientation','horizon')
title('Nodal Degree');
% axis off
box off


