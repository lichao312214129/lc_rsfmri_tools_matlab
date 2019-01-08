function lc_Data2Img(data_to_transfer,img_name)
%此函数将多个.img或者.nii文件读为.mat文件。如果文件小于或的等于1个，会出错（可将'MultiSelect'设为'off'）。
[file_name,path_source1,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','请选择模板图像');
img_strut_temp=load_nii([path_source1,char(file_name)]);
img_strut_temp.img=data_to_transfer;
save_nii(img_strut_temp,img_name)
end


