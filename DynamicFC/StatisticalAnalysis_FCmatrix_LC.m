%尽量用gretna的统计

%% ===========load all MAT files==========================
%第一组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第一组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_p=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_p(:,:,i)=importdata([path_source,char(file_name(i))]);
    else
        mat_p(:,:,i)=importdata([path_source,char(file_name)]);
    end
end
%第二组
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','第二组变量');
if iscell(file_name)
    n_sub=length(file_name);
    mat_template=importdata([path_source,char(file_name(1))]);
else
    n_sub=1;
    mat_template=importdata([path_source,char(file_name)]);
end
mat_c=zeros(size(mat_template,1), size(mat_template,2),n_sub);
for i=1:n_sub
    if iscell(file_name)
        mat_c(:,:,i)=importdata([path_source,char(file_name(i))]);
    else
        mat_c(:,:,i)=importdata([path_source,char(file_name)]);
    end
end
fprintf('==================================\n');
fprintf('Load MAT files\n');

%%
mat_p(isnan(mat_p))=0;
mat_c(isnan(mat_c))=0;
num_fc=size(mat_p,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=squeeze(mat_p(i,j,:));stat_c=squeeze(mat_c(i,j,:));
        [h(i,j),p(i,j)]=ttest2(stat_p,stat_c);
    end
end