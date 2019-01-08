function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, label_ForPerformance, MAE, R] =...
    SVMRegression_Kfold(K,opt)
%精确度不高
%input：K=K-fold cross validation,K<N
%output：分类表现以及K-fold的平均分类权重; label_ForPerformance=随机化处理后的label，用来绘制ROC曲线
% path=pwd;
% addpath(path);
if nargin ==1; opt.lambda=exp(-10:10); opt.Regularization='lasso';end
%% 将图像转为data,并产生label
%         [~,path,data_patients ] = Img2Data_LC;
%         [~,~,data_controls ] = Img2Data_LC;
%         data=cat(4,data_patients,data_controls);%data
%         [dim1,dim2,dim3,n_patients]=size(data_patients);
%         [~,~,~,n_controls]=size(data_controls);
%         label=[ones(n_patients,1);zeros(n_controls,1)];%label
%         %% inmask
%         N=n_patients+n_controls;
%         data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
%         implicitmask = sum(data,2)~=0;%内部mask,逐行累加
%         data_inmask=data(implicitmask,:);%内部mask内的data
%         data_inmask=data_inmask';
%% =============================================================
data=rand(500,500);r=[1;2;3;4;5;6;7;8;9;10;zeros(500-10,1)];label=data*r;
opt.Learner='svm';opt.lambda=exp(-10:10); opt.Regularization='lasso';
K=5;
%% =============================================================
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
%%  K fold loop
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
    %% 训练模型
    CVMdl = fitrlinear(train_data',train_label,'ObservationsIn','columns','KFold',5,'Lambda',opt.lambda,...
        'Learner',opt.Learner,'Regularization',opt.Regularization);%内部CV
    mse = kfoldLoss(CVMdl);
    loc_MinMSE=find(mse==min(mse));
    loc_MinMSE=loc_MinMSE(1);
    Lambda_best= opt.lambda(loc_MinMSE);%内部CV找到了最佳lambda（best）
    Mdl = fitrlinear(train_data',train_label,'ObservationsIn','columns','Lambda',Lambda_best,...
        'Learner',opt.Learner,'Regularization',opt.Regularization);%最佳lambda在train data里训练模型
    %%
    [predict_label] = predict(Mdl,test_data);
    Predict(j:j+numel(predict_label)-1,1)=predict_label;
    MAE(i)=sum(abs(predict_label-test_label))/numel(test_label);
    [R(i),~]=corr(predict_label,test_label);
end
close (h)
a=[Predict, label_ForPerformance];
b=[Mdl.Beta,r];
MAE_ALL=sum(abs(Predict-label_ForPerformance))/numel(label_ForPerformance);
R_ALL=corr(Predict,label_ForPerformance);
end

