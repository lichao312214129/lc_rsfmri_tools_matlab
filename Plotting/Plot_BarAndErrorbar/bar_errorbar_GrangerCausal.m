function  bar_errorbar_GrangerCausal( Matrix_Patients, Matrix_Controls )
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
% figure('color','k');
x = 1:size(Matrix_Patients,2);
Mean=[mean(Matrix_Patients,1);mean(Matrix_Controls,1)]';
Std=[std(Matrix_Patients);std(Matrix_Controls)]';
h = bar(x,Mean,0.5,'EdgeColor','k','LineWidth',1);
h(1).FaceColor=[.3 .3 .3];h(2).FaceColor=[.7 .7 .7];
% h(1).Visible='off';h(2).Visible='off';
% set(gca,'YTick',-0.01:0.00001:0.02);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
hold on
e=errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','MarkerSize',0.001,'linewidth',1,'Color','k');%Std是误差矩阵
ax = gca;
box off
ax.XTick =  1:size(Matrix_Patients,1);
% ax.XTickLabels = ...
%     {'left Cerebelum_Crus1','right Cerebelum_Crus1',...
%      'left cerebelum_6','left precuneus',...
%      'left postcentral gyrus(extending to bilateral precuneus)',...
%      'right orbitofrontal cortex','left orbitofrontal cortex',...
%      'bilatrel precuneus','left postcentral gyrus(extending to left precuneus)'};
ax.XTickLabels = {[]};
set(ax,'Fontsize',15);%设置ax标尺大小
% set(ax,'ytick',-0.1:0.05:0.1);
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[-0.1 0.1];%设置y轴范围
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%设置x轴范围
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('Causal influence','FontName','Times New Roman','FontWeight','bold','FontSize',15);
%%
h=legend('patients','controls');%根据需要修改
set(h,'Fontsize',10);%设置legend字体大小
h.Location='best';
set(h,'Orientation','horizon');
% grid on
% grid minor
%% save mean performances as .tif figure
% print(gcf,'-dtiff','-r300','figure')
end

