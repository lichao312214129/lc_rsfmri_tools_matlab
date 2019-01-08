function  [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC]=...
    Ttest2_MultiSubFeature(train_data,train_label, test_data, test_label, p_start, p_step, p_end,opt)
%% =======================函数说明=========================
% 用途： 对Ttest2后，不同p值得若干个sub-feature 进行机器学习建模及预测
% input:
    % train_data/train_label=训练样本集训练样本标签,可以为多个或者一个
    % p_start:p_step:p_end=初始p值：每次增加的p值：最大的p值
    % opt:参数，参考相应代码：FeatureSelection_RFE_SVM
%output： 若干个分类性能，其size与前面若干sub-feature对应
%% ============================分组==============================
data_p = train_data(train_label==1,:);
data_hc = train_data(train_label==-1,:);
%% ============================Ttest2特征筛选=====================
[~,pvalue]=ttest2( data_p, data_hc);
%% =======================多个sub-feature的建模及预测==============
count=0;
for p_thrd=p_start:p_step:p_end
    count= count+1;
    f_ind=pvalue<=p_thrd;
    model = fitclinear(train_data(:,f_ind),train_label,'Learner',opt.learner);
    [predicted_lable{count,1},decision] = predict( model,test_data(:,f_ind));
    Decision{count,1} = decision(:,1);
    %% =======================分类性能====================
    if iscell(predicted_lable(count,1));predict_temp=cell2mat(predicted_lable(count,1));end
    [Accuracy(count),Sensitivity(count),Specificity(count),PPV(count),NPV(count)]=Calculate_Performances(predict_temp,test_label);
    [AUC(count)]=AUC_LC(test_label,Decision{count,1});
end
end
