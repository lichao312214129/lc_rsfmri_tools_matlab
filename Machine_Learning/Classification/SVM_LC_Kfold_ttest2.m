function [ PER,Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, W_M_Brain,W_M_Brain_3D] =...
    SVM_LC_Kfold_ttest2(K,NMax_features,step)
%此代码在heart数据集上测试成功
%input：K=K-fold cross validation,K<N
%feature selection by ttest2
%output：分类表现以及K-fold的平均分类权重
% path=pwd;
% addpath(path);
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
PER=[];%不同特征数目的平均分类表现
W_M_Brain=zeros(NMax_features,dim1*dim2*dim3);

%% 此处分配的空间太大，想办法缩减！！！！！！！！！！！！！！！！！
%===================================
for N_feature=1:step:NMax_features % 不同特征数目情况下
%% 预分配空间
% w_M_Brain=zeros(1,sum(implicitmask));
Accuracy=zeros(K,1);Sensitivity =zeros(K,1);Specificity=zeros(K,1);
AUC=zeros(K,1);Decision=cell(K,1);PPV=zeros(K,1); NPV=zeros(K,1);
W_Brain=zeros(K,sum(implicitmask));
label_ForPerformance=NaN(N,1);
Predict=NaN(N,1);
%%  K fold loop
% 多线程预备
% if nargin < 2
%   parworkers=0;%default
% end
% data_inmask1=data_inmask;
% data_inmask2=data_inmask;
% label1=label;
% label2=label;
% 多线程准备完毕
h = waitbar(0,'...');
% s=rng;%可重复、一致
% rng(s);%可重复、一致
indices = crossvalind('Kfold', N, K);%此处不受随机种子点控制，因此每次结果还是不一样。
switch K<N
    case 1
        % initialize progress indicator
%         parfor_progress(K);
        for i=1:K
           waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
          %% ttest2, feature selection and scale
            %ttest2
            [~,P,~,~]=ttest2(train_data(train_label==1,:), train_data(train_label==0,:));%patients VS controls;
            [P_sort,Index]=sort(P);
             train_data= train_data(:,Index(1:N_feature));
             test_data=test_data(:,Index(1:N_feature));
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
            w_Brain = model.Beta;
            W_Brain(i,Index(1:N_feature)) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
            %而Index(1:N_feature)内的权重则被赋值（前面有预分配0向量）
%             if ~randi([0 4])
%                 parfor_progress;%进度条
%             end
        end
        close (h)
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data = data_inmask(test_index,:);
            test_label = label(test_index);
            label_ForPerformance(i)=test_label;
          %% ttest2, feature selection and scale
            %ttest2
            [~,P,~,~]=ttest2(train_data(train_label==1,:), train_data(train_label==0,:));%patients VS controls;
            [P_sort,Index]=sort(P);
             train_data= train_data(:,Index(1:N_feature));
             test_data=test_data(:,Index(1:N_feature));
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
            w_Brain = model.Beta;
            W_Brain(i,Index(1:N_feature)) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
            %而Index(1:N_feature)内的权重则被赋值（前面有预分配0向量）
%             if ~randi([0 4])
%                 parfor_progress;%进度条
%             end
        end
        close (h)
end
%% 平均的空间判别模式
W_mean=mean(W_Brain);%取所有LOOVC的w_brain的平均值，注意此处考虑到loop中未被选中的体素，处理方法是前面将其权重设为0
W_M_Brain(N_feature,implicitmask)=W_mean;%不同特征数目时的全脑体素权重
% W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);
%% 整理分类性能
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% 显示模型性能 K < N
        if K<N
           performances=[mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);...
           std([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC],1)];%显示分类表现,std的分母是‘N’
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
            PER=[PER performances];%次performance为在某个特征数目下，K个fold的平均值。
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
            PER=[PER performances];%次performance为在某个特征数目下得值，因为是LOOCV所以没有平均值和标准差。
        end     
end
           %% 显示和保存权重图像
            %gray matter mask
            AUC_max=max(PER(6,(1:2:end)));%不同特征数目下，AUC（k-fold下的平均值）的最大值。
            loc_MaxAUC=PER(6,(1:2:end))==AUC_max;
            feature_matrix=(1:step:NMax_features);
            location_Best_featureNum=feature_matrix(loc_MaxAUC);
            [file_name,path_source1,~] = uigetfile({'*.nii';'*.img'},'MultiSelect','off','请选择mask模板图像');
            img_strut_temp=load_nii([path_source1,char(file_name)]);
            mask_graymatter=img_strut_temp.img~=0;
            W_M_Brain_BestAUC=W_M_Brain(location_Best_featureNum(1),:);%location_Best_featureNum(1)为特征数目最少的，
            %最佳的location
            W_M_Brain_3D=reshape(W_M_Brain_BestAUC,dim1,dim2,dim3);
            W_M_Brain_3D(~mask_graymatter)=0;
            % save nii
            data=datestr(now,30);
            Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',data,'.nii'])
%% 画图
Name_plot={'Accuracy','Sensitivity', 'Specificity', 'PPV', 'NPV','AUC'};
N_plot=length(1:step:NMax_features);
h=figure;
h.Name='Mean Performance';
for j=1:6
subplot(3,2,j);plot((1:step:NMax_features),PER(j,(1:2:2*N_plot)),'-');title(['Mean',' ',Name_plot{j}]);grid on;hold on;
end
g=figure;
g.Name= 'Std Performance';
for j=1:6
subplot(3,2,j);plot((1:step:NMax_features),PER(j,[2:2:2*N_plot]),'-');title( ['Std',' ',Name_plot{j}]);grid on;hold on;
end
end


