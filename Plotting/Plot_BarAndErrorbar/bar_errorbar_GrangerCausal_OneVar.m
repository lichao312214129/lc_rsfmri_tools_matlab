function  bar_errorbar_GrangerCausal_OneVar( Matrix)
%此函数用来绘制带有误差的柱状图，同时标记双样本t检验的p值,目前的代只适用与两组被试。
%input:
% Matrix_Patients为病人的变量矩阵，比如有病人组被试数=N，且有2个变量（age，education）
% 那么该变量矩阵应该是一个N行2列的矩阵；以下是一个矩阵的表格形式；
%            age     education
% subject1    15         9
% subject2    20         12
% .           .           . 
% .           .           .
% .           .           .
% subjectN    16         15
%那么输入的矩阵形式为[15 20 . . . 16;9  12 . . . 15]
%类似的输入对照组的变量矩阵
x = 1:size(Matrix,2);
Mean=mean(Matrix,1)';
Std=std(Matrix)';
h = bar(x,Mean,0.6,'EdgeColor','k','LineWidth',1);
h.FaceColor=[.5 .5 .5];h.EdgeColor='k';
% h.Visible='off';
set(gca,'YTick',0:0.2:1);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
hold on
errorbar(f(get(h,{'xoffset','xdata'})),get(h,'ydata').',...
           Std,'s','MarkerSize',0.0001,'linewidth',1,'Color','k');%Std是误差矩阵
% errorbar(f(get(h,{'xoffset','xdata'})),...
%     cell2mat(get(h,'ydata')).',Std,pos)%Std是误差矩阵
ax = gca;
box off
ax.XTickLabels ={'Accuracy','Sensitivity', 'Specificity', 'PPV', 'NPV','AUC'};
set(ax,'Fontsize',15);%设置ax标尺大小
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 30;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[-0.1 0.1];%设置y轴范围
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%设置x轴范围
% xlabel('variables','FontName','Times New Roman','FontSize',20);
% ylabel('Performance','FontName','Times New Roman','FontWeight','normal','FontSize',40);
%%
% h=legend('Mean','Standard deviation');%根据需要修改
% set(h,'Fontsize',15);%设置legend字体大小
% set(h,'Box','on');
% h.Location='best';
grid on
% grid minor
end

