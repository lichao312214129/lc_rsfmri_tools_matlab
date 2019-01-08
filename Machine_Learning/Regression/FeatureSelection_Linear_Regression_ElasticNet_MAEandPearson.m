function [lambda_best,alpha_best, M_MAE_best, M_R_best]=...
          FeatureSelection_Linear_Regression_ElasticNet_MAEandPearson(data,label,alpha,lambda,K)
%author email:lichao19870617@gmail.com; please feel free to contact me
%参考崔再续的文章 cerebral cortex 期刊
%Regularized least-squares regression using lasso or elastic net
%将lasso改为lassoglm,将执行lasso正则的一般线性模型,响应变量服从'binomial'分布时，即为logistics回归（MATLAB example：Regularize Logistic Regression）
%algorithms(least-squares：min(1/2(f(x)-y)^2))
%用Nested cross validation来进行特征选择
% refrence: Individualized Prediction of Reading Comprehension Ability Using Gray Matter Volume;doi: 10.1093/cercor/bhx061
%input======lambda为一个数值型向量，越大零系数越多（lambda=e^gama,gama=[-6,5]）
%alpha为一个数值型向量，alpha=1为lasso回归，=0为岭回归，其他数值为Elastic Net 回归,alpha=[0.1,1]
%k代表k-fold 交叉验证
%output=====NoZero_feature=系数为非零的特征的mask;
%lambda_best=最佳lambda,
%alpha_best=最佳alpha,
%B_final=最终的系数（包含0系数）,
%Intercept_final=最终截距（beta0/bias）
%注意：本代码没有将数据做规范化预处理
%Regularize Logistic Regression可以可视化lambda和系数的关系。
%% 预分配空间
[N,~]=size(data);
%  B_final=cell(length(alpha),length(lambda),K);
MAE=inf(length(alpha),length(lambda),K);
R=zeros(length(alpha),length(lambda),K);
%% loop
hwait=waitbar(0,'请等待 Inner Loop>>>>>>>>');set(hwait, 'Color','c');
for i=1:length(alpha)
    for j=1:length(lambda)
        indices = crossvalind('Kfold', N, K);
        for k = 1:K
            %% 内部K-fold
            test_index = (indices == k); train_index_out = ~test_index;
            data_train=data(train_index_out,:);data_test=data(test_index,:);%外层循环测试样本data and 外层循环训练样本data
            label_train=label(train_index_out,:);label_test=label(test_index,:);%外层循环测试样本label and 外层循环训练样本label
            [B,FitInfo] = lasso(data_train,label_train,'Lambda',lambda(j),'Alpha',alpha(i));
            preds =data_test*B+ FitInfo.Intercept;
            MAE(i,j,k)=sum(abs(preds-label_test))/numel(label_test);
            [R(i,j,k),~]=corr(preds,label_test);
        end
    end
    waitbar(i/length(alpha)); 
end
%% 计算MAE和R的加权在score（R）+1/zscore(MAE)
clear i j k;
M_MAE=mean(MAE,3);
M_R=mean(R,3);
M_MAE(isnan(M_MAE))=inf;
M_R(isnan(M_R))=0;
zscore_MAE=zscore(M_MAE(:)); zscore_MAE=reshape(zscore_MAE,length(alpha),length(lambda));
zscore_R=zscore(M_R(:)); zscore_R=reshape(zscore_R,length(alpha),length(lambda));
accuracy_weighted=zscore_R+1./zscore_MAE;
[i,j]=find(accuracy_weighted==max(accuracy_weighted(:)));
alpha_best=alpha(i);lambda_best=lambda(j); M_MAE_best=M_MAE(i,j); M_R_best=M_R(i,j);
close(hwait)
end

