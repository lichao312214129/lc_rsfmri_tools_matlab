function [ df1 ] = my_ttest1(cov1,cov2)
%配对样本t检验
%   output: 
%   T_map:配对样本t检验得到了T统计量图；P_map
%   df：自由度
%%
%读取第一组图像
[file_name1,path_source1,~] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择第一组图像');
img_strut_temp1=load_nii([path_source1,char(file_name1(1))]);
data_temp=img_strut_temp1.img;
[x ,y ,z]=size(data_temp);n_sub1=length(file_name1);
data_patients=zeros(x, y, z, n_sub1);
for i=1:n_sub1
   img_strut1=load_nii([path_source1,char(file_name1(i))]);
   data_patients(:,:,:,i)=img_strut1.img;
end
%%
%读取第二组图像
[file_name2,path_source2,~] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择第二组图像');
n_sub2=length(file_name2);
data_controls=zeros(x, y, z, n_sub2);
for i=1:n_sub2
   img_strut2=load_nii([path_source2,char(file_name2(i))]);
   data_controls(:,:,:,i)=img_strut2.img;
end
%判断两组例数是否相同
if n_sub1~=n_sub2
    error('此为配对样本t检验，两组被试的样本数不相等，请检查')
    return
end
%% 去除协变量
if nargin==2
% regress out nuisance covariate-for patients
reg1=[ones(size(data_patients,4),1) cov1];
b=zeros(x,y,z,size(reg1,2));
for Z=1:z
    for Y=1:y
        for X=1:x
            data_temp=data_patients(X,Y,Z,:);
            b(X,Y,Z,:)=regress(data_temp(:),reg1); 
        end
    end
end
b2=b(:,:,:,2);b3=b(:,:,:,3);
f2= @(x) x*b2;
f3= @(x) x*b3;
betaX2=arrayfun(f2,cov1(:,1),'UniformOutput', false);
betaX3=arrayfun(f3,cov1(:,2),'UniformOutput', false);
data_temp=data_patients;
for i=1:size(data_patients,4)
    data_patients(:,:,:,i)=data_temp(i)-betaX2{i}-betaX3{i};
end
% regress out nuisance covariate-for controls
reg2=[ones(size(data_controls,4),1) cov2];
 b=zeros(x,y,z,size(reg2,2));
 for Z=1:z
    for Y=1:y
        for X=1:x
            data_temp=data_controls(X,Y,Z,:);
            b(X,Y,Z,:)=regress(data_temp(:),reg2); 
        end
    end
 end
b2=b(:,:,:,2);b3=b(:,:,:,3);
f2= @(x) x*b2;
f3= @(x) x*b3;
betaX2=arrayfun(f2,cov2(:,1),'UniformOutput', false);
betaX3=arrayfun(f3,cov2(:,2),'UniformOutput', false);
data_temp=data_controls;
 for i=1:size(data_controls,4)
    data_controls(:,:,:,i)=data_temp(i)-betaX2{i}-betaX3{i};
 end
end
%ttest1
[~,p,~,stats] =ttest(data_patients,data_controls,'Tail','both','Dim',4);
T= stats.tstat;%t statistic
img_strut_temp1_temp1=img_strut_temp1;
img_strut_temp1_temp1.img=T;
save_nii(img_strut_temp1_temp1,'T1_map.nii');%保存T图
img_strut_temp1_temp2=img_strut_temp1;
img_strut_temp1_temp2.img=p;
save_nii(img_strut_temp1_temp2,'P1_map.nii');%保存P图
df1=n_sub1-1;
end