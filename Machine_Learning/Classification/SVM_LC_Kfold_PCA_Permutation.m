function Performances_Permutation =SVM_LC_Kfold_PCA_Permutation(K,N_permutation, mask)
%此代码用来做置换检验 for pca
%input：K=K-fold cross validation,K<N，N_permutation= times of permutation
%output：all classification performances
mask_file='G:\Softer_DataProcessing\spm12\spm12\tpm\Reslice3_TPM_greaterThan0.2.nii';
[mask_3d,header] = y_Read(mask_file);
mask_3d = mask_3d ~= 0;
mask = reshape(mask_3d,[],1);
%% generate data and correspond label
[~,path_source,data_patients ] = lc_Img2Data;
[~,~,data_controls ] = lc_Img2Data;
data=cat(4,data_patients,data_controls);
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
label=[ones(n_patients,1);zeros(n_controls,1)];
% data in mask
N = n_patients+n_controls;
data = reshape(data,[dim1*dim2*dim3,N]);  % Column is a sample, each row is a feature.
% implicitmask = sum(data~=0,2)>=size(data,2)-10;  % inner mask
% data_inmask=data(implicitmask,:);%  data in inner mask
data_inmask=data(mask,:);
data_inmask=data_inmask';
%预分配空间
% w_Brain=zeros(K,sum(implicitmask));
% w_M_Brain=zeros(1,dim1*dim2*dim3);
%
Performances_ALL=zeros(N_permutation,6);
for i=1:N_permutation
    disp(['The outer was ' num2str(i),'/',num2str(N_permutation), ' iteration!']);
    label_forPermutation=label(randperm(numel(label)));
    Performances_ALL(i,:) =SVM_LC_Kfold_PCA_ForPermutationTest(data_inmask, label_forPermutation, N, K);
    %      waitbar(i/N_permutation,h,sprintf('%2.0f%%', i/N_permutation*100)) ;
    clc
end
Performances_ALL(isnan(Performances_ALL))=0;
%save results
%目录
loc= find(path_source=='\');
outdir=path_source(1:loc(length(find(path_source=='\'))-2)-1);%path的上2层目录
cd (outdir)
Performances_Permutation.decription='order= Accuracy,Sensitivity, Specificity, PPV, NPV,AUC';
Performances_Permutation.data=Performances_ALL;
save([outdir filesep 'Performances_Permutation.mat'],...
    'Performances_Permutation');
%     close (h)
% display histogram
Title={'Accuracy','Sensitivity', 'Specificity', 'PPV', 'NPV','AUC'};
nbins = 20;
for i=1:6
    subplot(2,3,i);histogram(Performances_Permutation.data(:,i),nbins);
    title(Title{i});
end
% 
disp(['The ',num2str(N_permutation),' times ','Permutation was done ']);
end

