function [ Predict_label,Real_label, B_ALL,  M_B_ALL, MAE, R ] = ...
    Linear_Regression_ElasticNet_MSE_PCA(data,label,lambda,alpha,K)
%注意：当应用PCA降维时，如果特征大于样本则预测不准确，特征<=样本时准确性不错。所以PCA不恰当，请慎重应用。
%利用elastic net来进行特征筛选，建立线性回归模型
%输入：请参考 FeatureSelection_Linear_Regression_ElasticNet
%输出：预测标签，真实标签以及应变量的原始值（用于评价回归性能，Pearson相关系数加mean absolute
%error(MAE)的倒数，注意此二数需要标准化，因为原始数据差异大
%% 数据准备
%K=5;
% data=rand(100,50);r=[1;2;3;4;5;6;7;8;9;zeros(50-9,1)];label=data*r;
% lambda=exp(-6:6);alpha=0.1:0.1:1;
[N,M]=size(data);
B_ALL=NaN(K,M);
MAE=inf(K,1);
R=zeros(K,1);
indices = crossvalind('Kfold', N, K);
Predict_label=cell(K,1); Real_label=cell(K,1);
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c');
for i = 1:K
    %% 外层循环
    waitbar(i/K);
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%外层循环测试样本data and 外层循环训练样本data
    train_label=label(train_index,:);test_label=label(test_index,:);%外层循环测试样本label and 外层循环训练样本label
    %% 降维及归一化
    %按列方向归一化
    %     [train_data,test_data,~] = ...
    %         scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
%     [train_data,PS] = mapminmax(train_data');
%     train_data=train_data';
%     test_data = mapminmax('apply',test_data',PS);
%     test_data =test_data';
    %主成分降维
    [COEFF, train_data] = pca(train_data);%分别对训练样本、测试样本进行主成分降维。
%     train_data=train_data(:,1:10);
    test_data = test_data*COEFF;
%     test_data=test_data(:,1:10);
%         [train_data,PS] = mapminmax(train_data');
%     train_data=train_data';
%     test_data = mapminmax('apply',test_data',PS);
%     test_data =test_data';
    %% 内层嵌套循环
    [ ~,~,~,B_PCA, Intercept_final] =...
        FeatureSelection_Linear_Regression_ElasticNet_MSE(train_data,train_label,lambda,alpha,K);
    %%
    % 建立逻辑回归模型并预测外侧测试样本
    B_OrignalSpace = B_PCA' * COEFF';
    B_ALL(i,:)=B_OrignalSpace;
    M_B_ALL=mean(B_ALL);
    preds =test_data*B_PCA+ Intercept_final;
    Predict_label{i}= preds; Real_label{i}=test_label;
    MAE(i)=sum(abs(preds-test_label))/numel(test_data);
    [R(i),~]=corr(preds,test_label);
end
close (h)
end

