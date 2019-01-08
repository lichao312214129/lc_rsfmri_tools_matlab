function [ Mean_ROISignals,PCA_ROISinals, PCA_explaination, Order] = Extract_ROI_Signal( N_group,N_masks )
%input------N_group=how many groups of images; N_masks=how many masks for
%extract signals
%output-----Mean_ROISignals=mask内的平均信号,PCA_ROISinals=mask内信号的的第一主成分,
%PCA_explaination=第一主成分的解释度（x%）;Order=mask的顺序
%% 预分配空间
img_name=cell(N_group,1);
img_source=cell(N_group,1);
data_img=cell(N_group,1);
PCA_explaination=zeros(N_group,N_masks);
n_sub=zeros(N_group,1);
ROISignals=cell(N_group,N_masks);
Mean_ROISignals=cell(N_group,1);
PCA_ROISinals=cell(N_group,1);
%% 读取多组图像
for i=1:N_group
[img_name1,img_source1,data1 ] = Img2Data_LC;
img_name{i}=img_name1;
img_source{i}=img_source1;
data_img{i}=data1;
n_sub(i)=size(data1,4);
end
%% 读取读个masks
[mask_name1,mask_source1,~ ] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择mask');
data_mask=cell(N_masks,1);
 Order=cell(N_masks,1);
for j=1:N_masks
   img_strut1=load_nii([mask_source1,char(mask_name1(j))]);
   Order{j}=[num2str(j),'_',char(mask_name1(j))];
   data_mask{j}=img_strut1.img;
end
%%  提取mask内的信号
clear i j;
for i=1:N_group
    data_temp_for_extract=data_img{i};
    Mean_ROISignals_group=zeros(n_sub(i),N_masks);
    pca_ROISinals_group=zeros(n_sub(i),N_masks);
    for j=1:N_masks
       ROISignals{i,j}=bsxfun(@times,data_temp_for_extract,data_mask{j}~=0);
       mask_logical=data_mask{j}~=0;
       VoxNum_inmask=sum(mask_logical(:)); 
        ROISignals_limited_in_mask=zeros(n_sub(i), VoxNum_inmask);
           for k=1: n_sub(i)
               ROISignals_sub= ROISignals{i,j}(:,:,:,k);
               ROISignals_limited_in_mask(k,:)=ROISignals_sub(ROISignals_sub~=0);
               Mean_ROISignals_group(k,j)=sum(ROISignals_limited_in_mask(k,:))/VoxNum_inmask;                             
           end
           %% 计算主成分解释度
           [~,score,dataset_latent,~] = pca(ROISignals_limited_in_mask);
          percent_explained = 100*dataset_latent/sum(dataset_latent);
          PCA_explaination(i,j)=percent_explained(1);
          pca_ROISinals_group(:,j)=score(:,1);
    end 
    Mean_ROISignals{i}=Mean_ROISignals_group;
    PCA_ROISinals{i}=pca_ROISinals_group;
end
end

