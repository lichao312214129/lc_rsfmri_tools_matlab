function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    SVM_LC_Kfold_RFEandUnivariate4_ForPermu(opt,data_inmask_p,data_inmask_c,Train_label)
%=========SVM classification using RFE========================
% new feature:将fitclinear改为fitcsvm，从而使每次建立的机器学习模型一样;2018-02-03 by Li Chao
%注意：
    % 此代码保存的权重图为N-fold中consensus的平均权重图，refer to《Multivariate classification of social anxiety disorder
    % using whole brain functional connectivity》。
    % 由于fitclinear和indices的随机性，每次的结果可能有差异！！！
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
% msgbox('由于fitclinear和indices的随机性，每次的结果可能有差异！！！')
%% set options

%% ===transform .nii/.img into .mat data, and achive corresponding label=========

%% ==========just opt.Keep data in inmasopt.K========================

%% ==================确定t检验后可能出现的最小的特征数================

% 确定文件名的顺序，为后面确定哪些样本分类不好做准备

% 进入此段代码的主程序
for i=1:opt.K
    % 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    % patients data
    Test_index_p = (indices_p == i); Train_index_p = ~Test_index_p;
    Test_data_p =data_inmask_p(Test_index_p,:);Train_data_p =data_inmask_p(Train_index_p,:);
    % controls data
    Test_index_c = (indices_c == i); Train_index_c = ~Test_index_c;
    Test_data_c =data_inmask_c(Test_index_c,:);Train_data_c =data_inmask_c(Train_index_c,:);
    % all data
    Train_data=[Train_data_p;Train_data_c];
    Test_data=[Test_data_p;Test_data_c];
    % all label
    Train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
    % 打乱所有的训练label
    Rand_Num=randperm(numel(Train_label));
     Train_label= Train_label(Rand_Num);
    % step2： 标准化或者归一化
    if strcmp(opt.standard,'normalizing')
        MeanValue = mean(Train_data);
        StandardDeviation = std(Train_data);
        [row_quantity, columns_quantity] = size(Train_data);
        Train_data_temp=zeros(row_quantity, columns_quantity);
        for ii = 1:columns_quantity
            if StandardDeviation(ii)
                Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
            end
        end
        Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
        Train_data=Train_data_temp;Test_data=Test_data_temp;
    end
    
    if strcmp(opt.standard,'scale')
        [Train_data_temp,PS] = mapminmax(Train_data');
        Train_data_temp=Train_data_temp';
        Test_data_temp = mapminmax('apply',Test_data',PS);
        Test_data_temp =Test_data_temp';
        Train_data=Train_data_temp;
%         Test_data=Test_data_temp;
    end
    
    % 加入单变量的特征过滤
    [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
    Index_ttest2=find(P<=opt.P_threshold);
    if ~opt.permutation
        disp(['Number of remained feature of the ',num2str(i),'it ','fold',' = ',num2str(numel(Index_ttest2))]);
    end
    if Num_FeatureSet_min>=numel(Index_ttest2)
        Num_FeatureSet_min=numel(Index_ttest2);
    end
end

% 如果最小特征小于预设的最大特征,则将最大特征改为t检验中出现的最小特征数，相应的步长和其实也改变
if Num_FeatureSet_min< opt.Max_FeatureQuantity
    if ~opt.permutation
        disp(['t检验后的特征数目少于设定的最大特征数，将执行根据最小特征数的程序，最小特征为：',num2str(Num_FeatureSet_min)]);
    end
    opt.Initial_FeatureQuantity=10;opt.Step_FeatureQuantity=floor(Num_FeatureSet_min/100);opt.Max_FeatureQuantity=Num_FeatureSet_min;
end
%% =======================进入主程序===============================
% 预分配空间
Num_FeatureSet=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
Accuracy=zeros(opt.K,Num_FeatureSet);Sensitivity =zeros(opt.K,Num_FeatureSet);Specificity=zeros(opt.K,Num_FeatureSet);
AUC=zeros(opt.K,Num_FeatureSet);Decision=cell(opt.K,Num_FeatureSet);PPV=zeros(opt.K,Num_FeatureSet); NPV=zeros(opt.K,Num_FeatureSet);
W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);%不同特征子集时平均的weight（outer opt.K-fold的平均）
W_Brain=zeros(Num_FeatureSet,sum(implicitmask),opt.K);
label_ForPerformance=cell(opt.K,1);
predict_label=cell(opt.K,Num_FeatureSet);
Predict=NaN(opt.K,N,1);
%%  ====================K fold loop===============================
h1=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
switch opt.K<N %opt.K-fold or LOOCV
    case 1
        for i=1:opt.K %Outer opt.K-fold + Inner RFE
            waitbar(i/opt.K,h1,sprintf('%2.0f%%', i/opt.K*100)) ;
            % step1：split data into training data and testing  data
            % 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
            % patients data
            Test_index_p = (indices_p == i); Train_index_p = ~Test_index_p;
            Test_data_p =data_inmask_p(Test_index_p,:);Train_data_p =data_inmask_p(Train_index_p,:);
            % controls data
            Test_index_c = (indices_c == i); Train_index_c = ~Test_index_c;
            Test_data_c =data_inmask_c(Test_index_c,:);Train_data_c =data_inmask_c(Train_index_c,:);
            % all data
            Train_data=[Train_data_p;Train_data_c];
            Test_data=[Test_data_p;Test_data_c];
            % all label
            Test_label = [ones(sum(indices_p==i),1);zeros(sum(indices_c==i),1)];
            Train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
            %% step2： 标准化或者归一化
            if strcmp(opt.standard,'normalizing')
                MeanValue = mean(Train_data);
                StandardDeviation = std(Train_data);
                [row_quantity, columns_quantity] = size(Train_data);
                Train_data_temp=zeros(row_quantity, columns_quantity);
                for ii = 1:columns_quantity
                    if StandardDeviation(ii)
                        Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
                    end
                end
                Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            
            if strcmp(opt.standard,'scale')
                [Train_data_temp,PS] = mapminmax(Train_data');
                Train_data_temp=Train_data_temp';
                Test_data_temp = mapminmax('apply',Test_data',PS);
                Test_data_temp =Test_data_temp';
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            %% step3：加入单变量的特征过滤
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
            Index_ttest2=find(P<=opt.P_threshold);%将小于等于某个P值得特征选择出来。
            Train_data= Train_data(:,Index_ttest2);
            Test_data=Test_data(:,Index_ttest2);
            %% step4：Feature selection---RFE
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM2( Train_data,Train_label,opt );
            %% step5： training model and predict test data using different feature subsets which were selected by step4
            %step4：Feature selection---RFE
            j=0;%计数，为W_M_Brain赋值。
            h2 = waitbar(0,'...');
            for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity %
                w_brain=zeros(1,sum(implicitmask));
                j=j+1;%计数。
                waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100)) ;
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
                    loc_implicitmask=Index_ttest2(Index_selectfeature);
                    w_brain(loc_implicitmask) = reshape(model.Beta,1,numel(model.Beta));
                    W_Brain(j,:,i) = w_brain;%此W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                end
                %             if ~randi([0 4])
                %                 parfor_progress;%进度条
                %             end
            end
            close (h2)
        end
        close (h1)
%% ==============================================================
    case 0 %equal to leave one out cross validation, LOOCV
        for i=1:opt.K %Outer LOOCV + Inner RFE
            waitbar(i/opt.K,h1,sprintf('%2.0f%%', i/opt.K*100)) ;
            % step1：split data into training data and testing  data
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            label_ForPerformance(i)=Test_label;
            %% step2： 标准化或者归一化
            if strcmp(opt.standard,'normalizing')
                MeanValue = mean(Train_data);
                StandardDeviation = std(Train_data);
                [row_quantity, columns_quantity] = size(Train_data);
                Train_data_temp=zeros(row_quantity, columns_quantity);
                for ii = 1:columns_quantity
                    if StandardDeviation(ii)
                        Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
                    end
                end
                Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            
            if strcmp(opt.standard,'scale')
                [Train_data_temp,PS] = mapminmax(Train_data');
                Train_data_temp=Train_data_temp';
                Test_data_temp = mapminmax('apply',Test_data',PS);
                Test_data_temp =Test_data_temp';
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            %% step3：加入单变量的特征过滤
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
            Index_ttest2=find(P<=opt.P_threshold);%将小于等于某个P值得特征选择出来。
            Train_data= Train_data(:,Index_ttest2);
            Test_data=Test_data(:,Index_ttest2);
            %% step4：Feature selection---RFE
            opt.stepmethod='percentage';opt.step=10;
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM( Train_data,Train_label,opt );
            j=0;%计数，为W_M_Brain赋值。
            h2 = waitbar(0,'...');
            for FeatureQuantity=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity % 不同特征数目情况下
                w_brain=zeros(1,sum(implicitmask));
                j=j+1;%计数。
                waitbar(j/Num_FeatureSet,h2,sprintf('%2.0f%%', j/Num_FeatureSet*100));
                Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
                train_data= Train_data(:, Index_selectfeature);
                test_data=Test_data(:, Index_selectfeature);
                % 训练模型&预测
                model= fitclinear(train_data,Train_label);
                % 预测 or 分类
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                Predict(i,j,1)=predict_label;
                %  空间判别模式
                if opt.weight
                    loc_implicitmask=Index_ttest2(Index_selectfeature);
                    w_brain(loc_implicitmask) = reshape(model.Beta,1,numel(model.Beta));
                    W_Brain(j,:,i) = w_brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                end
            end
            close (h2)
        end
        close (h1)
end
%% ================公用的代码==================================
if opt.weight
    %% consensus中平均的空间判别模式
    binary_mask=W_Brain~=0;
    sum_binary_mask=sum(binary_mask,3);
    loc_consensus=sum_binary_mask>=opt.percentage_consensus*opt.K; num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
    if ~opt.permutation
        disp(['consensus voxel = ' num2str(num_consensus)]);
    end
    W_mean=mean(W_Brain,3);%取所有fold的 W_Brain的平均值
    W_mean(~loc_consensus)=0;%set weights located in the no consensus location to zero.
    W_M_Brain(:,implicitmask)=W_mean;%不同feature 数目时的全脑体素权重
end
%% 整理分类性能
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% 计算模型在opt.K fold中的平均性能，或者LOOCV的性能
if opt.K<N
    performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
        [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%综合分类表现，前一半是Mean 后一半是Std
elseif opt.K==N
    [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,label_ForPerformance);
    AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
    performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%综合分类表现
end
%% identify the best performance，以及其相应的特征数（包括consensus特征数），并确定相应的weight。num_consensus
%以AUC为标准找到最好的AUC所在位置，并找到最好的分类表现以及最好AUC对应的weight
N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
meanAUC=performances(6,(1:1:N_plot)); meanaccuracy=performances(1,(1:1:N_plot));
meansensitivity=performances(2,(1:1:N_plot));meanspecificity=performances(3,(1:1:N_plot));
loc_best_meanaccuracy=find(meanaccuracy==max(meanaccuracy));%参考分类性能:Accuracy
loc_best_meanaccuracy=loc_best_meanaccuracy(1);
AUC_best=meanAUC(loc_best_meanaccuracy);Accuracy_best=meanaccuracy(loc_best_meanaccuracy);
%for permutation test
Sensitivity_best=meansensitivity(loc_best_meanaccuracy); Specificity_best=meanspecificity(loc_best_meanaccuracy);
predict_label_best=predict_label(:,loc_best_meanaccuracy);
predict_label_best=cell2mat(predict_label_best);
if ~opt.permutation
    disp(['best AUC,Accuracy,Sensitivity and Specificity = '...
        ,num2str([AUC_best,Accuracy_best,Sensitivity_best,Specificity_best])]);
end
%相应的特征数、及consensus特征数
if opt.weight
    NumBestConsensusFeature=num_consensus(loc_best_meanaccuracy);
    AllFeatureSubset=(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
    NumBestFeature=AllFeatureSubset(loc_best_meanaccuracy);
    W_M_Brain_best=W_M_Brain(loc_best_meanaccuracy,:);
    W_M_Brain_3D=reshape(W_M_Brain_best,dim1,dim2,dim3);%best W_M_Brain_3D
    if ~opt.permutation
        disp(['NumBestConsensusFeature and NumBestFeature = ' num2str(NumBestConsensusFeature),' and ', num2str(NumBestFeature),' respectively']);
    end
end
%% visualize performance
if opt.viewperformance
    % Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
    N_plot=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity);
    figure;
    plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(1,(1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2);title('Mean accuracy');
    figure;
    plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(2,(1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2);title('Mean sensitivity');
    figure;
    plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(3,(1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2);title('Mean specificity');
    figure;
    plot((opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity),performances(6,(1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2); title('Mean AUC');
    % error bar of Accuracy
     figure;
%      errorbar(mean(Accuracy),std(Accuracy));
     dy=std(Accuracy);
     MeanAccurcay=mean(Accuracy);
     loc_maxAccuracy=find(mean(Accuracy)==max(mean(Accuracy)));
     loc_maxAccuracy= loc_maxAccuracy(1);
     maxAccuracy= MeanAccurcay(loc_maxAccuracy);
     axis_x=1:size(Accuracy,2);
%      axis_x=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity;
     fig_fill=fill([axis_x,fliplr(axis_x)],[MeanAccurcay-dy,fliplr(MeanAccurcay+dy)],[0.5 0.2 0.2]);%填充CI
     fig_fill.EdgeColor=[0.8 0.2 0.2];fig_fill.FaceColor='r';fig_fill.LineStyle='none';
     fig_fill.FaceAlpha=0.3;
     hold on;
          line([loc_maxAccuracy,loc_maxAccuracy],[maxAccuracy-dy(loc_maxAccuracy),maxAccuracy+dy(loc_maxAccuracy)],'Color',[1 0 0],'LineWidth',2);
          plot(loc_maxAccuracy,maxAccuracy,'o','MarkerSize',8,'Color',[1 0 0],'LineWidth',2)
          plot(axis_x,MeanAccurcay,'-','MarkerSize',8,'Color',[0.6 0 0],'LineWidth',1)
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

