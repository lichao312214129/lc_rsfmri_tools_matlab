function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    MVPA_SingleModality_Kfold_Univariate_RFE7(opt,dataMat,label)
%=========Classification using PCA and RFE========================
% usage：
%       
%      refer to《Multivariate classification of social anxiety disorder
%      using whole brain functional connectivity》 and PMID:18672070。
%      1. 此代码保存的权重图为N-fold中consensus的平均权重图，
%      2. 由于fitclinear和indices的随机性，每次的结果可能有差异！！！
%      3. 在开始RFE之前可以加入单变量的特征过滤或者其他降维，如F-score 、opt.Kendall Tau、Two-sample
%      t-test等（此代码用Two-sample t-test）
%      4. 此代码没有用nested RFE
% input：
%        opt.K=K-fold cross validation(opt.K<=N)        
%        [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=[初始的特征数,最大特征数,每次增加的特征数]
%        opt.P_threshold =单变量来特征过滤是的P阈值;
%        opt.percentage_consensus=K fold中某个权重不为零的体素出现的概率
%        如opt.percentage_consensus=0.8，opt.K=5，则出现5*0.8=4次以上的体素才认为是consensus体素。
% output：
%        分类表现以及K-fold的平均分类权重(部分直接保持为.mat文件)
% New: 
%       扩展到其他classifier。2018-04-10 By Li Chao
%% set options
if nargin<1
    % style of loading data
    opt.loadOrderOfData='groupFirst';
    % mask :'implicit' OR 'external'
    opt.maskSource='implicit';
    % how many modality/feature types
    opt.numOfFeatureType=1;
    % permutation test
    opt.permutation=0;
    % outer K fold CV
    opt.K=5;
    % load old indices
    opt.IfLoadIndices=0;
    % standardization
    opt.standardizationMethod='normalizing';
    opt.min_scale=0;
    opt.max_scale=1;
    % univariate feature filter.
    opt.P_threshold=0.01;
    % RFE
    opt.learner='fitclinear';
    opt.stepmethod='percentage';
    opt.step=5;
    % feature subset
    opt.Initial_FeatureQuantity=10;
    opt.Max_FeatureQuantity=5000;
    opt.Step_FeatureQuantity=50;
    % classifier
    classifier=@fitclinear;
    % calculate weight map
    opt.weight=1;
    % The frequence of the occurrence of the same voxels/features which used to generate weight map; range=(0,1];
    opt.percentage_consensus=0.7;
    % view performances
    opt.viewperformance=1;
    % save results
    opt.saveresults=1;
    % gpu
    opt.gpu=0;
end
%% ===============image to data and produce label==================
% 如果是置换检验则不读图像，数据由上一层代码提供
% data
if nargin<2
    [fileName,folderPath,dataCell] =Img2Data_MultiGroup('on',2);
    path=folderPath{1};
    name_patients=fileName{1};
    name_controls=fileName{2};
%     [dataMatCell]=dataCell2Mat(dataCell,opt.numOfFeatureType,'groupFirst');
   [dataMatCell,nameFirstModality]=...
       dataCell2Mat(dataCell,fileName,opt.numOfFeatureType,opt.loadOrderOfData);% 按特征分配到各个cell
    dataMat=dataMatCell{1};
end
% label
if nargin<3
    [label]=generateLabel(dataCell,opt.numOfFeatureType, 'groupFirst');
end
[dim1,dim2,dim3,~]=size(dataMat);
%% ===========just keep data in mask,and reshape data=============
% 逐个特征种类在第2维度上叠加，并用mask来筛选
data_inmask=[];
maskForFilter=[];
for ith_featureType=1:opt.numOfFeatureType
    [data_inmask_temp,maskForFilter_temp]=featureFilterByMask(dataMatCell{ith_featureType},[],opt.maskSource);
    data_inmask=cat(2,data_inmask,data_inmask_temp);
    maskForFilter=cat(1,maskForFilter,maskForFilter_temp);
end
%% 确定是否载入已有的交叉验证方式,并为后面确定哪些样本分类不好做准备
if ~opt.permutation
    % 当不是置换检验时，就根据用户来确定是否载入已有的交叉验证方式
    if opt.IfLoadIndices==0
        indiceCell=generateIndiceForKfoldCV(label,opt.K);
    else
        [~,indices_p,indices_c]=LoadIndices();
    end
else
    % 当是置换检验时，就算计交叉验证
    indiceCell=generateIndiceForKfoldCV(label,opt.K);
end
% 当不是置换检验时，则确定文件名的顺序，为论文报告哪些样本分类不好做准备
% indices_p=indiceCell{1};
% indices_c=indiceCell{2};
name_all_sorted=sortNameAccordIndices(nameFirstModality,indiceCell,label,opt);

%% =======================预分配空间===============================
numOfFeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
Accuracy=zeros(opt.K,numOfFeatureSet);Sensitivity =zeros(opt.K,numOfFeatureSet);Specificity=zeros(opt.K,numOfFeatureSet);
AUC=zeros(opt.K,numOfFeatureSet);Decision=cell(opt.K,numOfFeatureSet);PPV=zeros(opt.K,numOfFeatureSet); NPV=zeros(opt.K,numOfFeatureSet);
W_M_Brain=zeros(numOfFeatureSet,dim1*dim2*dim3);
W_Brain=zeros(numOfFeatureSet,size(data_inmask,2),opt.K);
label_ForPerformance=cell(opt.K,1);
labelPredict=cell(opt.K,numOfFeatureSet);
%%  ====================K fold loop===============================
tic;
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1：将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    [dataTrain,dataTest,labelTrain,labelTest]=...
        BalancedSplitDataAndLabel(data_inmask,label,indiceCell,i);
    % step2： 标准化或者归一化
    [dataTrain,dataTest]=Standardization(dataTrain,dataTest,opt);
    % step3：加入单变量的特征过滤
    [~,P,~,~]=ttest2(dataTrain(labelTrain==1,:), dataTrain(labelTrain==2,:),'Tail','both');
%         [~,P]=featureSelection_ANOCOVA(dataTrain,labelTrain, []);% 使用GRETNA的代码，注意要引用。
    Index_ttest2=find(P<=opt.P_threshold);
    dataTrain= dataTrain(:,Index_ttest2);
    dataTest=dataTest(:,Index_ttest2);
    %             [COEFF,dataTrain] = pca(dataTrain);%分别对训练样本、测试样本进行主成分降维。
    %             dataTest = dataTest*COEFF;
    % step4：Feature selection---RFE
    [ feature_ranking_list ] = featureSelection_RFE_SVM2( dataTrain,labelTrain,opt );
    % step5： training model and predict test data using different feature subset
%     if ~opt.permutation; h1 = waitbar(0,'...');end
    numOfMaxFeatureQuantity=min(opt.Max_FeatureQuantity,length(Index_ttest2));%最大特征数
    %     numOfMaxFeatureIteration=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity);%最大迭代次数
    j=0;% count
    for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity
        j=j+1;%计数
%         if ~opt.permutation
%             waitbar(j/numOfMaxFeatureIteration,h1,sprintf('%2.0f%%', j/numOfMaxFeatureIteration*100)) ;
%         end
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        dataTrainTemp= dataTrain(:,Index_selectfeature);
        dataTestTemp=dataTest(:,Index_selectfeature);
        label_ForPerformance{i,1}=labelTest;
        % training and predict/testing
        model= classifier(dataTrainTemp,labelTrain);
        [labelPredict{i,j}, dec_values] = predict(model,dataTestTemp);
        Decision{i,j}=dec_values(:,2);
        % Calculate performance of model
        [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(labelPredict{i,j},labelTest);
        Accuracy(i,j) =accuracy;
        Sensitivity(i,j) =sensitivity;
        Specificity(i,j) =specificity;
        PPV(i,j)=ppv;
        NPV(i,j)=npv;
        [AUC(i,j)]=AUC_LC(labelTest,dec_values(:,1));
        %  空间判别模式
        if opt.weight
            W_Brain(j,:,i)=data2originIndex({Index_ttest2,Index_selectfeature},...
                reshape(model.Beta,1,numel(model.Beta)), size( data_inmask,2));
        end
    end
%     if ~opt.permutation
%         close (h1);
%     end
    % step 5 completed!
end
close (h);
toc
%% ====================公用的代码==================================
% 计算平均的空间判别模式，并排除掉频率低的weight
if opt.weight
    W_mean=AverageWeightMap(W_Brain,opt.percentage_consensus);% W_mean的维度和maskForFilter一致。
    %     W_M_Brain=data2originIndex({find(maskForFilter~=0)},W_mean,length(maskForFilter));
    W_M_Brain(:,maskForFilter~=0)=W_mean;%不同feature 数目时的全脑体素权重
end
% 计算最佳的分类性能
[loc_best,predict_label_best,~,Accuracy_best,Sensitivity_best,Specificity_best,...
    ~,~,AUC_best]=...
    IdentifyBestPerformance(labelPredict,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,'accuracy');
% disply best performances
if ~opt.permutation
    disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
        ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
end
if opt.weight
    % 如果label只有两个，则说明第一组被试的label为大label，则weight需要取相反数
    if numel(unique(label))==2
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=-reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    else
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    end
end
%% visualize performance
if opt.viewperformance
    plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
        opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)
end
%% 保存最佳的分类权重图并保存结果
Time=datestr(now,30);
if opt.saveresults
    % 存放结果路径
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path的上一层目录
    % gray matter mask
    if opt.weight
        [file_name,path_source1,~]= uigetfile( ...
            {'*.img;*.nii;','All Image Files';...
            '*.*','All Files' },...
            '请选择mask（单选）', ...
            'MultiSelect', 'off');
        img_strut_temp=load_nii([path_source1,char(file_name)]);
        mask_graymatter=img_strut_temp.img~=0;
        W_M_Brain_3D(~mask_graymatter)=0;
        % save nii
        cd (outdir)
        Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
    end
    % 保存结果，并且确定哪些被试的分类效果不好
    label_ForPerformance= cell2mat( label_ForPerformance);
%     labelPredict=cell2mat(labelPredict);
    loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
    name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','predict_label_best','name_badsubjects',...
        'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best',...
        'indiceCell');
end
end

