function [ W_M_Brain, Real_label, Predict_best, MAE_ALL,MAE_best, R_ALL,R_best,CombinedPerformance, CombinedPerformance_best] =...
    SVMRegression_Kfold_RFE_alpha(label,opt)
%精确度不错
%在开始RFE之前可以加入单变量的特征过滤，如F-score 、kendall Tau、Two-sample t-test等
%refer to PMID:18672070

%addpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools')
%SVM classification using RFE
%input：K=K-fold cross validation,K<=N;
%[Initial_FeatureQuantity,Max_FeatureQuantity,Step_FeatureQuantity]=初始的特征数,最大特征数,每次增加的特征数。
%output：分类表现以及K-fold的平均分类权重
% path=pwd;
% addpath(path);
%%
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%options for outer K fold.
    opt.P_threshold=0.05;%options for univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;%options for RFE, refer to related codes.
    opt.percentage_consensus=0.7;%options for indentifying the most important voxels.range=(0,1];
    %K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
end
K=opt.K;Initial_FeatureQuantity=opt.Initial_FeatureQuantity;
Max_FeatureQuantity=opt.Max_FeatureQuantity;Step_FeatureQuantity=opt.Step_FeatureQuantity;
%%
if nargin <=5
    opt.stepmethod='percentage';opt.step=10;opt.learner='leastsquares';%linear regression;
end
p1=genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools');
addpath(p1, '-begin');
p2 = genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\MVPA3.0');
addpath(p2, '-begin');
%% transform .nii/.img into .mat data, and achive corresponding label
[~,path,data ] = Img2Data_LC;
% [~,~,data_controls ] = Img2Data_LC;
% data=cat(4,data,data_controls);%data
[dim1,dim2,dim3,N]=size(data);
% [~,~,~,n_controls]=size(data_controls);
%% just keep data in inmask
data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
implicitmask = sum(data,2)~=0;%内部mask,逐行累加
data_inmask=data(implicitmask,:);%内部mask内的data
data_inmask=data_inmask';
%% 预分配空间
Number_FeatureSet=numel(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Num_loop=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
W_M_Brain=zeros(Num_loop,dim1*dim2*dim3);
W_Brain=zeros(Num_loop,sum(implicitmask),K);
Real_label=cell(K,1);
Predict=cell(K,Number_FeatureSet);
%%  K fold loop
% 多线程预备
% if nargin < 2
%   parworkers=0;%default
% end
% 多线程准备完毕
h=waitbar(0,'Please wait: Outer Loop>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, K);%此处不受随机种子点控制，因此每次结果还是不一样。
switch K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            Test_index = (indices == i); Train_index = ~Test_index;
            Train_data =data_inmask(Train_index,:);
            Train_label = label(Train_index,:);
            Test_data = data_inmask(Test_index,:);
            Test_label = label(Test_index);
            Real_label{i}=Test_label;
            %% inner loop: feature selection
            [ feature_ranking_list ] =FeatureSelection_RFE_SVM_Regression( Train_data,Train_label,opt );
            j=0;%计数，为W_M_Brain赋值。
            h1 = waitbar(0,'Please wait: different feature subsets for outer k-fold>>>>>>');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % 不同feature subset情况下
                j=j+1;%计数。
                waitbar(j/Num_loop,h1,sprintf('%2.0f%%', j/Num_loop*100)) ;
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                z_MAE_ALL= Train_data(:,Index_selectfeature);
                z_R_ALL=Test_data(:,Index_selectfeature);
                %按列方向归一化
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
                [z_MAE_ALL,PS] = mapminmax(z_MAE_ALL');
                z_MAE_ALL=z_MAE_ALL';
                z_R_ALL = mapminmax('apply',z_R_ALL',PS);
                z_R_ALL =z_R_ALL';
                %% 训练模型&预测
                model= fitrlinear(z_MAE_ALL,Train_label,'Learner',opt.learner);
                [predict_label] = predict(model,z_R_ALL);
                Predict{i,j}=predict_label;
                %% estimate mode/SVM
                
                %%  空间判别模式
                w_Brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                %而Index(1:N_feature)内的权重则被赋值（前面有预分配0向量）
                %             if ~randi([0 4])
                %                 parfor_progress;%进度条
                %             end
            end
            close (h1)
        end
        close (h)
        Predict=cell2mat(Predict);
        Real_label=cell2mat(Real_label);
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            Real_label{i}=Test_label;
            %% inner loop: ttest2, feature selection and scale
            opt.stepmethod='percentage';opt.step=10;
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM_Regression( Train_data,Train_label,opt );
            j=0;%计数，为W_M_Brain赋值。
            h1 = waitbar(0,'...');
            for FeatureQuantity=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity % 不同特征数目情况下
                j=j+1;%计数。
                waitbar(j/Num_loop,h1,sprintf('%2.0f%%', j/Num_loop*100));
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                z_MAE_ALL= Train_data(:, Index_selectfeature);
                z_R_ALL=Test_data(:, Index_selectfeature);
                %按列方向归一化
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
                [z_MAE_ALL,PS] = mapminmax(z_MAE_ALL');
                z_MAE_ALL=z_MAE_ALL';
                z_R_ALL = mapminmax('apply',z_R_ALL',PS);
                z_R_ALL =z_R_ALL';
                %% 训练模型
                model= fitrlinear(z_MAE_ALL,Train_label);
                %% 预测 or 分类
                [predict_label] = predict(model,z_R_ALL);
                 Predict{i,j}=predict_label;
                %%  空间判别模式
                w_Brain = model.Beta;
                W_Brain(j,Index_selectfeature,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                %             if ~randi([0 4])
                %                 parfor_progress;%进度条
                %             end
            end
            close (h1)
        end
         Predict=cell2mat(Predict);
        Real_label=cell2mat(Real_label);
        close (h)
end
%% 平均的空间判别模式
W_mean=mean(W_Brain,3);%取所有LOOVC的w_brain的平均值，注意此处考虑到loop中未被选中的体素，处理方法是前面将其权重设为0
W_M_Brain(:,implicitmask)=W_mean;%不同feature 数目时的全脑体素权重
%% 整理分类性能

%% 计算模型性能 MAE
% ALL MAE and ALL R
MAE_ALL=Predict-Real_label;
MAE_ALL=sum(abs(MAE_ALL),1)/numel(Real_label);
[R_ALL,~]=corr(Predict,Real_label);
% combine MAE and R to calculate combined performance
% z_MAE_ALL=zscore(MAE_ALL);
% z_R_ALL=zscore(R_ALL);
[z_MAE_ALL,~] = mapminmax(MAE_ALL,0.1,1);
[z_R_ALL,~] = mapminmax(R_ALL,0.1,1);
z_MAE_ALL=reshape(z_MAE_ALL,1,numel(z_MAE_ALL));
z_R_ALL=reshape(z_R_ALL,1,numel(z_R_ALL));
CombinedPerformance=z_R_ALL+1./z_MAE_ALL;
% best feature subset
loc_maxCombinedPerformance=find(CombinedPerformance==max(CombinedPerformance));
loc_maxCombinedPerformance=loc_maxCombinedPerformance(1);
%min MAE and max Pearson R
Predict_best=Predict(:,loc_maxCombinedPerformance);
CombinedPerformance_best=CombinedPerformance(loc_maxCombinedPerformance);
MAE_best=MAE_ALL(loc_maxCombinedPerformance);
R_best=R_ALL(loc_maxCombinedPerformance);
% find best Weight and Predict
W_M_Brain_best=W_M_Brain(loc_maxCombinedPerformance,:);
feature_array=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity;
% Num_feature_best=feature_array(loc_maxCombinedPerformance);
%% 显示不同特征值组合适的各种性能
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),MAE_ALL,'--o');title('MAE_ALL');
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),R_ALL,'--o');title('R_ALL');
 figure;plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),CombinedPerformance,'--o');title('CombinedPerformance');
%% save results
%目录
loc= find(path=='\');
outdir=path(1:loc(length(find(path=='\'))-2)-1);%path的上一层目录
W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
%% 保存分类权重图并保存结果
%gray matter mask
[file_name,path_source1,~]= uigetfile( ...
    {'*.img;*.nii;','All Image Files';...
    '*.*','All Files' },...
    '请选择mask（单选）', ...
    'MultiSelect', 'off');
img_strut_temp=load_nii([path_source1,char(file_name)]);
mask_graymatter=img_strut_temp.img~=0;
W_M_Brain_3D(~mask_graymatter)=0;
% save nii
Time=datestr(now,30);
cd (outdir)
Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%save results
save([outdir filesep 'Results_MVPA.mat'],...
    'W_M_Brain_best', 'W_M_Brain_3D', 'Real_label', ...
    'Predict_best', 'MAE_ALL','MAE_best','R_ALL','R_best','CombinedPerformance','CombinedPerformance_best');
end

