function [ Predict_label,Real_label, B_ALL, M_B_ALL, MAE, R ] = ...
    Linear_Regression_ElasticNet_MAEandPearson(data,label,lambda,alpha,K)
%次函数精度没有~MSE的高
%利用elastic net来进行特征筛选，建立线性回归模型
%输入：请参考 FeatureSelection_Linear_Regression_ElasticNet
%输出：预测标签，真实标签以及应变量的原始值（用于评价回归性能，Pearson相关系数加mean absolute
%error(MAE)的倒数，注意此二数需要标准化，因为原始数据差异大
%% 数据准备
[N,M]=size(data);
MAE=inf(K,1);
R=zeros(K,1);
B_ALL=NaN(K,M);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% 外层循环 Outer
    waitbar(i/K);
    test_index_out = (indices == i); train_index_out = ~test_index_out;
    train_data_out=data(train_index_out,:);test_data_out=data(test_index_out,:);%外层循环测试样本data and 外层循环训练样本data
    train_label_out=label(train_index_out,:);test_label_out=label(test_index_out,:);%外层循环测试样本label and 外层循环训练样本label
    %% 内层嵌套循环 Inner
    [lambda_best,alpha_best, ~,~]=...
        FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(train_data_out,train_label_out,alpha,lambda,K);
    [B,FitInfo] = lasso(train_data_out,train_label_out,'Alpha',alpha_best,'Lambda',lambda_best);
    % 建立逻辑回归模型并预测外侧测试样本
    B_ALL(i,:)=B;
    M_B_ALL=mean(B_ALL);
    preds =test_data_out*B+ FitInfo.Intercept;
    Predict_label{i}= preds; Real_label{i}=test_label_out;
    MAE(i)=sum(abs(preds-test_label_out))/numel(test_data_out);
    [R(i),~]=corr(preds,test_label_out);
end
close (h)
end

