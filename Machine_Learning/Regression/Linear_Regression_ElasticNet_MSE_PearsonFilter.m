function [ Predict_label,Real_label, B_ALL, M_B_ALL, MAE, R, r ] = ...
    Linear_Regression_ElasticNet_MSE_PearsonFilter(data,label,lambda,alpha,K)
% !!!需要修改
%此函数精度最准，但是运行较慢，一般特征少于一万可以用。
%利用elastic net来进行特征筛选，建立线性回归模型
%输入：请参考 FeatureSelection_Linear_Regression_ElasticNet
%输出:
%example
% data=rand(100,500);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(500-34,1)];
%label=data*r;
%lambda=exp(-6:6);alpha=0.1:0.1:1;
%[ Predict_label{1},Real_label{1}]
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
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%外层循环测试样本data and 外层循环训练样本data
    train_label=label(train_index,:);test_label=label(test_index,:);%外层循环测试样本label and 外层循环训练样本label
    %% 特征初筛
    [r,P]=corr(train_data, train_label);%pearson correlation;
    Index=find(r>0.2);%将小于等于某个P值得特征选择出来。
    train_data= train_data(:,Index);
    test_data=test_data(:,Index);
%     train_data= sum(train_data,2);
%     test_data= sum(test_data,2);
    %% 内层嵌套循环 Inner :特征精筛
    [ ~,~,~,B_final, Intercept_final] =...
        FeatureSelection_Linear_Regression_ElasticNet_MSE(train_data,train_label,lambda,alpha,K);
    %%
    % 建立逻辑回归模型并预测外侧测试样本
        B_ALL(i,Index)=B_final;
        M_B_ALL=mean(B_ALL);
    preds =test_data*B_final+ Intercept_final;
    Predict_label{i}= preds; Real_label{i}=test_label;
        MAE(i)=sum(abs(preds-test_label))/numel(test_data);
        [R(i),~]=corr(preds,test_label);
end
close (h)
end

