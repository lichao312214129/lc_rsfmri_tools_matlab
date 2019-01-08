function [ NoZero_feature,lambda_best,alpha_best,B_final, Intercept_final] =...
    FeatureSelection_Linear_Regression_ElasticNet_MSE_Parallel(data,label,lambda,alpha,K)
%此函数比~MAEandPearson的精度高
%author email:lichao19870617@gmail.com; please feel free to contact me
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
%%
MSE=inf(length(alpha),1);%所有alpha对应的最小MSE向量
Lambda=zeros(length(alpha),1);%所有alpha对应的最佳Lambda向量
%% 多线程
% initialize progress indicator
% parfor_progress(length(alpha));
% parfor(i = 1:length(alpha),parworkers)
%%
% hwait=waitbar(0,'请等待 Inner Loop>>>>>>>>');
parworkers=2;
parfor_progress(length(alpha));
parfor(i = 1:length(alpha),parworkers)
    %     for i=1:length(alpha)
    waitbar(i/length(alpha));
    [~,FitInfo] = lasso(data,label,'Lambda',lambda,'Alpha',alpha(i),'CV',K);%Regularized least-squares regression using elastic net algorithms
    mse_min=FitInfo.MSE(FitInfo.IndexMinMSE);%某个alpha值时的最小MSE
    lambda_best=FitInfo.Lambda(FitInfo.IndexMinMSE);%某个alpha值时的最佳lambda
    MSE(i)=mse_min;%所有alpha对应的最小MSE向量
    Lambda(i)=lambda_best;%所有alpha对应的最佳Lambda向量
            parfor_progress;
end
% close (hwait)
lambda_best=Lambda(MSE==min(MSE));
lambda_best=lambda_best(end);%所有alpha及lambda组合中最佳的lambda
alpha_best=alpha(MSE==min(MSE));
alpha_best=alpha_best(end);%所有alpha及lambda组合中最佳的alpha
%% 用最佳的alpha和lambda来建立回归模型，从而筛选特征。
[B_final ,FitInfo2] = lasso(data,label,'Lambda',lambda_best,'Alpha',alpha_best);
Intercept_final=FitInfo2.Intercept;
NoZero_feature=B_final~=0;%非零系数的位置（逻辑张量）
end

