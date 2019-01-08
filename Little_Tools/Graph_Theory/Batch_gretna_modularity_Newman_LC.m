function [ output_args ] = Batch_gretna_modularity_Newman_LC
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
[file_name,path_source,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','on','每个被试的网络（相关矩阵）');

if iscell(file_name)
    n_sub=length(file_name);
else
    n_sub=1;
end
%
for i=1:n_sub
    if iscell(file_name)
        struct_matrix_temp=load([path_source,char(file_name(i))]);
        name=char(file_name(i));
        name=name(1:end-4);
        cmd=['M=struct_matrix_temp.',name,';'];
        eval(cmd)
        [CommunityIndex(:,i) Q(i)] = gretna_modularity_Newman(M);
    else
        struct_matrix_temp=load([path_source,char(file_name)]);
        name=char(file_name);
        name=name(1:end-4);
        cmd=['M=struct_matrix_temp.',name,';'];
        eval(cmd)
        [CommunityIndex Q] = gretna_modularity_Newman(M);
    end
end


%%  write modularity_Newman to excel and save results
% results path
time_lc=datestr(now,30);
path_outdir_tmp = uigetdir({},'结果存放目录');
mkdir([path_outdir_tmp filesep 'modularity_Newman_',time_lc]);
path_outdir=[path_outdir_tmp filesep 'modularity_Newman_',time_lc];
cd (path_outdir)
% title
filename_ex = ['CommunityIndex.xlsx'];
% data_ex = {'subject name'};
% sheet = 1;
% xlRange = 'A1';
% xlswrite(filename_ex,data_ex,sheet,xlRange)
% name
if iscell(file_name)
    data_ex=char(file_name');
    data_ex=data_ex(:,1:end-4);
    data_ex=cellstr(data_ex);
else
    data_ex=file_name;
    data_ex=data_ex(1:end-4);
    data_ex=cellstr(data_ex);
end
sheet = 1;
xlRange = 'A1';
xlswrite(filename_ex,data_ex',sheet,xlRange)
% data
data_ex = [CommunityIndex];
sheet = 1;
xlRange = 'A2';
xlswrite(filename_ex,data_ex,sheet,xlRange)

%%  write Q_Newman to excel and save results
% results path
% title
filename_ex = ['Q.xlsx'];
% data_ex = {'subject name'};
% sheet = 1;
% xlRange = 'A1';
% xlswrite(filename_ex,data_ex,sheet,xlRange)
% name
if iscell(file_name)
    data_ex=char(file_name');
    data_ex=data_ex(:,1:end-4);
    data_ex=cellstr(data_ex);
else
    data_ex=file_name;
    data_ex=data_ex(1:end-4);
    data_ex=cellstr(data_ex);
end
sheet = 1;
xlRange = 'A1';
xlswrite(filename_ex,data_ex',sheet,xlRange)
% data
data_ex = [Q];
sheet = 1;
xlRange = 'A2';
xlswrite(filename_ex,data_ex,sheet,xlRange)
end