function [AUC,Accuracy,Sensitivity,Specificity] =...
    MVPA_PCA_nestedRFE2(opt,dataMat,label)
%=========Classification using PCA and RFE========================
% usage：
%       
%      refer to《Multivariate classification of social anxiety disorder
%      using whole brain functional connectivity》 and PMID:18672070。
%      1. 此代码保存的权重图为N-fold中consensus的平均权重图，
%      2. 由于fitclinear和indices的随机性，每次的结果可能有差异！！！
%      3. 在开始RFE之前可以加入单变量的特征过滤或者其他降维，如F-score 、opt.Kendall Tau、Two-sample
%      t-test等（此代码用PCA降维）
%      4. 此代码用的是nested RFE
% input：
%        opt.K=K-fold cross validation(opt.K<=N)        
%        [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=[初始的特征数,最大特征数,每次增加的特征数]
%        opt.P_threshold =单变量来特征过滤是的P阈值;
%        opt.percentage_consensus=K fold中某个权重不为零的体素出现的概率
%        如opt.percentage_consensus=0.8，opt.K=5，则出现5*0.8=4次以上的体素才认为是consensus体素。
% output：
%        分类表现以及K-fold的平均分类权重(部分直接保持为.mat文件)
% new:
%         nested RFE 找到最佳的特征数目后，再在外层训练集里根据这个特征数目建立模型
%% set options
if nargin<1
    % mask :'implicit' OR 'external'
    opt.maskSource='implicit';
    % how many modality/feature types
    opt.numOfFeatureType=1;
    % permutation test
    opt.permutation=0;
    % K fold CV
    opt.K=5;
    opt.innerK=10;
    % load old indices
    opt.IfLoadIndices=0;
    % standardization
    opt.standard='normalizing';
    opt.min_scale=0;
    opt.max_scale=1;
    % univariate feature filter.
    opt.P_threshold=0.1;
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
    opt.percentage_consensus=0.4;
    % view performances
    opt.viewperformance=1;
    % save results
    opt.saveresults=1;
end
%% ===============image to data and produce label==================
% 如果是置换检验则不读图像，数据由上一层代码提供
% data
if nargin<2
    [fileName,folderPath,dataCell] =Img2Data_MultiGroup('on',2);
    path=folderPath{1};
    name_patients=fileName{1};
    name_controls=fileName{2};
    [dataMatCell]=dataCell2Mat(dataCell,opt.numOfFeatureType,'groupFirst');% 按特征分配到各个cell
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
indices_p=indiceCell{1};
indices_c=indiceCell{2};
name_all_sorted=SortNameAccordIndices(name_patients,name_controls,indices_p,indices_c,opt);

%% =======================预分配空间===============================
Accuracy=zeros(opt.K,1);
Sensitivity =zeros(opt.K,1);
Specificity=zeros(opt.K,1);
AUC=zeros(opt.K,1);
Decision=cell(opt.K,1);
PPV=zeros(opt.K,1); 
NPV=zeros(opt.K,1);
%
W_M_Brain=zeros(1,dim1*dim2*dim3);
W_Brain=zeros(opt.K,sum(maskForFilter));
label_ForPerformance=cell(opt.K,1);
labelPredict=cell(opt.K,1);
%%  ====================K fold loop===============================
tic;
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % balance split
    [dataTrain,dataTest,labelTrain,labelTest]=...
        BalancedSplitDataAndLabel(data_inmask,label,indiceCell,i);
    label_ForPerformance{i}=labelTest;
    % standardization
    [dataTrain,dataTest]=Standardization(dataTrain,dataTest,opt.standard);
    % PCA
    [COEFF,dataTrain] = pca(dataTrain);%分别对训练样本、测试样本进行主成分降维。
    dataTest = dataTest*COEFF;
    % =========================nested RFE=============================
    indexOfRankedFeatures_Nested=zeros(opt.innerK,size(dataTrain,2));
    accuracy_Nested=zeros(opt.innerK,size(dataTrain,2));
    %
    indiceCell_Nested=generateIndiceForKfoldCV(labelTrain,opt.innerK);
    for iterInner=1:opt.innerK
        [dataTrain_Nested,dataTest_Nested,labelTrain_Nested,labelTest_Nested]=...
            BalancedSplitDataAndLabel(dataTrain,labelTrain,indiceCell_Nested,iterInner);
        % rfe feature selection
        indexOfRankedFeatures_Nested(iterInner,:)= FeatureSelection_RFE_SVM2( dataTrain_Nested,labelTrain_Nested,opt );
        % obtain accuracy using different feature subset
        for numOfFeature_Nested=1:1:size(dataTrain_Nested,2)
            index_Nested=indexOfRankedFeatures_Nested(iterInner,:);
            index_Nested= index_Nested(1:numOfFeature_Nested);
            dataTrainTemp_Nested=dataTrain_Nested(:,index_Nested);
            dataTestTemp_Nested=dataTest_Nested(:,index_Nested);
            model_Nested= classifier(dataTrainTemp_Nested,labelTrain_Nested);
            [labelPredict_Nested, ~] = predict(model_Nested,dataTestTemp_Nested);
            [accuracy_Nested(iterInner,numOfFeature_Nested),~,~,~,~]=Calculate_Performances(labelPredict_Nested,labelTest_Nested);
        end
    end
    % identify best feature subset(计算出最佳的特征数目后，根据特征在inner K-fold中出现的频率来选择特征)
    numOfBestFeatureSubset=find(mean(accuracy_Nested)==max(mean(accuracy_Nested)));
%     indexOfBestFeatureSubset=indexOfRankedFeatures_Nested(:,1:numOfBestFeatureSubset);
%     uniIndexOfBestFeatureSubset=unique(indexOfBestFeatureSubset);
%     myMinus=@(x) x-indexOfBestFeatureSubset;
%     cmpCell=arrayfun(myMinus,uniIndexOfBestFeatureSubset,'UniformOutput',false);
%     countZero=@(x) sum(sum(x==0));
%     numOfuniIndexOfBestFeatureSubset=cell2mat(cellfun(countZero,cmpCell,'UniformOutput',false));
%     freqOfuniIndexOfBestFeatureSubset=numOfuniIndexOfBestFeatureSubset/opt.innerK;
%     indOfSelectedFeature=freqOfuniIndexOfBestFeatureSubset>opt.percentage_consensus;
%     featureSelected=uniIndexOfBestFeatureSubset(indOfSelectedFeature);
    % =========================finished nested RFE=============================
    % training and predict/testing using optimized feature subsets
    model= classifier(dataTrain(:,1:numOfBestFeatureSubset),labelTrain);
    [labelPredict{i}, dec_values] = predict(model,dataTest(:,1:numOfBestFeatureSubset));
    Decision{i}=dec_values(:,2);
    % Calculate performance of model
    [Accuracy(i),Sensitivity(i),Specificity(i),PPV(i),NPV(i)]=Calculate_Performances(labelPredict{i},labelTest);
    [AUC(i)]=AUC_LC(labelTest,dec_values(:,1));
    %  空间判别模式
    weightOfComponent = model.Beta;
    weightOfFeature= weightOfComponent' * COEFF(:,1:numOfBestFeatureSubset)';
    weightOfFeature=reshape(weightOfFeature,1,numel(weightOfFeature));
    if opt.weight
        W_Brain(i,:)=weightOfFeature;
    end
end
toc
close (h);
toc
mean([AUC,Accuracy,Sensitivity,Specificity])
std([AUC,Accuracy,Sensitivity,Specificity])
%% ====================公用的代码==================================
% 计算平均的空间判别模式，并排除掉频率低的weight
if opt.weight
    W_mean= mean(W_Brain);
    W_M_Brain(:,maskForFilter~=0)=W_mean;%不同feature 数目时的全脑体素权重
end
% 计算最佳的分类性能

if opt.weight
    % 如果label只有两个，则说明第一组被试的label为大label，则weight需要取相反数
    if numel(unique(label))==2
        W_M_Brain_3D=-reshape(W_M_Brain,dim1,dim2,dim3);%best W_M_Brain_3D
    else
        W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);%best W_M_Brain_3D
    end
end
%% visualize performance

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
    labelPredict=cell2mat(labelPredict);
%     loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
%     name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','labelPredict',...
        'indiceCell');
end
end
