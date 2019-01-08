function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, w_M_Brain, w_M_Brain_3D] =...
    SVM_LC_Kfold_PCA_Par(K,parworkers)
%此代码在heart数据集上测试成功
%input：K=K-fold cross validation,K<N
%output：分类表现以及K-fold的平均分类权重
%% 将图像转为data,并产生label
[~,~,data_patients ] = Img2Data_LC;
[~,~,data_controls ] = Img2Data_LC;
data=cat(4,data_patients,data_controls);%data
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
label=[ones(n_patients,1);zeros(n_controls,1)];%label
%% inmask
N=n_patients+n_controls;
data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
implicitmask = sum(data,2)~=0;%内部mask,逐行累加
data_inmask=data(implicitmask,:);%内部mask内的data
data_inmask=data_inmask';
%% 预分配空间
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
w_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
w_M_Brain=zeros(1,dim1*dim2*dim3);
Predict=NaN(N,1);
%%  K fold loop
% 多线程预备
if nargin < 2
  parworkers=0;%default
end
% data_inmask1=data_inmask;
% data_inmask2=data_inmask;
% label1=label;
% label2=label;
% 多线程准备完毕
s=rng(1);%可重复、一致
rng(s);%可重复、一致
indices = crossvalind('Kfold', N, K);
switch K<N
    case 1
        % initialize progress indicator
        parfor_progress(K);
        parfor (i=1:K,parworkers)
%             waitbar(i/K,h,sprintf('%2.0f',i)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask((indices == i),:);
            test_label = label(test_index,:);
            %% 降维及归一化
            %主成分降维
            [COEFF, train_data] = pca(train_data);%分别对训练样本、测试样本进行主成分降维。
            test_data = test_data*COEFF;
            %按列方向归一化
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% 训练模型
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
            Decision{i}=dec_values(:,2);
            %% 评估模型
            [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,test_label);
            Accuracy(i) =accuracy;
            Sensitivity(i) =sensitivity;
            Specificity(i) =specificity;
            PPV(i)=ppv;
            NPV(i)=npv;
            [AUC(i)]=AUC_LC(test_label,dec_values(:,2));
            %%  空间判别模式
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
            if ~randi([0 4])
                parfor_progress;%进度条
            end
        end
        parfor_progress(0);
%% 留一交叉验证
    case 0 %equal to leave one out cross validation, LOOCV
        parfor_progress(K);
        parfor (i=1:K,parworkers)
%             waitbar(i/K,h,sprintf('%2.0f',i)) ;
            %K fold
          new_data = data_inmask; new_label = label;
          test_data = data_inmask(i,:);new_data(i,:) = []; train_data = new_data;
          test_label = label(i,:);new_label(i,:) = [];train_label = new_label;
           label_ForPerformance(i)=test_label;
            %% 降维及归一化
            %主成分降维
            [COEFF, train_data] = pca(train_data);%分别对训练样本、测试样本进行主成分降维。
            test_data = test_data*COEFF;
            %按列方向归一化
            % [train_data,test_data,~] = ...
            %    scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
            [train_data,PS] = mapminmax(train_data');
            train_data=train_data';
            test_data = mapminmax('apply',test_data',PS);
            test_data =test_data';
            %% 训练模型
            model= fitclinear(train_data,train_label);
            %%
            [predict_label, dec_values] = predict(model,test_data);
            Decision{i}=dec_values(:,2);
            Predict(i,1)=predict_label;
            %%  空间判别模式
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
%             if ~randi([0 4])
                parfor_progress;%进度条
%             end
        end
        parfor_progress(0);
end
%% 平均的空间判别模式
W_mean=mean(w_Brain);%取所有LOOVC的w_brain的平均值
w_M_Brain(implicitmask)=W_mean;
w_M_Brain_3D=reshape(w_M_Brain,dim1,dim2,dim3);
%% 显示模型性能 K < N
        if K<N
           performances=[mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);...
           std([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC])];%显示分类表现
           performances=performances';
           f = figure;
            title(['Performance with',' ',num2str(K),'-fold']);
            axis off
            t = uitable(f);
            d = performances;
            t.Data = d;
            t.ColumnName = {'mean performance','std'};
            t.RowName={'MAccuracy','MSensitivity','MSpecificity','MPPV','MNPV','MAUC'};
            t.Position = [50 0 400 300];
        end
%% 显示模型性能 K==N，等价于LOOCV
        if K==N
            [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
             AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
            performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%显示分类表现
            f = figure;
            title(['Performance with',' ',num2str(K),'-fold']);
            axis off
            t = uitable(f);
            d = performances;
            t.Data = d;
            t.ColumnName = {'performance'};
            t.RowName={'Accuracy','Sensitivity','Specificity','PPV','NPV','AUC'};
%             t.ColumnEditable = true;
            t.Position = [50 0 300 300];
        end
%% 显示图像
Data2Img_LC(w_M_Brain_3D,'w_M_Brain_3D.nii')

