function [ Predict_label,Real_label, B_ALL,  M_B_ALL, MAE, R ] = ...
          Linear_Regression_ElasticNet_MSE(data,label,lambda,alpha,K)
%此函数精度最准，但是运行较慢，一般特征少于一万可以用。
%利用elastic net来进行特征筛选，建立线性回归模型
%输入：请参考 FeatureSelection_Linear_Regression_ElasticNet
%输出：预测标签，真实标签以及应变量的原始值（用于评价回归性能，Pearson相关系数加mean absolute
%error(MAE)的倒数，注意此二数需要标准化，因为原始数据差异大
%example
% data=rand(100,100);r=rand(100,1)*5; label=data*r+rand(100,1)*0.2;
% 
% lambda=logspace(-5,-1,15);;alpha=0.1:0.1:1;K=3;
%lambda=exp(-5:5);
%  [ Predict_label,Real_label];
%[a,b]=sort(M_B_ALL,'descend');
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
    %% 外层循环
    waitbar(i/K);
    test_index_out = (indices == i); train_index_out = ~test_index_out;
    train_data_out=data(train_index_out,:);test_data_out=data(test_index_out,:);%外层循环测试样本data and 外层循环训练样本data
    train_label_out=label(train_index_out,:);test_label_out=label(test_index_out,:);%外层循环测试样本label and 外层循环训练样本label
    %%
    MeanValue = mean(train_data_out);
    StandardDeviation = std(train_data_out);
    [row_quantity, columns_quantity] = size(train_data_out);
    Train_data_temp=zeros(row_quantity, columns_quantity);
    for ii = 1:columns_quantity
        if StandardDeviation(ii)
            Train_data_temp(:, ii) = (train_data_out(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
        end
    end
    Test_data_temp = (test_data_out - MeanValue) ./ StandardDeviation;
    train_data_out=Train_data_temp;test_data_out=Test_data_temp;
    %% 内层嵌套循环
        [ ~,~,~,B_final, Intercept_final] =...
         FeatureSelection_Linear_Regression_ElasticNet_MSE(train_data_out,train_label_out,lambda,alpha,K);
    %%
      % 建立逻辑回归模型并预测外侧测试样本
      B_ALL(i,:)=B_final;
      M_B_ALL=mean(B_ALL);
      B0=B_final;
      preds =test_data_out*B0+ Intercept_final;
      Predict_label{i}= preds; Real_label{i}=test_label_out; 
      MAE(i)=sum(abs(preds-test_label_out))/numel(test_label_out);
     [R(i),~]=corr(preds,test_label_out);
end
Predict_label=cell2mat(Predict_label); Real_label=cell2mat(Real_label);
close (h)
 MAE_ALL=sum(abs(Predict_label-Real_label))/numel(Real_label)
  [R_ALL,~]=corr(Predict_label,Real_label)
end

