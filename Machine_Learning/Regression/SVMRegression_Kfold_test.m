function [Predict, label_ForPerformance,a,M_Beta] =SVMRegression_Kfold_test(K,data,label, lambda)

% data=rand(100,100);r=[1;2;3;4;5;6;7;8;9;10;zeros(100-10,1)];label=data*r;
% lambda=exp(-6:6);alpha=0.1:0.1:1;
% [accuracy,sensitivity,specificity,PPV,NPV]=Calculate_Performances(a(:,1),a(:,2))
%  [Predict, label_ForPerformance]
implicitmask = sum(data,1)~=0;%内部mask,逐列累加
data_inmask=data;
[N,~]=size(data_inmask);
%=======
%% 预分配空间
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
% w_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
% w_M_Brain=zeros(1,dim1*dim2*dim3);
Predict=NaN(N,1);
%%  Outer K fold loop
h = waitbar(0,'...');
indices = crossvalind('Kfold', N, K);%此处不受随机种子点控制，因此每次结果还是不一样。
for i=1:K
    waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
    test_index = (indices == i); train_index = ~test_index;
    train_data =data_inmask(train_index,:);
    train_label = label(train_index,:);
    test_data = data_inmask(test_index,:);
    test_label = label(test_index);
    j=sum(~isnan(label_ForPerformance))+1;
    label_ForPerformance(j:j+numel(test_label)-1,1)=test_label;
    %% Inner K fold to optimize paramaters, best lambda
    CVMdl = fitrlinear(train_data,train_label,'KFold',5,'Lambda',lambda,...
    'Learner','svm','Regularization','lasso');%内部CV
    mse = kfoldLoss(CVMdl);
    loc_MinMSE=find(mse==min(mse));
    loc_MinMSE=loc_MinMSE(1);
    lambda_best= lambda(loc_MinMSE);%内部CV找到了最佳lambda（best）
    %% use the best paramaters to build model for each outer k fold
    Mdl = fitrlinear(train_data,train_label,'Lambda',lambda_best,...
    'Learner','svm','Regularization','lasso');%最佳lambda在train data里训练模型
    Beta(K,:)=Mdl.Beta;
    %% use builted model to predict each fold of unseen data
    [predict_label] = predict(Mdl,test_data);
    Predict(j:j+numel(predict_label)-1,1)=predict_label;
    MAE(i)=sum(abs(predict_label-test_label))/numel(test_label);
    [R(i),~]=corr(predict_label,test_label);
end
close (h)
M_Beta=mean(Beta);
a=[Predict, label_ForPerformance];
end

