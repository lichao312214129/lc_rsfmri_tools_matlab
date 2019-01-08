function [ Predict_label,Real_label, MAE, R ] = ...
    Linear_Regression_ElasticNet_MAEandPearson_PCA(data,label,lambda,alpha,K)
%利用elastic net来进行特征筛选，建立线性回归模型
%输入：请参考 FeatureSelection_Linear_Regression_ElasticNet
%输出：预测标签，真实标签以及应变量的原始值（用于评价回归性能，Pearson相关系数加mean absolute
%error(MAE)的倒数，注意此二数需要标准化，因为原始数据差异大
%% 数据准备
[N,M]=size(data);
B_ALL=NaN(K,M);
MAE=inf(K,1);
R=zeros(K,1);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% 外层循环 Outer
    waitbar(i/K);
    test_index_out = (indices == i); train_index_out = ~test_index_out;
    train_data=data(train_index_out,:);test_data=data(test_index_out,:);%外层循环测试样本data and 外层循环训练样本data
    train_label=label(train_index_out,:);test_label=label(test_index_out,:);%外层循环测试样本label and 外层循环训练样本label
    %% 降维及归一化
    %按列方向归一化
%     [train_data,test_data,~] = ...
%         scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
%                 [train_data,PS] = mapminmax(train_data');
%                 train_data=train_data';
%                 test_data = mapminmax('apply',test_data',PS);
%                 test_data =test_data';
    %主成分降维
    [COEFF, train_data] = pca(train_data);%分别对训练样本、测试样本进行主成分降维。
    test_data = test_data*COEFF;
    %% 内层嵌套循环 Inner
    [lambda_best,alpha_best, ~,~]=...
        FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(train_data,train_label,alpha,lambda,K);
    [B_PCA,FitInfo] = lasso(train_data,train_label,'Alpha',alpha_best,'Lambda',lambda_best);
    % 建立逻辑回归模型并预测外侧测试样本
    B_OrignalSpace = B_PCA' * COEFF';
    B_ALL(i,:)=B_OrignalSpace;
    preds =test_data*B_PCA+ FitInfo.Intercept;
    Predict_label{i}= preds; Real_label{i}=test_label;
    MAE(i)=sum(abs(preds-test_label))/numel(test_data);
    [R(i),~]=corr(preds,test_label);
end
close (h)
end

