function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    MVPA_2D(opt,data,label)
%=========SVM classification using RFE========================
%注意：
% 此代码保存的权重图为N-fold中consensus的平均权重图，refer to《Multivariate classification of social anxiety disorder
% using whole brain functional connectivity》。
% 由于fitclinear和indices的随机性，每次的结果可能有差异！！！
% 在开始RFE之前可以加入单变量的特征过滤，如F-score 、opt.Kendall Tau、Two-sample t-test等
% refer to PMID:18672070 opt.Initial_FeatureQuantity
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
    opt.standard='scale';
    opt.min_scale=0;
    opt.max_scale=1;
    % univariate feature filter.
    opt.P_threshold=0.1;
    % RFE
    opt.learner='svm';
    opt.stepmethod='percentage';
    opt.step=10;
    % feature subset
    opt.Initial_FeatureQuantity=1;
    opt.Max_FeatureQuantity=400;
    opt.Step_FeatureQuantity=1;
    % calculate weight map
    opt.weight=0;
    % The frequence of the occurrence of the same voxels/features which used to generate weight map; range=(0,1];
    opt.percentage_consensus=0.5;
    % view performances
    opt.viewperformance=0;
    % save results
    opt.saveresults=0;
end
%% ===============image to data and produce label==================

%% ===========just keep data in mask,and reshape data=============

%% 确定是否载入已有的交叉验证方式,并为后面确定哪些样本分类不好做准备

%% =======================预分配空间===============================
% Num_FeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
% Accuracy=zeros(opt.K,Num_FeatureSet);Sensitivity =zeros(opt.K,Num_FeatureSet);Specificity=zeros(opt.K,Num_FeatureSet);
% AUC=zeros(opt.K,Num_FeatureSet);Decision=cell(opt.K,Num_FeatureSet);PPV=zeros(opt.K,Num_FeatureSet); NPV=zeros(opt.K,Num_FeatureSet);
% W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);
% W_Brain=zeros(Num_FeatureSet,sum(maskForFilter),opt.K);
% label_ForPerformance=cell(opt.K,1);
% predict_label=cell(opt.K,Num_FeatureSet);
%%  ====================K fold loop===============================
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1：将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    n_patients=sum(label==1);
    n_controls=sum(label~=1);
    indices_p = crossvalind('Kfold', n_patients, opt.K);
    indices_c = crossvalind('Kfold', n_controls, opt.K);
    indiceCell={indices_c,indices_p};% 注意:因为求unique label是是从小到大的顺序，所以control的indices放前面
    [Train_data,Test_data,Train_label,Test_label]=...
        BalancedSplitDataAndLabel(data,label,indiceCell,i);
    % step2： 标准化或者归一化
    [Train_data,Test_data]=Standardization(Train_data,Test_data,opt.standard);
    % step3：加入单变量的特征过滤
    [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    Index_ttest2=find(P<=opt.P_threshold);
    Train_data= Train_data(:,Index_ttest2);
    Test_data=Test_data(:,Index_ttest2);
    % step4：Feature selection---RFE
    [ feature_ranking_list ] = FeatureSelection_RFE_SVM2( Train_data,Train_label,opt );
    % step5： training model and predict test data using different feature subset
    if ~opt.permutation; h1 = waitbar(0,'...');end
    numOfMaxFeatureQuantity=min(opt.Max_FeatureQuantity,length(Index_ttest2));%最大特征数
    numOfMaxFeatureIteration=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity);%最大迭代次数
    j=0;% count
    for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity
        j=j+1;%计数
        if ~opt.permutation
            waitbar(j/numOfMaxFeatureIteration,h1,sprintf('%2.0f%%', j/numOfMaxFeatureIteration*100)) ;
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
        [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,1));
        %  空间判别模式
        if opt.weight
            W_Brain(j,:,i)=data2originIndex({Index_ttest2,Index_selectfeature},...
                reshape(model.Beta,1,numel(model.Beta)),67541);
        end
    end
    if ~opt.permutation
        close (h1);
    end
    % step 5 completed!
end
close (h);
%% ====================公用的代码==================================
% 计算平均的空间判别模式，并筛选频率低的weight
if opt.weight
    W_mean=AverageWeightMap(W_Brain,opt.percentage_consensus);% W_mean的维度和maskForFilter一致。
%     W_M_Brain=data2originIndex({find(maskForFilter~=0)},W_mean,length(maskForFilter));
    W_M_Brain(:,maskForFilter~=0)=W_mean;%不同feature 数目时的全脑体素权重
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
    % 如果label只有两个，则说明第一组被试的label为大label，则weight需要取相反数
    if unique(label)==2
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=-reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    else
        W_M_Brain_best=W_M_Brain(loc_best,:);
        W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    end
end
%% visualize performance
% if opt.viewperformance
%     plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
%         opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)
% end
% %% 保存最佳的分类权重图并保存结果
% Time=datestr(now,30);
% if opt.saveresults
%     %存放结果路径
%     loc= find(path=='\');
%     outdir=path(1:loc(length(find(path=='\'))-2)-1);%path的上一层目录
%     %gray matter masopt.K
%     if opt.weight
%         [file_name,path_source1,~]= uigetfile( ...
%             {'*.img;*.nii;','All Image Files';...
%             '*.*','All Files' },...
%             '请选择mask（单选）', ...
%             'MultiSelect', 'off');
%         img_strut_temp=load_nii([path_source1,char(file_name)]);
%         mask_graymatter=img_strut_temp.img~=0;
%         W_M_Brain_3D(~mask_graymatter)=0;
%         % save nii
%         cd (outdir)
%         Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%     end
%     % 保存结果，并且确定哪些被试的分类效果不好
%     label_ForPerformance= cell2mat( label_ForPerformance);
%     predict_label=cell2mat(predict_label);
%     loc_badsubjects=(label_ForPerformance-predict_label_best)~=0;
%     name_badsubjects=name_all_sorted(loc_badsubjects);
%     save([outdir filesep [Time,'Results_MVPA.mat']],...
%         'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
%         'label_ForPerformance','predict_label_best','name_badsubjects',...
%         'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best',...
%         'indiceCell');
% end
end

