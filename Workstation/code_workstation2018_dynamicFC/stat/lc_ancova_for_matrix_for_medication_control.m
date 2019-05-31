function  [fvalue_ancova,pvalue_ancova,h_ancova_fdr]=lc_ancova_for_matrix_for_medication_control(mask,fdr_threshold)
% % 此代码应用了GRETNA和DPABI，请引用
% 对ROI wise的static/dynamic FC 进行统计分析(ancova+fdr),被代码适用于本研究中对用药协变量的控制
%%input：
%   ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
%   ID_Mask：感兴趣ROI的id,缺省则对所有的连接进行统计
% output：
%   h:静态或者动态功能连接统计分析的显著情况
%   p：静态或者动态功能连接统计分析的p值

%% All inputs
if nargin <1
    % data
    path_med='F:\黎超\dynamicFC\Data\Dynamic\state4\med_control\all_med';
    path_no_med='F:\黎超\dynamicFC\Data\Dynamic\state4\med_control\all_no_med';
    
    % cov
    path_cov_med='F:\黎超\dynamicFC\Data\Dynamic\state4\med_control\cov_med.xlsx';
    path_cov_no_med='F:\黎超\dynamicFC\Data\Dynamic\state4\med_control\cov_no_med.xlsx';

    % data format and size
    suffix='*.mat';
    n_row=114;%矩阵有几行
    n_col=114;%矩阵有几列
    
    % mask
    mask=ones(114,114);
    mask(triu(mask)==1)=0;
    mask=mask==1;
    
    % correction method
    fdr_threshold=0.05;
    correction_method='fdr';

    % save 
    if_save=0;
    save_path='F:\黎超\dynamicFC\Data\Dynamic\state4\med_control';
end

% create folder to save results
if ~exist(save_path,'dir')
    mkdir(save_path);
end

%% load fc and cov
% load fc
fprintf('Loading FC...\n');
fc_med=load_FCmatrix(path_med,suffix,n_row,n_col);
fc_no_med=load_FCmatrix(path_no_med,suffix,n_row,n_col);
fprintf('Loaded FC\n');

% 加载协变量
fprintf('Loading covariance...\n');
cov_med=load_cov(path_cov_med);
cov_no_med=load_cov(path_cov_no_med);
Covariates={cov_med,cov_no_med};
fprintf('Loaded covariance\n');

%% 准备数据
% 提取ID_Mask内的连接,提取之后，被试矩阵将会是1D的形式
fc_med=fc_med(:,mask);
fc_no_med=fc_no_med(:,mask);

% Inf/NaN to 1 and 0
fc_med(isinf(fc_med))=1;
fc_no_med(isinf(fc_no_med))=1;

fc_med(isnan(fc_med))=0;
fc_no_med(isnan(fc_no_med))=0;
%% ancova
DependentFiles={fc_med,fc_no_med};
[fvalue_ancova,pvalue_ancova]=ancova(DependentFiles, Covariates);

%% multi-correction
if strcmp(correction_method,'fdr')
    results=multcomp_fdr_bh(pvalue_ancova,'alpha', fdr_threshold);
else
    results=multcomp_bonferroni(pvalue_ancova,'alpha', fdr_threshold);
end
h_corrected=results.corrected_h;

%% let h_fdr and p_fdr back to original matrix
h_ancova_fdr=zeros(size(mask));
h_ancova_fdr(mask)=h_corrected;

F1=zeros(size(mask));
F1(mask)=fvalue_ancova;
fvalue_ancova=F1;

P1=ones(size(mask));
P1(mask)=pvalue_ancova;
pvalue_ancova=P1;

%% save 
if if_save
    disp('save results...');
    save (fullfile(save_path,['h_ancova_',correction_method,'.mat']),'h_ancova_fdr');
    save (fullfile(save_path,['fvalue_ancova_',correction_method,'.mat']),'fvalue_ancova');
    save (fullfile(save_path,['pvalue_ancova_',correction_method,'.mat']),'pvalue_ancova');
    disp('saved results');
end

fprintf('==================================\n');
fprintf('Completed\n');
end

%% =================================================================
function all_subj_fc=load_FCmatrix(path,suffix,n_row,n_col)
% 加载path中所有被试的FC
subj=dir(fullfile(path,suffix));
subj={subj.name}';
subj_path=fullfile(path,subj);

n_subj=length(subj);
all_subj_fc=zeros(n_subj,n_row,n_col);
for i =1:n_subj
    all_subj_fc(i,:,:)=importdata(subj_path{i});
end
end

function cov=load_cov(path)
try
    cov=importdata(path);
catch
    cov=xlsread(path);
end
end

function [F,P]=ancova(DependentFiles, Covariates)
% 多个预测变量
disp('performing ancova for all dependent variables...')
n_x=size(DependentFiles{1},2);
n_g=length(DependentFiles);

% 预分配
fc=(DependentFiles{1});
n_features=size(fc,2);
F=zeros(1,n_features);
P=zeros(1,n_features);

for i=1:n_x
    dependentFiles={};
    for j=1:n_g
        dependentFiles=cat(2,dependentFiles,DependentFiles{j}(:,i));
    end
    [F(i),P(i)] = lc_ANCOVA1(dependentFiles, Covariates);
end
end