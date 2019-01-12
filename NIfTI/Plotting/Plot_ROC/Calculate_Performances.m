function [accuracy,sensitivity,specificity,PPV,NPV]=Calculate_Performances(Predict_label,Real_label)
%计算模型的预测表现。
% Predict_label=Predict_label==1;Real_label=Real_label==Real_label;%将非1设为0.
% Predict_label=reshape(Predict_label,length(Predict_label),1);%变成行向量.
% Real_label=reshape(Real_label,length(Real_label),1);%变成行向量.
% tic
%     P=find(Real_label==1); N=find(Real_label==0);
%     P1=find(Predict_label==1); N1=find(Predict_label==0);
%     P=reshape(P,length(P),1);N=reshape(N,length(N),1);P1=reshape(P1,length(P1),1);N1=reshape(N1,length(N1),1);
%     TP=size(intersect(P,P1),1); TN=size(intersect(N,N1),1); FP=size(intersect(N,P1),1); FN=size(intersect(P,N1),1);
%     Accuracy =(TP+TN)/(TP + FN + TN + FP); %定义
%     Sensitivity =TP/(TP + FN);
%     Specificity =TN/(TN + FP); 
%% next is to calculate the performances.....
Predict_label=Predict_label==1;Real_label=Real_label==Real_label;%将非1设为0.
Predict_label=reshape(Predict_label,length(Predict_label),1);%变成行向量.
Real_label=reshape(Real_label,length(Real_label),1);%变成行向量.
tic
TP=sum(Real_label.*Predict_label);
FN=sum(Real_label)-sum(Real_label.*Predict_label);
TN=sum((Real_label==0).*(Predict_label==0));
FP=sum(Real_label==0)-sum((Real_label==0).*(Predict_label==0));
    accuracy =(TP+TN)/(TP + FN + TN + FP); %定义
    sensitivity =TP/(TP + FN);
    specificity =TN/(TN + FP); 
    PPV=TP/(TP+FP);%positive predictive
    NPV=TN/(TN+FN);%negative predictive value
%% performance of model with difference features'combination ordered have obtained.
end

