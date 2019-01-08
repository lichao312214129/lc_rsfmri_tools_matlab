function [ output_args ] = Extra_ROI_Signal( N_group,N_masks )
%input------N=how many groups of images
%%
%读取多组图像
img_name=cell(N_group,1);
img_source=cell(N_group,1);
data_img=cell(N_group,1);
clear x y z;
for i=1:N_group
[img_name1,img_source1,data1 ] = Img2Data_LC;
img_name{i}=img_name1;
img_source{i}=img_source1;
data_img{i}=data1;
end
%%
%读取读个masks
[mask_name1,mask_source1,~ ] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择图像');
data_mask=cell(N_masks,1);
for i=1:n_sub1
   img_strut1=load_nii([mask_source1,char(mask_name1(i))]);
   data_mask{i}=img_strut1.img;
end
%%
end

