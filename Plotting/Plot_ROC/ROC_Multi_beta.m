function  ROC_Multi_beta( Label_All,Decision_All,Name_legend )
%此代码用来画多个ROC曲线
%输入：Label_All=所有的样本label，例如病人为1，正常对照组为0；Decision_All=所有的样本得分。
%输入Label_All,Decision_All的具体格式：M行N列，其中M为变量个数，N为样本个数
%for example：Label_All=[1 0 0 1;1 1 0 0],表示Label_All是2行4列，即2个变量，4个样本。
%输出：为多个ROC曲线
%本代码最多支持10个变量，如有需要请自行修改。
%=======================================
% 现在用一个例子来告诉大家怎么用：
% 1、假设你想看看样本的5个变量对于100样本（50个病人，50个对照）的分类表现（ROC曲线）如何；
% 2、先随机生产5行100列的数据，每一行都对应某个变量情况下所有样本的标签（病人=1，对照=0）
% ：Label_All=[ones(5,50),zeros(5,50)];  Decision_All=normrnd(0.5,0.3,[5,100]);
% 3、输入5个变量的名字：Name_legend={'血糖','血脂','血压','年龄','性别'};
% 4、最后一步就是把代码：ROC_Multi_alpa( Label_All,Decision_All
% )’复制到MATLAB的命令行窗口，回车即可运行产生ROC图像。
%%
Num_ROC=size(Label_All,1);
LineStyle={'-','--o','-','--o','-','--o','-','--o','-','--o'};
ColorMap={'r','r','g','g','b','b','c','c','m','m'};
% Name_legend={'legend1','legend2','legend3','legend4','legend5','legend6','legend7','legend8','legend9','legend10'};
for j=1:Num_ROC
    label=Label_All(j,:);
    Decision=-Decision_All(j,:);
    label(label~=1)=0;%将label中不为1的数，变为0。因而，对于多分类，此代码需要修改。
    label=reshape(label,length(label),1);Decision=reshape(Decision,length(Decision),1);%reshape
    %%
    %计算不同decision时的敏感度和特异度。
    sensitivity=zeros(length(label),1);specificity=zeros(length(label),1);%预留空间。
    for i=1:length(label)
       Decision_tem=Decision;
       Decision_tem(Decision_tem>=Decision(i))=1;Decision_tem(Decision_tem<Decision(i))=0;%将Decion_temp转换为0，1。
       sensitivity(i)=sum(label.*Decision_tem)/sum(label);
       specificity(i)=sum((label==0).*(Decision_tem==0))/sum(label==0);
    end
    Order=[1-specificity,sensitivity];
    Order=sort(Order);
    plot(Order(:,1),Order(:,2),char(LineStyle(j)),'color',ColorMap{j},...
    'LineWidth',2)
%     'MarkerSize',8,...
%     'MarkerEdgeColor','r',...
%     'MarkerFaceColor',[0.5,0.5,0.5]);%g为颜色，-为线型。
hold on;
end
ylabel('sensitivity','FontName','Times New Roman','FontWeight','bold','FontSize',25);
xlabel('1-specificity','FontName','Times New Roman','FontWeight','bold','FontSize',25);
set(gca,'Fontsize',30);%设置坐标标尺大小
axis([-0.1 1 0 1]);%设置坐标轴在指定的区间.
fig=legend(Name_legend,'Location','NorthEastOutside');
set(fig,'Fontsize',30);%设置legend字体大小
end

