function  [fvalue_ancova,pvalue_ancova,h_ancova_fdr] = lc_ancova_for_matrix_used_for_my_study(mask,fdr_threshold)
% 对ROI wise的static/dynamic FC 进行统计分析(ancova+fdr)
% input：
%   ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
%   ID_Mask：感兴趣ROI的id,缺省则对所有的连接进行统计
% output：
%   h:静态或者动态功能连接统计分析的显著情况
%   p：静态或者动态功能连接统计分析的p值

%% All inputs
% input
if nargin < 1
    path = 'D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic';
    state = 4;

    path_sz = fullfile(path,['state',num2str(state),'\state',num2str(state),'_SZ']);
    path_bd = fullfile(path,['state',num2str(state),'\state',num2str(state),'_BD']);
    path_mdd = fullfile(path,['state',num2str(state),'\state',num2str(state),'_MDD']);
    path_hc = fullfile(path,['state',num2str(state),'\state',num2str(state),'_HC']);
    
    suffix = '*.mat';
    n_row = 114;%矩阵有几行
    n_col = 114;%矩阵有几列
    
    % cov
    path_sz_cov = fullfile(path,['state',num2str(state),'\cov','\state',num2str(state),'_cov_SZ.xlsx']);
    path_bd_cov = fullfile(path,['state',num2str(state),'\cov','\state',num2str(state),'_cov_BD.xlsx']);
    path_mdd_cov = fullfile(path,['state',num2str(state),'\cov','\state',num2str(state),'_cov_MDD.xlsx']);
    path_hc_cov = fullfile(path,['state',num2str(state),'\cov','\state',num2str(state),'_cov_HC.xlsx']);
    
    % mask
    n_node = 114;
    mask = ones(n_node,n_node);
    mask(triu(mask) == 1) = 0;
    mask = mask == 1;
    
    % correction
    fdr_threshold=0.05;
    correction_method='fdr';
    
    % save
    is_save=1;
    save_path=fullfile(path,['state',num2str(state),'\result1']);
end

% create folder to save results
if ~exist(save_path,'dir')
    mkdir(save_path);
end

%% load fc and cov
% load fc
fprintf('Loading FC...\n');
fc_sz = load_FCmatrix(path_sz,suffix,n_row,n_col);
fc_bd = load_FCmatrix(path_bd,suffix,n_row,n_col);
fc_mdd = load_FCmatrix(path_mdd,suffix,n_row,n_col);
fc_hc = load_FCmatrix(path_hc,suffix,n_row,n_col);
fprintf('Loaded FC\n');

% load covariance
fprintf('Loading covariance...\n');
cov_sz=load_cov(path_sz_cov);
cov_bd=load_cov(path_bd_cov);
cov_mdd=load_cov(path_mdd_cov);
cov_hc=load_cov(path_hc_cov);
Covariates={cov_sz,cov_bd,cov_mdd,cov_hc};
fprintf('Loaded covariance\n');

%% prepare data
% extract connectvity in ID_Mask. The result is 1D vector for each subject
fc_sz = fc_sz(:,mask);
fc_bd = fc_bd(:,mask);
fc_mdd = fc_mdd(:,mask);
fc_hc = fc_hc(:,mask);

% Inf/NaN to 1 and 0
fc_sz(isinf(fc_sz)) = 1;
fc_bd(isinf(fc_bd)) = 1;
fc_mdd(isinf(fc_mdd)) = 1;
fc_hc(isinf(fc_hc)) = 1;

fc_sz(isnan(fc_sz)) = 0;
fc_bd(isnan(fc_bd)) = 0;
fc_mdd(isnan(fc_mdd)) = 0;
fc_hc(isnan(fc_hc)) = 0;

%% ancova
DependentFiles = {fc_sz,fc_bd,fc_mdd,fc_hc};
[fvalue_ancova,pvalue_ancova] = ancova(DependentFiles, Covariates);

%% Multiple comparison correction
if strcmp(correction_method, 'fdr')
    results = multcomp_fdr_bh(pvalue_ancova, 'alpha', fdr_threshold);
elseif strcmp(correction_method, 'fwe')
    results = multcomp_bonferroni(pvalue_ancova, 'alpha', fdr_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = results.corrected_h;

%% let h_fdr and p_fdr back to original matrix (2D matrix)
h_ancova_fdr = zeros(n_node, n_node);
h_ancova_fdr(mask) = h_corrected;

F_tmp = zeros(n_node, n_node);
F_tmp(mask) = fvalue_ancova;
fvalue_ancova = F_tmp;

P_tmp=ones(size(mask));
P_tmp(mask)=pvalue_ancova;
pvalue_ancova=P_tmp;

%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['h_ancova_',correction_method,'.mat']),'h_ancova_fdr');
    save (fullfile(save_path,['fvalue_ancova_',correction_method,'.mat']),'fvalue_ancova');
    save (fullfile(save_path,['pvalue_ancova_',correction_method,'.mat']),'pvalue_ancova');
    disp('saved results');
end

fprintf('==================================\n');
fprintf('Completed\n');
end

function all_subj_fc = load_FCmatrix(path, suffix, n_row, n_col)
% 加载path中所有被试的FC
subj = dir(fullfile(path,suffix));
subj = {subj.name}';
subj_path = fullfile(path,subj);

n_subj = length(subj);
all_subj_fc = zeros(n_subj,n_row,n_col);
for i = 1 : n_subj
    all_subj_fc(i,:,:) = importdata(subj_path{i});
end
end

function cov=load_cov(path)
try
    cov = importdata(path);
catch
    cov = xlsread(path);
end
end

function [F, P] = ancova(DependentFiles, Covariates)
% Multiple Predictive Variables

disp('performing ancova for all dependent variables...\n')
n_y = size(DependentFiles{1}, 2);  % how many dependent variables
n_group = length(DependentFiles);  % how many groups

% pre-allocation
fc = (DependentFiles{1});
n_features = size(fc,2);
F = zeros(1,n_features);
P = zeros(1,n_features);

for dependent_var = 1 : n_y
    dependentFiles = {};
    for group = 1 : n_group
        dependentFiles = cat(2,dependentFiles,DependentFiles{group}(:,dependent_var));
    end
    [F(dependent_var),P(dependent_var)] = lc_gretna_ANCOVA1(dependentFiles, Covariates);
end
end