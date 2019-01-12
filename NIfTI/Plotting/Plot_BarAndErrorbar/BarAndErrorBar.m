function BarAndErrorBar( data_c,data_p_f,data_p_s)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
%此函数用来绘制带有误差的柱状图。
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
%那么输入的矩阵形式为[15; 20; . . . 16, 9;  12; . . . 15]
%类似的输入对照组的变量矩阵
x = 1:size(data_c,2);
Mean=[mean(data_c,1);mean(data_p_f,1);mean(data_p_s,1)]';%均值。
Std=[std(data_c,1);std(data_p_f,1);std(data_p_s,1)]';
h = bar(x,Mean,0.4);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
x_kedu=f(get(h,{'xoffset','xdata'}));%获取每一个柱状图中线的x坐标。
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std是误差矩阵
ax = gca;
ax.XTickLabels = {'Accuracy','Sensitivity','Specificity','AUC'};%改为你需要的横坐标名称，比如age/education等等
set(ax,'Fontsize',10);%设置ax标尺大小
ax.XTickLabelRotation = 0;
% Yrang_max=max(max(Mean + Std));
% ax.YLim=[0 Yrang_max+Yrang_max/3];%设置y轴范围
% ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%设置x轴范围
% xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('','FontName',' ','FontSize',10);
%% 画连线+标星号，此部分为研究特一的，以后的版本会改为通用版
% %画连线1
% line([x_kedu(3,1),x_kedu(3,2)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/3,...
%     Mean(3,2)+(Mean(3,2)-Mean(3,1))/3],'color','k','LineWidth',2);%画连接线
% text(x_kedu(3,1)+(x_kedu(3,2)-x_kedu(3,1))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/1.5,'*',...
%     'Fontsize',30,'color','k');%有统计学差异，标上星号,由于MATLAB位置误差，bar的正负会影响分母的大小（2）。
% %画连线2
% line([x_kedu(3,2),x_kedu(3,3)],[Mean(3,2)+(Mean(3,2)-Mean(3,1))/3,...
%     Mean(3,2)+(Mean(3,2)-Mean(3,1))/3],'color','k','LineWidth',2);%画连接线  
% text(x_kedu(3,2)+(x_kedu(3,3)-x_kedu(3,2))/4,Mean(3,2)+(Mean(3,2)-Mean(3,1))/1.5,'*',...
%     'Fontsize',30,'color','r');%有统计学差异，标上星号。
% %画连线3
% line([x_kedu(4,1),x_kedu(4,2)],[Mean(4,2)+(Mean(4,2)-Mean(4,1))/2,...
%     Mean(4,2)+(Mean(4,2)-Mean(4,1))/2],'color','k','LineWidth',2);%画连接线  
% text(x_kedu(4,1)+(x_kedu(4,2)-x_kedu(4,1))/4,Mean(4,2)+(Mean(4,2)-Mean(4,1))/1.8,'*',...
%     'Fontsize',30,'color','k');%有统计学差异，标上星号。
% %画连线4
% line([x_kedu(7,1),x_kedu(7,2)],[Mean(7,2)+(Mean(7,2)-Mean(7,1))/3,...
%     Mean(7,2)+(Mean(7,2)-Mean(7,1))/3],'color','k','LineWidth',2);%画连接线
% text(x_kedu(7,1)+(x_kedu(7,2)-x_kedu(7,1))/4,Mean(7,2)+(Mean(7,2)-Mean(7,1))/1.5,'*',...
%     'Fontsize',30,'color','k');%有统计学差异，标上星号。
% %画连线5
% line([x_kedu(8,1),x_kedu(8,2)],[Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.5,...
%     Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.5],'color','k','LineWidth',2);%画连接线  
% text(x_kedu(8,1)+(x_kedu(8,2)-x_kedu(8,1))/4,Mean(8,2)+(Mean(8,2)-Mean(8,1))/2.3,'*',...
%     'Fontsize',30,'color','k');%有统计学差异，标上星号,由于MATLAB位置误差，bar的正负会影响分母的大小（4.5）。
%% set
% h=legend('对照组','颈型颈椎病患者（治疗前）','颈型颈椎病患者（治疗后）');%根据需要修改
% set(h,'Fontsize',10);%设置legend字体大小
% h.Location='northeast';
% h.Orientation='horizon';
% grid on

end

