function [ Predict_label,Real_label,B0,Decision ] = ...
          Logistic_Regression_ElasticNet_Kfold(data,label,lambda,alpha,K)
%利用elastic net来进行特征筛选，建立逻辑回归模型
%输入：请参考 FeatureSelection_Logistic_Regression_ElasticNet
%输出：预测标签，真实标签以及应变量的原始值（用于ROC）
%example
% data=rand(100,50);r=[1;2;3;4;5;6;7;8;9;8;7;6;5;4;3;2;1;1;2;3;4;5;6;7;8;9;9;8;7;6;5;4;3;21;zeros(50-34,1)];
%label=data*r;
%lambda=exp(-6:6);alpha=0.5:0.1:1;K=5;
%[ cell2mat(Predict_label),cell2mat(Real_label)]
%for i=1:K;[accuracy(i),sensitivity(i),specificity(i),PPV(i),NPV(i)]=Calculate_Performances(Predict_label{i},Real_label{i});end
%a=[accuracy;sensitivity;specificity;PPV;NPV]
%mean(a,2)
%% 数据准备
label=label==1;%将非1设为0.
[N,~]=size(data);
Predict_label=cell(K,1); Real_label=cell(K,1);Decision=cell(K,1);
%% K fold ready
indices = crossvalind('Kfold', N, K);
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(h, 'Color','c'); 
for i = 1:K
    %% 外层循环
    waitbar(i/K);
    test_index = (indices == i); train_index = ~test_index;
    train_data=data(train_index,:);test_data=data(test_index,:);%外层循环测试样本data and 外层循环训练样本data
    train_label=label(train_index,:);test_label=label(test_index,:);%外层循环测试样本label and 外层循环训练样本label
    %% 内层嵌套循环
        [ ~,~,~,B_final, Intercept_final] =...
          FeatureSelection_Logistic_Regression_ElasticNet(train_data,train_label,lambda,alpha,K);
    %%
      % 建立逻辑回归模型并预测外侧测试样本
      B0=B_final;
      B1=[Intercept_final; B0];
      preds = glmval(B1,test_data,'logit');
      Decision{i}=preds;
      Predict_label{i}= preds>=0.5; Real_label{i}=test_label;
end
Predict_label=cell2mat(Predict_label);Real_label=cell2mat(Real_label);
close (h)
end

