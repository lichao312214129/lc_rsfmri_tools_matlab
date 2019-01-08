function [ df2 ] = my_ttest2_1(cov1,cov2)
%本代码用于两独立样本t检验（去除协变量）
%input: cov must be a n by 2 matrix
%   output: T_map=两独立样本t检验得到了T统计量图; P_map; df=自由度
%%
%读取病人图像
[file_name1,path_source1,~] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择病人组图像');
img_strut_temp1=load_nii([path_source1,char(file_name1(1))]);
data_temp=img_strut_temp1.img;
[x ,y ,z]=size(data_temp);n_sub1=length(file_name1);
data_patients=zeros(x, y, z, n_sub1);
for i=1:n_sub1
   img_strut1=load_nii([path_source1,char(file_name1(i))]);
   data_patients(:,:,:,i)=img_strut1.img;
end
%%
%读取对照组图像
[file_name2,path_source2,~] = uigetfile({'*.img';'*.nii'},'MultiSelect','on','请选择对照组图像');
n_sub2=length(file_name2);
data_controls=zeros(x, y, z, n_sub2);
for i=1:n_sub2
   img_strut2=load_nii([path_source2,char(file_name2(i))]);
   data_controls(:,:,:,i)=img_strut2.img;
end
%% 去协变量
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
%%
b2=b(:,:,:,2);b3=b(:,:,:,3);
f2= @(x) x*b2;
f3= @(x) x*b3;
betaX2=arrayfun(f2,cov1(:,1),'UniformOutput', false);
betaX3=arrayfun(f3,cov1(:,2),'UniformOutput', false);
data_temp=data_patients;
for i=1:size(data_patients,4)
    cmd=['data_temp(',num2str(i),')-betaX2{',num2str(i),'}-betaX3{',num2str(i),'}'];
    data_patients(:,:,:,i)=eval(cmd);
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
%% 两独立样本t检验
[~,p,~,stats] =ttest2(data_patients,data_controls,'Tail','both','Dim',4);
T= stats.tstat;%t statistic
%%
%save images
img_strut_temp1_temp1=img_strut_temp1;
img_strut_temp1_temp1.img=T;
save_nii(img_strut_temp1_temp1,'T2_map.nii');%保存T图
img_strut_temp1_temp2=img_strut_temp1;
img_strut_temp1_temp2.img=p;
save_nii(img_strut_temp1_temp2,'P2_map.nii');%保存P图
df2=n_sub1+n_sub2-2;
end