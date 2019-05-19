function  ZScoreTranslation
%对多个图像进行Z变换
%%
%读取图像
[file_name1,path_source1,~] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择图像');
img_strut_temp1=load_nii([path_source1,char(file_name1(1))]);
data_temp=img_strut_temp1.img;
[x ,y ,z]=size(data_temp);n_sub1=length(file_name1);
data_patients=zeros(x, y, z, n_sub1);
img_strut1=cell(n_sub1,1);
for i=1:n_sub1
   img_strut1{i}=load_nii([path_source1,char(file_name1(i))]);
   data_patients(:,:,:,i)=img_strut1{i}.img;
end
%%
cd (path_source1);
group_mean=mean(data_patients,4);
group_std=std(data_patients,0,4);
for i=1:n_sub1
    Z=(data_patients(:,:,:,i)-group_mean)./group_std;
    img_strut1{i}.img=Z;
    save_nii(img_strut1{i},['Z',file_name1{i}]);
end
end