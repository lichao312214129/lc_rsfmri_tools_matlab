function [Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC,...
    w_M_Brain_3D, label_ForPerformance,sorted_fileName] =...
    SVM_LC_Kfold_PCA(K, mask, save_dir)
%%
% Please cite DPABI softerware
% input:
%   K: K-fold cross validation,K<N
%	mask: only retaine data in mask
%	save_dir: directory to save results
% output: classification performances, weight maps, labels and file names
%
%%
if nargin < 1
    K=10;
end
if nargin < 2
    mask_file = uigetfile('*.nii;*.img','Select mask file');
    [mask_3d,header] = y_Read(mask_file);
    mask_3d = mask_3d ~= 0;
    mask = reshape(mask_3d,[],1);
    %     mask_path='G:\Softer_DataProcessing\spm12\spm12\tpm\Reslice3_TPM_greaterThan0.2.nii';
end
if nargin < 3
    save_dir =  uigetdir(pwd,'Select results'' directory');
end

%% ----------------------------------------------------------------
% nii to matrix, and generate labels
[fileName_P,~,data_patients ] = lc_Img2Data;
[fileName_C,~,data_controls ] = lc_Img2Data;
data = cat(4,data_patients,data_controls);
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
label = [ones(n_patients,1);zeros(n_controls,1)];

% data in mask (needs dpabi software)
N = n_patients+n_controls;
data = reshape(data,[dim1*dim2*dim3,N]);  % Column is a sample, each row is a feature.
% implicitmask = sum(data~=0,2)>=size(data,2)-10;  % inner mask
% data_inmask=data(implicitmask,:);%  data in inner mask
data_inmask=data(mask,:);
data_inmask=data_inmask';
data_inmask_p=data_inmask(label==1,:);
data_inmask_c=data_inmask(label==0,:);

% Preallocate memory
Accuracy=zeros(K,1);
Sensitivity =zeros(K,1);
Specificity=zeros(K,1);
AUC=zeros(K,1);
Decision=cell(K,1);
PPV=zeros(K,1);
NPV=zeros(K,1);
w_Brain=zeros(K,sum(mask));
label_ForPerformance=cell(K,1);
w_M_Brain=zeros(1,dim1*dim2*dim3);
Predict=NaN(N,1);
sorted_fileName={};

%  K fold loop
rng(66);
indices = crossvalind('Kfold', N, K);
indices_p = crossvalind('Kfold', n_patients, K);
indices_c = crossvalind('Kfold', n_controls, K);

switch K<N
    case 1
        for i=1:K
            % 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
            % patients data
            test_idx_p = (indices_p == i);
            sorted_fileName_P=fileName_P(indices_p == i);
            train_idx_p = ~test_idx_p;
            test_data_p =data_inmask_p(test_idx_p,:);
            train_data_p =data_inmask_p(train_idx_p,:);
            % controls data
            test_idx_c = (indices_c == i);
            sorted_fileName_C=fileName_C(indices_c == i);
            train_idx_c = ~test_idx_c;
            test_data_c =data_inmask_c(test_idx_c,:);
            train_data_c =data_inmask_c(train_idx_c,:);
            % all data
            train_data_all=cat(1,train_data_p,train_data_c);
            test_data_all=cat(1,test_data_p,test_data_c);
            sorted_fileName=[sorted_fileName;sorted_fileName_P;sorted_fileName_C];
            % all label
            test_label = [ones(sum(test_idx_p),1);zeros(sum(test_idx_c),1)];
            train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
            label_ForPerformance{i,1}=test_label;
            % normalization
            [train_data_all,test_data_all]=lc_standardization(train_data_all,test_data_all,'normalization');
            % pca
            [COEFF, train_data_all,~,~,~] = pca(train_data_all);
            test_data_all = test_data_all*COEFF;
            %% fit
            model= fitcsvm(train_data_all,train_label,'KernelFunction','linear',...
                'KernelScale','auto');
            %             model= fitclinear(train_data_all,train_label);
            % prediction
            [predict_label, dec_values] = predict(model,test_data_all);
            Decision{i}=dec_values(:,2);
            % Calculate performances
            [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,test_label);
            Accuracy(i) =accuracy;
            Sensitivity(i) =sensitivity;
            Specificity(i) =specificity;
            PPV(i)=ppv;
            NPV(i)=npv;
            [AUC(i)]=AUC_LC(test_label,dec_values(:,2));
            %weight
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
            fprintf('%d/%d\n',i,K)
        end
    case 0 % LOOCV
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            train_data_all =data_inmask(train_index,:);
            train_label = label(train_index,:);
            test_data_all = data_inmask(test_index,:);
            test_label = label(test_index);
            label_ForPerformance{i,1}=test_label;
            [COEFF, train_data_all] = pca(train_data_all);
            test_data_all = test_data_all*COEFF;
            [train_data_all,PS] = mapminmax(train_data_all');
            train_data_all=train_data_all';
            test_data_all = mapminmax('apply',test_data_all',PS);
            test_data_all =test_data_all';
            % fit
            model= fitclinear(train_data_all,train_label);
            % predict
            [predict_label, dec_values] = predict(model,test_data_all);
            Decision{i}=dec_values(:,2);
            Predict(i,1)=predict_label;
            % weight
            w_Brain_Component = model.Beta;
            w_Brain(i,:) = w_Brain_Component' * COEFF';
        end
end

%% ---------------------------------------mean weight----------------------------------------
W_mean=mean(w_Brain);  % mean all iteration
w_M_Brain(mask)=W_mean;
w_M_Brain_3D=reshape(w_M_Brain,dim1,dim2,dim3);
w_M_Brain_3D(~mask_3d)=0;

% Process performances
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
% Display performances
if K<N
    performances=[mean([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC]);...
        std([Accuracy,Sensitivity, Specificity, PPV, NPV,AUC],1)];%显示分类表现,std的分母是‘N’
    performances=performances';
    f = figure;
    title(['Performance with',' ',num2str(K),'-fold']);
    axis off
    t = uitable(f);
    d = performances;
    t.Data = d;
    t.ColumnName = {'mean performance','std'};
    t.RowName={'MAccuracy','MSensitivity','MSpecificity','MPPV','MNPV','MAUC'};
    t.Position = [50 0 400 300];
end

if K==N
    [Accuracy, Sensitivity, Specificity, PPV, NPV]=Calculate_Performances(Predict,cell2mat(label_ForPerformance));
    AUC=AUC_LC(label_ForPerformance,cell2mat(Decision));
    performances=[Accuracy, Sensitivity, Specificity, PPV, NPV,AUC]';%显示分类表现
    f = figure;
    title(['Performance with',' ',num2str(K),'-fold']);
    axis off
    t = uitable(f);
    d = performances;
    t.Data = d;
    t.ColumnName = {'performance'};
    t.RowName={'Accuracy','Sensitivity','Specificity','PPV','NPV','AUC'};
    %             t.ColumnEditable = true;
    t.Position = [50 0 300 300];
end

% save
data=datestr(now,30);
y_Write(w_M_Brain_3D,header,['w_M_Brain_3D_',data,'.nii']);

save([save_dir filesep 'Results_MVPA_',data,'.mat'],...
    'Accuracy', 'Sensitivity', 'Specificity',...
    'PPV', 'NPV', 'Decision', 'AUC', 'w_M_Brain_3D', 'label_ForPerformance','sorted_fileName');
print(gcf,'-dtiff','-r600',[fullfile(save_dir,'Mean Performances'),data]);
end


