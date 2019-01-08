function [OptimalPred,AUC_All]=PlotROC_LC(RealLabel,Pred,opt)
%用途： 画ROC曲线
% input:
%    RealLabel=真实的应变量值；
%    Pred=预测的应变量值或者直接是自变量的值;
% output：
 %    OptimalPred=最佳的Preds;
 %    AUC_All: 预测的所有decision和真是label得到的AUC
% new:当有多个最佳约登指数时，本代码根据特异度和敏感度的最小绝对差值来做决定，2018-04-02 By Lichao
%% 橘黄色[1 0.5 0]  深绿色[0 0.5 0]
if nargin<3
    opt.roc_type='-o';
    opt.dot_type='o';
    opt.color=[1 0.5 0];
    opt.LineWidth=2;
    opt.MarkerSize=3;
    opt.MarkerEdgeColor=[1 0.5 0];
    opt.MarkerFaceColor='w';
    opt.plotOptimum=0;
end
%% 将label中不为1的数，变为0。因而，对于多分类，此代码需要修改。AND reshape
RealLabel=RealLabel==1;
RealLabel=reshape(RealLabel,length(RealLabel),1);
Pred=reshape(Pred,length(Pred),1);
%% 测试正负decision时的AUC大小，选择大的AUC时的decision
AUC_pos=AUC_LC(RealLabel,Pred);
AUC_neg=AUC_LC(RealLabel,-Pred);
if AUC_pos< AUC_neg
    Pred=-Pred;
    AUC_All=AUC_neg;
else 
    AUC_All=AUC_pos;
end
%% 计算不同decision时的敏感度和特异度。
sensitivity=zeros(length(RealLabel),1);specificity=zeros(length(RealLabel),1);%预留空间。
for i=1:length(RealLabel)
    Decision_tem=Pred;
    Decision_tem=Decision_tem>=Pred(i);%将Decion_temp转换为0，1。
    sensitivity(i)=sum(RealLabel.*Decision_tem)/sum(RealLabel);
    specificity(i)=sum((RealLabel==0).*(Decision_tem==0))/sum(RealLabel==0);
end
Order_original=[1-specificity,sensitivity];
Order_sorted=sort(Order_original);
%% 根据约登指数选择
YuedengIndex=specificity+sensitivity-1;
locOfOptimalPred=find(YuedengIndex==max(YuedengIndex));
if numel(locOfOptimalPred)>1
    dif=abs(specificity(locOfOptimalPred)-sensitivity(locOfOptimalPred));
    locSmallDif=dif==min(dif);
%     locGreaterThanPointSeven=find(specificity(locOfOptimalPred)>0.7&&sensitivity(locOfOptimalPred)>0.7);
    locOfOptimalPred=locOfOptimalPred(locSmallDif);
%     if specificity(locOfSmallDifPred_Origin)< 0.7 || sensitivity(locOfSmallDifPred_Origin)< 0.7
%         
%     end
    fprintf('存在多个最佳特征值,本代码根据特异度和敏感度的最小绝对差值，选取第%d位置特征值最为最佳特征值',locOfOptimalPred(1));
end
OptimalPred=Pred(locOfOptimalPred(1));
%% plot optimum dot
if opt.plotOptimum
plot(Order_original(locOfOptimalPred,1),Order_original(locOfOptimalPred,2),opt.dot_type,...
    'LineWidth',opt.LineWidth,...
    'MarkerSize',opt.MarkerSize+1,...
    'MarkerEdgeColor',opt.MarkerEdgeColor,...
    'MarkerFaceColor',opt.MarkerFaceColor);%g为颜色，-为线型。);
text(Order_original(locOfOptimalPred,1)+0.02,Order_original(locOfOptimalPred,2)-0.1,...
    ['specificity = ',num2str(1-Order_original(locOfOptimalPred,1),'%.2f'),char(10),...
    'sensitivity = ',num2str(Order_original(locOfOptimalPred,2),'%.2f')],...
    'FontSize',12)
% text(Order_original(locOfOptimalPred,1)+0.02,Order_original(locOfOptimalPred,2)-0.1,...
%     ['specificity = ',num2str(1-Order_original(locOfOptimalPred,1),'%.2f'),char(10),...
%     'sensitivity = ',num2str(Order_original(locOfOptimalPred,2),'%.2f'),char(10),...
%      'AUC = ',num2str(AUC,'%.2f')],...
%     'FontSize',12)
hold on;
end
%% plot ROC curve
plot(Order_sorted(:,1),Order_sorted(:,2),opt.roc_type,'color',opt.color,...
    'LineWidth',opt.LineWidth,...
    'MarkerSize',opt.MarkerSize,...
    'MarkerEdgeColor',opt.MarkerEdgeColor,...
    'MarkerFaceColor',opt.MarkerFaceColor);%g为颜色，-为线型。);
xlabel('1-Specificity');
ylabel('Sensitivity');
set(gca,'Fontsize',14);%设置坐标标尺大小
box off
axis([-0.1 1 0 1]);%设置坐标轴在指定的区间.
% xlabel('1-specificity','FontName','Times New Roman','FontWeight','bold''FontSize',25);
% ylabel('sensitivity','FontName','Times New Roman','FontWeight','bold','FontSize',25);
hold off;
end

