function  [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC]=...
    RFE_MultiSubFeature(train_data,train_label, test_data, test_label,opt)
%% =======================函数说明=========================
% 用途： 对RFE后，排名靠前的若干个sub-feature 进行机器学习建模及预测
% input:
% train_data/train_label=训练样本集训练样本标签,可以为多个或者一个
% N_start:N_step:N_end=初始特征数目：每次增加的特征数目：最多的特征数目
% opt:参数，参考相应代码：FeatureSelection_RFE_SVM
%output： 若干个分类性能，其size与前面若干sub-feature对应
%% =======================RFE特征筛选=====================
[ f_ind ] = FeatureSelection_RFE_SVM( train_data,train_label,opt);
%% =======================多个sub-feature的建模及预测==============
count=0;
for N_X=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity
    count= count+1;
    model = fitclinear(train_data(:,f_ind(1:N_X)),train_label,'Learner',opt.learner);
    [predicted_lable{count,1},decision] = predict( model,test_data(:,f_ind(1:N_X)));
    Decision{count,1} = decision(:,1);
    %% =======================分类性能====================
    if iscell(predicted_lable(count,1));predict_temp=cell2mat(predicted_lable(count,1));end
    [Accuracy(count),Sensitivity(count),Specificity(count),PPV(count),NPV(count)]=Calculate_Performances(predict_temp,test_label);
    [AUC(count)]=AUC_LC(test_label,Decision{count,1});
end
end
