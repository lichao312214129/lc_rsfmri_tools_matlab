function [ MAE_best,R_best,CombinedPerformance_best,Predict_best] =...
    SVMRegression_Kfold_RFE_beta(opt,label,data)
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
if nargin <1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%options for outer K fold.
    opt.P_threshold=0.05;%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
    opt.learner='leastsquares';opt.stepmethod='percentage';opt.step=10;%options for RFE, refer to related codes.
    opt.percentage_consensus=0.7;%options for indentifying the most important voxels.range=(0,1];
    %K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
    opt.weight=0;opt.viewperformance=0;opt.saveresults=0;opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
end
Initial_FeatureQuantity=opt.Initial_FeatureQuantity;
Max_FeatureQuantity=opt.Max_FeatureQuantity;Step_FeatureQuantity=opt.Step_FeatureQuantity;
P_threshold=opt.P_threshold;percentage_consensus=opt.percentage_consensus;
%%
% p1=genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\little tools');
% addpath(p1, '-begin');
% p2 = genpath('J:\lichao\MATLAB_Code\LC_script\Scripts_LC\MVPA3.0');
% addpath(p2, '-begin');
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
if nargin<3 %如果是置换检验则不读图像，数据由上一层代码提供
    [~,path,data_patients ] = Img2Data_LC;
    [~,~,data_controls ] = Img2Data_LC;
    data=cat(4,data_patients,data_controls);%data
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
    if opt.permutation;disp(['number of patients and controls are ', num2str([n_patients, n_controls])]);end
end
if nargin<2
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
end
[dim1,dim2,dim3,N]=size(data);
%% 判断label与data是否数目匹配
if numel(label)~=N
    warning('The number of label is inconsistent with data');
end
%% just keep data in inmask
data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
implicitmask = sum(data,2)~=0;%内部mask,逐行累加
data_inmask=data(implicitmask,:);%内部mask内的data
data_inmask=data_inmask';
%% 预分配空间
Number_FeatureSet=numel(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
Num_loop=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
W_M_Brain=zeros(Num_loop,dim1*dim2*dim3);
W_Brain=zeros(Num_loop,sum(implicitmask),opt.K);
Real_label=cell(opt.K,1);
Predict=cell(opt.K,Number_FeatureSet);
%%  K fold loop
% 多线程预备
% if nargin < 2
%   parworkers=0;%default
% end
% 多线程准备完毕
h=waitbar(0,'Please wait: Outer Loop>>>>>>','Position',[50 50 280 60]);
indices = crossvalind('Kfold', N, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
switch opt.K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:opt.K
            waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
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
                train_data= Train_data(:,Index_selectfeature);
                test_data=Test_data(:,Index_selectfeature);
                % step2： 标准化或者归一化
                [train_data,test_data ] = Standard( train_data,test_data,opt);
                %% 训练模型&预测
                model= fitrlinear(train_data,Train_label,'Learner',opt.learner);
                [predict_label] = predict(model,test_data );
                Predict{i,j}=predict_label;
                %% estimate mode/SVM
                
                %%  空间判别模式
                if opt.weight
                    w_Brain = model.Beta;
                    W_Brain(j,Index_selectfeature,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                end
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
        for i=1:opt.K
            waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
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
                train_data= Train_data(:, Index_selectfeature);
                test_data=Test_data(:, Index_selectfeature);
                % step2： 标准化或者归一化
                [train_data,test_data ] = Standard( train_data,test_data,opt);
                %% 训练模型
                model= fitrlinear(train_data,Train_label);
                %% 预测 or 分类
                [predict_label] = predict(model,test_data);
                Predict{i,j}=predict_label;
                %%  空间判别模式
                if opt.weight
                    w_Brain = model.Beta;
                    W_Brain(j,Index_selectfeature,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                end
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
if opt.weight
    %% consensus中平均的空间判别模式
    binary_mask=W_Brain~=0;
    sum_binary_mask=sum(binary_mask,3);
    loc_consensus=sum_binary_mask>=percentage_consensus*opt.K; num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
    disp(['consensus voxel = ' num2str(num_consensus)]);
    W_mean=mean(W_Brain,3);%取所有fold的 W_Brain的平均值
    W_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero.
    W_M_Brain(:,implicitmask)=W_mean;%不同feature 数目时的全脑体素权重
end
%% 整理分类性能

%% 计算模型性能 MAE等
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
CombinedPerformance=z_R_ALL+1./z_MAE_ALL;%refer to Cui ZaiXu's paper (Cerebral Cortex)
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
if opt.viewperformance
    figure;plot(feature_array,MAE_ALL,'--o');title('MAE_ALL');
    figure;plot(feature_array,R_ALL,'--o');title('R_ALL');
    figure;plot(feature_array,CombinedPerformance,'--o');title('CombinedPerformance');
end
%% save results
Time=datestr(now,30);
if  opt.saveresults
    %目录
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path的上一层目录
    W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    % 保存分类权重图
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
end
%save results
if opt.saveresults
    save([outdir filesep [Time,' Results_MVPA.mat']],...
        'W_M_Brain_best', 'W_M_Brain_3D','Predict_best','Real_label',...
        'MAE_ALL','MAE_best','R_ALL','R_best','CombinedPerformance','CombinedPerformance_best');
end
end

