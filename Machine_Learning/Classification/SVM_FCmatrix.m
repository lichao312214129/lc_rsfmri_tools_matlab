function [Accuracy, Sensitivity, Specificity, PPV, NPV, AUC,Decision,label_ForPerformance,weight] = SVM_FCmatrix(opt)
%% =====================代码说明==================================
% 用途：对功能连接矩阵进行机器学习(PCA 降维)
% input:
% data/label=样本/样本标签,交互选择
% p_start:p_step:p_end=初始p值：每次增加的p值：最大的p值
% opt:参数，参考相应代码：FeatureSelection_RFE_SVM
%output： 若干个分类性能，size=K*N_subfeature,K=K fold; N_subfeature=sub—feature个数
%% ======================默认参数=================================
%有一些是无用的，但不影响
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;% outer K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10; % inner RFE.
    opt.percentage_consensus=0.7;% The most frequent voxels/features;range=(0,1] to obtain weight map;
    opt.weight=0;opt.viewperformance=1;opt.saveresults=0;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;%数据标准化方式及参数
    opt.permutation=0;%是否是进行的置换检验
    p_start=0.001;p_step=0.001;p_end=0.05;%ttest2
end
%% ==============load all MAT files==============================
fprintf('==============load all MAT files====================\n');
%第一组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第一组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_p=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_p(:,:,i)=importdata([path_source,char(file_name(i))]);
        mat_p(:,:,i)=triu( mat_p(:,:,i));%取上三角
    else
        mat_p(:,:,i)=importdata([path_source,char(file_name)]);
        mat_p(:,:,i)=triu( mat_p(:,:,i));%取上三角
    end
end
label_p=ones(n_sub,1);
%第二组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第二组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_c=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_c(:,:,i)=importdata([path_source,char(file_name(i))]);
        %         mat_c(:,:,i)=triu( mat_c(:,:,i));%取上三角
    else
        mat_c(:,:,i)=importdata([path_source,char(file_name)]);
        %         mat_c(:,:,i)=triu( mat_c(:,:,i));%取上三角
    end
end
label_c=zeros(n_sub,1);
fprintf('==============Load MAT files completed!====================\n');

%% ===============数据融-产生label-提取上三角=======================
fprintf('=================数据融合-产生label-提取上三角=================\n');
data=cat(3,mat_p,mat_c);
data(isnan(data))=0;
label=[label_p;label_c-1];
% 上三角（不包括对角线）的数据提取
size_mask_triu=[size(data,1),size(data,2)];
mask_triu=ones(size_mask_triu);
mask_triu(tril(mask_triu)==1)=0;
N_sub=size(data,3);
for n_sub=1:N_sub
    data_temp=data(:,:,n_sub);
    data_triu(n_sub,:)=data_temp(mask_triu==1)';
end
fprintf('============数据融合-产生label-提取上三角 Completed!============\n');

%%
fprintf('=======================K fold 交叉验证开始====================\n');
% preallocate
Accuracy=zeros(opt.K,1);Sensitivity =zeros(opt.K,1);Specificity=zeros(opt.K,1);
AUC=zeros(opt.K,1);Decision=cell(opt.K,1);PPV=zeros(opt.K,1); NPV=zeros(opt.K,1);
label_ForPerformance=cell(opt.K,1);
%
hh = waitbar(0,'please wait..');
N_sub=size(data_triu,1);
indices = crossvalind('Kfold', N_sub, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
for i = 1:opt.K
    waitbar(i/opt.K)
    Test_index = (indices == i); Train_index = ~Test_index;
    dataTrain =data_triu(Train_index,:);
    labelTrain = label(Train_index,:);
    dataTest=data_triu(Test_index,:);
    labelTest=label(Test_index,:);
    label_ForPerformance{i,1}=labelTest;
    %数据标准化
    [dataTrain,PS] = mapminmax(dataTrain');
    dataTrain=dataTrain';
    dataTest = mapminmax('apply',dataTest',PS);
    dataTest =dataTest';
    %% 特征筛选且对多个sub-feature进行建模和预测
    % PCA
    dataTrain(isnan( dataTrain))=0;
    dataTrain(isinf( dataTrain))=0;
    [COEFF,dataTrain] = pca(dataTrain);%分别对训练样本、测试样本进行主成分降维。
    dataTest = dataTest*COEFF;
    % training and testing
    model=fitclinear(dataTrain,labelTrain);
    [labelPredict,dec]=predict(model,dataTest);
     [Accuracy(i),Sensitivity(i),Specificity(i),PPV(i),NPV(i)]=Calculate_Performances(labelPredict,labelTest);
     [AUC(i)]=AUC_LC(labelTest,dec(:,1));
     Decision{i}=dec;
     %  空间判别模式
     wei = model.Beta;
     weight(i,:) = wei' * COEFF';
     % Ttest2
    %     [Accuracy(i,:), Sensitivity(i,:), Specificity(i,:), PPV(i,:), NPV(i,:), AUC(i,:)]=...
    %         Ttest2_MultiSubFeature(train_data,train_label, test_data, test_label, p_start, p_step, p_end,opt);
    %% 整理分类性能
    Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
    PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
end
close (hh)
fprintf('=======================All Completed!====================\n');