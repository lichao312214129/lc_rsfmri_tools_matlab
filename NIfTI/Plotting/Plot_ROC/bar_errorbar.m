function  bar_errorbar( Matrix_Patients, Matrix_Controls )
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
x = 1:size(Matrix_Patients,2);
Mean=[mean(Matrix_Patients,1);mean(Matrix_Controls,1)]';
Std=[std(Matrix_Patients);std(Matrix_Controls)]';
h = bar(x,Mean,0.4);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
hold on
errorbar(f(get(h,{'xoffset','xdata'})),...
    cell2mat(get(h,'ydata')).',Std,'.','linewidth',1)%Std是误差矩阵
ax = gca;
% ax.XTick =  1:size(Matrix_Patients,1);
ax.XTickLabels = {'age','education'};%改为你需要的横坐标名称，比如age/education等等
set(ax,'Fontsize',18);%设置ax标尺大小
ax.XTickLabelRotation = 45;
Yrang_max=max(max(Mean + Std));
ax.YLim=[0 Yrang_max+Yrang_max/3];%设置y轴范围
ax.XLim=[0.6 size(Matrix_Patients,2)+0.4];%设置x轴范围
xlabel('variables','FontName','Times New Roman','FontSize',20);
ylabel('mean ± std','FontName','Times New Roman','FontSize',20);
%%
% %划线
% loc=f(get(h,{'xoffset','xdata'}));%每个柱子的中点x坐标
% plot([loc(1,1),loc(1,2)],....
%     [max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)]),max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)])]);
% plot([loc(2,1),loc(2,2)],....
%     [max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)]),max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])]);
%%
[~,p]=ttest2(Matrix_Patients, Matrix_Controls);%双样本t检验。
txt1 = text(0.90, max([Mean(1,1)+Std(1,1),Mean(1,2)+Std(1,2)])+Std(1,1)/4, strcat('p=',num2str(p(1))), 'rotation', 0);  %在柱状图上面显示p值
txt2 = text(1.90, max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])+Std(2,2)/4, strcat('p=',num2str(p(2))), 'rotation', 0);  
% txt3 = text(2.90, max([Mean(3,1)+Std(3,1),Mean(3,2)+Std(3,2)])+Std(3,2)/4, strcat('p=',num2str(p(3))), 'rotation', 0);  
% txt4 = text(3.90, max([Mean(4,1)+Std(4,1),Mean(4,2)+Std(4,2)])+Std(4,2)/4, strcat('p=',num2str(p(4))), 'rotation', 0);  
% txt5 = text(4.90, max([Mean(2,1)+Std(2,1),Mean(2,2)+Std(2,2)])+Std(2,2)/4, 'P=b', 'rotation', 0);   
set(txt1, 'fontsize', 15);  
set(txt2, 'fontsize', 15);  
% set(txt3, 'fontsize', 15);  
% set(txt4, 'fontsize', 15); 
% set(txt5, 'fontsize', 15); 
h=legend('patients','controls');%根据需要修改
set(h,'Fontsize',20);%设置legend字体大小
grid on
end

