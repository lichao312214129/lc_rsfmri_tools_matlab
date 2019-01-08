function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    SVM_LC_Kfold_RFEandUnivariate5(opt,dataMat,label)
%=========SVM classification using RFE========================
%注意：
% 此代码保存的权重图为N-fold中consensus的平均权重图，refer to《Multivariate classification of social anxiety disorder
% using whole brain functional connectivity》。
% 由于fitclinear和indices的随机性，每次的结果可能有差异！！！
% 在开始RFE之前可以加入单变量的特征过滤，如F-score 、opt.Kendall Tau、Two-sample t-test等
% refer to PMID:18672070opt.Initial_FeatureQuantity
% input：opt.K=opt.K-fold cross validation,opt.K<=N;
% [opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=初始的特征数,最大特征数,每次增加的特征数。
% opt.P_threshold 为单变量来特征过滤是的P阈值;opt.percentage_consensus为在
% opt.K fold中某个权重不为零的体素出现的概率，如opt.percentage_consensus=0.8，opt.K=5，则出现5*0.8=4次以上的体素才认为是consensus体素。
% output：分类表现以及opt.K-fold的平均分类权重
% performances(:,1:size(performances,2)/2)=性能，余下的为标准差。
% new feature:将fitclinear改为fitcsvm，从而使每次建立的机器学习模型一样;2018-02-03 by Li Chao
% New: 代码模块化，已增加代码的延展性可以可移植性。2018-03-08 by Li Chao
%% set options
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.1;%The most frequent voxels/features;range=(0,1];
    opt.weight=1;opt.viewperformance=1;opt.saveresults=1;
    opt.standard='normalizing';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
    opt.IfLoadIndices=0;
end
%% ===============image to data and produce label==================
% 如果是置换检验则不读图像，数据由上一层代码提供
% data
if nargin<2 
    [fileName,folderPath,dataCell] =Img2Data_MultiGroup(2);
    path=folderPath{1};
    name_patients=fileName{1};
    name_controls=fileName{2};
    [dataMatCell]=dataCell2Mat(dataCell,1,'groupFirst');% 按特征分配到各个cell
    dataMat=dataMatCell{1};
end
% label
if nargin<3
    [label]=generateLabel(dataCell,1, 'groupFirst');
end
[dim1,dim2,dim3,Num_AllSub]=size(dataMat);
n_patients=sum(label==1);
n_controls=sum(label==0);
%% ==========just keep data in mask========================
[data_inmask,maskForFilter]=FeatureFilterByMask(dataMat,[],'implicit');
data_inmask_p=data_inmask(label==1,:);
data_inmask_c=data_inmask(label==0,:);
%% 确定是否载入已有的交叉验证方式,并为后面确定哪些样本分类不好做准备
if ~opt.permutation
    % 当不是置换检验时，就根据用户来确定是否载入已有的交叉验证方式
    if opt.IfLoadIndices==0
        indices = crossvalind('Kfold', Num_AllSub, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
        indices_p = crossvalind('Kfold', n_patients, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
        indices_c = crossvalind('Kfold', n_controls, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
    else
        [~,indices_p,indices_c]=LoadIndices();
    end
else
    % 当是置换检验时，就算计交叉验证
    indices = crossvalind('Kfold', Num_AllSub, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
    indices_p = crossvalind('Kfold', n_patients, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
    indices_c = crossvalind('Kfold', n_controls, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
end
% 当不是置换检验时，则确定文件名的顺序，为后面确定哪些样本分类不好做准备
name_all_sorted=SortNameAccordIndices(name_patients,name_controls,indices_p,indices_c,opt);
%% ==================确定t检验后可能出现的最小的特征数================
Num_FeatureSet_min=Inf;
Index_ttest2=cell(opt.K,1);
for i=1:opt.K
    %% 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    [Train_data,Test_data,Train_label,~]=...
    BalancedSplitDataAndLabel(data_inmask_p,data_inmask_c,indices_p,indices_c,i);
    %% step2： 标准化或者归一化
    [Train_data,~]=Standardization(Train_data,Test_data,opt.standard);
    % 加入单变量的特征过滤
    [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    Index_ttest2{i}=find(P<=opt.P_threshold);
    if ~opt.permutation
        disp(['Number of remained feature of the ',num2str(i),'it ','fold',' = ',num2str(numel(Index_ttest2{i}))]);
    end
    if Num_FeatureSet_min>=numel(Index_ttest2{i})
        Num_FeatureSet_min=numel(Index_ttest2{i});
    end
end

%% ==============如果最小特征小于预设的最大特征,则将最大特征改为t检验中出现的最小特征数，相应的步长和其实也改变========
if Num_FeatureSet_min< opt.Max_FeatureQuantity
    if ~opt.permutation
        disp(['t检验后的特征数目少于设定的最大特征数，将执行根据最小特征数的程序，最小特征为：',num2str(Num_FeatureSet_min)]);
    end
    opt.Initial_FeatureQuantity=10;opt.Step_FeatureQuantity=floor(Num_FeatureSet_min/100);opt.Max_FeatureQuantity=Num_FeatureSet_min;
end
%% =======================预分配空间===============================
Num_FeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
Accuracy=zeros(opt.K,Num_FeatureSet);Sensitivity =zeros(opt.K,Num_FeatureSet);Specificity=zeros(opt.K,Num_FeatureSet);
AUC=zeros(opt.K,Num_FeatureSet);Decision=cell(opt.K,Num_FeatureSet);PPV=zeros(opt.K,Num_FeatureSet); NPV=zeros(opt.K,Num_FeatureSet);
W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);
W_Brain=zeros(Num_FeatureSet,sum(maskForFilter),opt.K);
label_ForPerformance=cell(opt.K,1);
predict_label=cell(opt.K,Num_FeatureSet);
%%  ====================K fold loop===============================
h1=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
for i=1:opt.K %Outer opt.K-fold + Inner RFE
    waitbar(i/opt.K,h1,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1：split data into training data and testing  data
    % 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    [Train_data,Test_data,Train_label,Test_label]=...
        BalancedSplitDataAndLabel(data_inmask_p,data_inmask_c,indices_p,indices_c,i);
    %% step2： 标准化或者归一化
    [Train_data,Test_data]=Standardization(Train_data,Test_data,opt.standard);
    %% step3：加入单变量的特征过滤
    %             [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    %             Index_ttest2=find(P<=opt.P_threshold);%将小于等于某个P值得特征选择出来。
    Train_data= Train_data(:,Index_ttest2{i});
    Test_data=Test_data(:,Index_ttest2{i});
    %% step4：Feature selection---RFE
    [ feature_ranking_list ] = FeatureSelection_RFE_SVM2( Train_data,Train_label,opt );
    %% step5： training model and predict test data using different feature subsets which were selected by step4
    %step4：Feature selection---RFE
    j=0;%计数，为W_M_Brain赋值。
     if ~opt.permutation; h2 = waitbar(0,'...');end
    for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity %
        w_brain=zeros(1,sum(maskForFilter));
        j=j+1;%计数。
         if ~opt.permutation
             waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100)) ;
         end
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        train_data= Train_data(:,Index_selectfeature);
        test_data=Test_data(:,Index_selectfeature);
        label_ForPerformance{i,1}=Test_label;
        % 训练模型&预测
        model= fitcsvm(train_data,Train_label);
        [predict_label{i,j}, dec_values] = predict(model,test_data);
        Decision{i,j}=dec_values(:,2);
        % estimate mode/SVM
        [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label{i,j},Test_label);
        Accuracy(i,j) =accuracy;
        Sensitivity(i,j) =sensitivity;
        Specificity(i,j) =specificity;
        PPV(i,j)=ppv;
        NPV(i,j)=npv;
        [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,2));
        %  空间判别模式
        if opt.weight
            W_Brain(j,:,i)=data2OriginIndex({Index_ttest2{i},Index_selectfeature},...
                reshape(model.Beta,1,numel(model.Beta)),67541);
%             Index_ttest2_mask=Index_ttest2{i};
%             loc_maskForFilter=Index_ttest2_mask(Index_selectfeature);
%             w_brain(loc_maskForFilter) = reshape(model.Beta,1,numel(model.Beta));
%             W_Brain(j,:,i) = w_brain;%此W_Brian将Index(1:N_feature)以外位置的体素权重设为0
        end
    end
     if ~opt.permutation; close (h2);end
end
close (h1)
%% ====================公用的代码==================================
% 计算平均的空间判别模式，并筛选频率低的weight
if opt.weight
    W_mean=AverageWeightMap(W_Brain,opt.percentage_consensus);% W_mean的维度和maskForFilter一致。
    W_M_Brain(:,maskForFilter)=W_mean;%不同feature 数目时的全脑体素权重
end
% 计算最佳的分类性能
 [loc_best,predict_label_best,performances,Accuracy_best,Sensitivity_best,Specificity_best,...
         ~,~,AUC_best]=...
         IdentifyBestPerformance(predict_label,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,'accuracy');
 % disply best performances
if ~opt.permutation
    disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
        ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
end
%相应的特征数、及consensus特征数
if opt.weight
    W_M_Brain_best=W_M_Brain(loc_best,:);
    W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
end
%% visualize performance
if opt.viewperformance
    plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
    opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)
end
%% 保存最佳的分类权重图并保存结果
Time=datestr(now,30);
if opt.saveresults
    %存放结果路径
    loc= find(path=='\');
    outdir=path(1:loc(length(find(path=='\'))-2)-1);%path的上一层目录
    %gray matter masopt.K
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
    predict_label=cell2mat(predict_label);
    loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
    name_badsubjects=name_all_sorted(loc_badsubjects);
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance','predict_label_best','name_badsubjects',...
        'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best',...
        'indices','indices_p','indices_c');
end
end

