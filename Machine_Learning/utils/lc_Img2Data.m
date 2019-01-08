function [file_name,path_source,data ] = lc_Img2Data(ifMultiple,Reminder)
% 此函数将多个.img或者.nii文件读为.mat文件。如果文件小于或的等于1个，会出错（可将'MultiSelect'设为'off'）。
% input:
%      N=多少组图像
%      ifMultiple='on' OR 'off',是否为多个文件
% output: 
%      data为4D.mat文件，前面三个维度是图像维度，第四个维度是样本数。
%% 读取病人图像
if nargin<2
    Reminder='请选择需要转换成数据的图像';
end
if nargin<1
    ifMultiple='on';
end
%
[file_name,path_source,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect',ifMultiple,Reminder);
img_strut_temp1=load_nii([path_source,char(file_name(1))]);
data_temp=img_strut_temp1.img;
[x ,y ,z]=size(data_temp);n_sub1=length(file_name);
data=zeros(x, y, z, n_sub1);
for i=1:n_sub1
   img_strut1=load_nii([path_source,char(file_name(i))]);
   data(:,:,:,i)=img_strut1.img;
end
file_name=file_name';
end

