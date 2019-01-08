function [Accuracy, Sensitivity, Specificity, PPV, NPV] =...
    Logistic_Regression_Univariatefilter_ElasticNet_Alpha(opt)
%=========SVM classification using RFE========================
%注意：此代码保存的权重图为N-fold中consensus的平均权重图，refer to《Multivariate classification of social anxiety disorder
% using whole brain functional connectivity》。
%在开始RFE之前可以加入单变量的特征过滤，如F-score 、opt.Kendall Tau、Two-sample t-test等
%refer to PMID:18672070opt.Initial_FeatureQuantity
%input：opt.K=opt.K-fold cross validation,opt.K<=N;
%[opt.Initial_FeatureQuantity,opt.Max_FeatureQuantity,opt.Step_FeatureQuantity]=初始的特征数,最大特征数,每次增加的特征数。
%opt.P_threshold 为单变量来特征过滤是的P阈值;opt.percentage_consensus为在
% opt.K fold中某个权重不为零的体素出现的概率，如opt.percentage_consensus=0.8，opt.K=5，则出现5*0.8=4次以上的体素才认为是consensus体素。
%output：分类表现以及opt.K-fold的平均分类权重
%performances(:,1:size(performances,2)/2)=性能，余下的为标准差。
%indices= 随机种子 为了在小范围内测试
% path=pwd;
% addpath(path);
%% set options
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.0001;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.7;%The most frequent voxels/features;range=(0,1];
    opt.weight=0;opt.viewperformance=0;opt.saveresults=0;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
    opt.lambda=exp(-6:6);opt.alpha=0.1:0.1:1;
end
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
% if nargin<2 %如果是置换检验则不读图像，数据由上一层代码提供
    [~,path,data_patients ] = Img2Data_LC;
    [~,~,data_controls ] = Img2Data_LC;
    data=cat(4,data_patients,data_controls);%data
    n_patients=size(data_patients,4);
    n_controls=size(data_controls,4);
% end
% if nargin<3
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
% end
[dim1,dim2,dim3,N]=size(data);
%% ==========just opt.Keep data in inmasopt.K========================
data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
implicitmask = sum(data,2)~=0;%内部masopt.K,逐行累加
data_inmask=data(implicitmask,:);%内部masopt.K内的data
data_inmask=data_inmask';
%%
[ B0,Predict_label,Real_label,Decision ] = ...
    Logistic_Regression_ElasticNet(data_inmask,label,opt);
%% 分类表现
[Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(cell2mat(Predict_label),cell2mat(Real_label));
AUC=AUC_LC(cell2mat(Real_label),cell2mat(Decision));












%% ==================确定t检验后可能出现的最小的特征数===============


%% ==============如果最小特征小于预设的最大特征,则将最大特征改为t检验中出现的最小特征数，相应的步长和其实也改变========

%% =======================预分配空间===============================

%%  ====================opt.K fold loop===============================
%
% %% ================公用的代码==================================
% if opt.weight
%     %% consensus中平均的空间判别模式
%     binary_mask=W_Brain~=0;
%     sum_binary_mask=sum(binary_mask,3);
%     loc_consensus=sum_binary_mask>=opt.percentage_consensus*opt.K; num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
%     if ~opt.permutation
%         disp(['consensus voxel = ' num2str(num_consensus)]);
%     end
%     W_mean=mean(W_Brain,3);%取所有fold的 W_Brain的平均值
%     W_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero.
%     W_M_Brain(:,implicitmask)=W_mean;%不同feature 数目时的全脑体素权重
% end
%% 整理分类性能
% Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
% PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
% %% 计算模型在opt.K fold中的平均性能，或者LOOCV的性能
% if opt.K<N
%     performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
%         [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%综合分类表现，前一半是Mean 后一半是Std
% elseif opt.K==N
%     [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
%     AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
%     performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%综合分类表现
% end
% %% identify the best performance，以及其相应的特征数（包括consensus特征数），并确定相应的weight。num_consensus
% %以AUC为标准找到最好的AUC所在位置，并找到最好的分类表现以及最好AUC对应的weight
% N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
% meanAUC=performances(6,(1:1:N_plot)); meanaccuracy=performances(1,(1:1:N_plot));
% meansensitivity=performances(2,(1:1:N_plot));meanspecificity=performances(3,(1:1:N_plot));
% loc_best_meanAUC=find(meanAUC==max(meanAUC));
% loc_best_meanAUC=loc_best_meanAUC(1);
% AUC_best=meanAUC(loc_best_meanAUC);Accuracy_best=meanaccuracy(loc_best_meanAUC);
% Sensitivity_best=meansensitivity(loc_best_meanAUC); Specificity_best=meanspecificity(loc_best_meanAUC);%for permutation test
% if ~opt.permutation
%     disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
%         ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
% end
% %相应的特征数、及consensus特征数
% if opt.weight
%     NumBestConsensusFeature=num_consensus(loc_best_meanAUC);
%     AllFeatureSubset=(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
%     NumBestFeature=AllFeatureSubset(loc_best_meanAUC);
%     W_M_Brain_best=W_M_Brain(loc_best_meanAUC,:);
%     W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
%     if ~opt.permutation
%         disp(['NumBestConsensusFeature and NumBestFeature = ' num2str(NumBestConsensusFeature),' and ', num2str(NumBestFeature),' respectively']);
%     end
% end
% %% visualize performance
% if opt.viewperformance
%     % Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
%     N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(1,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean accuracy');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(2,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean sensitivity');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(3,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2);title('Mean specificity');
%     figure;
%     plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(6,(1:1:N_plot)),...
%         '--o','markersize',5,'LineWidth',2); title('Mean AUC');
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
%             '请选择masopt.K（单选）', ...
%             'MultiSelect', 'off');
%         img_strut_temp=load_nii([path_source1,char(file_name)]);
%         mask_graymatter=img_strut_temp.img~=0;
%         W_M_Brain_3D(~mask_graymatter)=0;
%         % save nii
%         cd (outdir)
%         Data2Img_LC(W_M_Brain_3D,['W_M_Brain_3D_',Time,'.nii']);
%     end
%     %save results
%     save([outdir filesep [Time,'Results_MVPA.mat']],...
%         'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
%         'label_ForPerformance',...
%         'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best');
% end
end

