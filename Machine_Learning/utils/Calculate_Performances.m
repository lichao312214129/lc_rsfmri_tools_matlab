function [accuracy,sensitivity,specificity,PPV,NPV]=Calculate_Performances(predict_label,real_label)
%计算模型的预测表现
%输入;预测标签和真实标签
%输出：各分类性能;PPV：阳性预测率；NPV：阴性预测率
%% 计算性能
% 数据准备
% 将非1设为0.
predict_label=predict_label==1;
real_label=real_label==1;
% 变成行向量.
predict_label=reshape(predict_label,length(predict_label),1);
real_label=reshape(real_label,length(real_label),1);
% 计算
TP=sum(real_label.*predict_label);
FN=sum(real_label)-sum(real_label.*predict_label);
TN=sum((real_label==0).*(predict_label==0));
FP=sum(real_label==0)-sum((real_label==0).*(predict_label==0));
    accuracy =(TP+TN)/(TP + FN + TN + FP); %定义
    sensitivity =TP/(TP + FN);
    specificity =TN/(TN + FP); 
    PPV=TP/(TP+FP);%positive predictive
    NPV=TN/(TN+FN);%negative predictive value
end

