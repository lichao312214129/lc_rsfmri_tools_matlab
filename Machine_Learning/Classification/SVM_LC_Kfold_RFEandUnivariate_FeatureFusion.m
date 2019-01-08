function [AUC_best, Accuracy_best,Sensitivity_best,Specificity_best] =...
    SVM_LC_Kfold_RFEandUnivariate_FeatureFusion(opt,data,label)
%=========SVM classification using RFE========================
% 只能添加两个特征种类
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
%% ========================set options===========================
if nargin<1
    opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.05;% univariate feature filter.
    opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.7;%The most frequent voxels/features;range=(0,1];
    opt.weight=0;opt.viewperformance=1;opt.saveresults=1;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;
end
%% ===transform .nii/.img into .mat data, and achive corresponding label=========
if nargin<2 %如果是置换检验则不读图像，数据由上一层代码提供
    % nii to matrix
    [~,path,data_patients1 ] = Img2Data_LC('第1组：第1个特征');
    [~,~,data_patients2 ] = Img2Data_LC('第1组：第2个特征');
    [~,~,data_controls1 ] = Img2Data_LC('第2组：第1个特征');
    [~,~,data_controls2 ] = Img2Data_LC('第2组：第2个特征');
    % 获取数据维度，为后面的reshape做准备
    [dim1,dim2,dim3,~]=size(data_patients1);
    % 获取两组被试的样本量，为后面的cross-validation做准备
    n_patients=size(data_patients1,4);
    n_controls=size(data_controls1,4);
    N=n_patients+n_controls;
    label=[ones(n_patients,1);zeros(n_controls,1)];%label
    % just keep data in inmask
    % reshape
    data_patients1=reshape(data_patients1,[dim1*dim2*dim3,n_patients])';
    data_patients2=reshape(data_patients2,[dim1*dim2*dim3,n_patients])';
    data_controls1=reshape(data_controls1,[dim1*dim2*dim3,n_controls])';
    data_controls2=reshape(data_controls2,[dim1*dim2*dim3,n_controls])';
    % fusion
    data=[data_patients1,data_patients2;data_controls1,data_controls2];
    % 内部mask，将所有被试中全为0的某个特征删除
    implicitmask = sum(data,1)~=0; %内部mask
    data_inmask=data(:,implicitmask); %内部mask内的总data，为LOOCV所用
    data_inmask_p=data_inmask(label==1,:); %内部mask内的病人组data，为K-fold所用
    data_inmask_c=data_inmask(label==0,:);%内部mask内的正常组data，为K-fold所用
    if opt.permutation;disp(['number of patients and controls are ', num2str([n_patients, n_controls])]);end
end
% if nargin<3
%     label=[ones(n_patients,1);zeros(n_controls,1)];%label
% end
%% ==================确定t检验后可能出现的最小的特征数===============
Num_FeatureSet_min=Inf;
indices = crossvalind('Kfold', N, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
indices_p = crossvalind('Kfold', n_patients, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
indices_c = crossvalind('Kfold', n_controls, opt.K);%此处不受随机种子点控制，因此每次结果还是不一样。
for i=1:opt.K
    %% 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
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
W_M_Brain=zeros(Num_FeatureSet,dim1*dim2*dim3);%不同特征子集时平均的weight（outer opt.K-fold的平均）
W_Brain=zeros(Num_FeatureSet,sum(implicitmask),opt.K);
label_ForPerformance=NaN(N,1);
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
            [ feature_ranking_list ] = FeatureSelection_RFE_SVM( Train_data,Train_label,opt );
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
                label_ForPerformance(j:j+numel(Test_label)-1,1)=Test_label;
                % 训练模型&预测
                model= fitclinear(train_data,Train_label);
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                % estimate mode/SVM
                [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,Test_label);
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
loc_best_meanaccuracy=find(meanaccuracy==max(meanaccuracy));
loc_best_meanaccuracy=loc_best_meanaccuracy(1);
AUC_best=meanAUC(loc_best_meanaccuracy);Accuracy_best=meanaccuracy(loc_best_meanaccuracy);
Sensitivity_best=meansensitivity(loc_best_meanaccuracy); Specificity_best=meanspecificity(loc_best_meanaccuracy);%for permutation test
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
    %save results
    save([outdir filesep [Time,'Results_MVPA.mat']],...
        'Accuracy', 'Sensitivity', 'Specificity','PPV', 'NPV', 'Decision', 'AUC',...
        'label_ForPerformance',...
        'AUC_best','Accuracy_best','Sensitivity_best','Specificity_best');
end
end

