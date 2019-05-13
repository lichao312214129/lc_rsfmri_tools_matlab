function  [fvalue_ancova, pvalue_ancova, h_ancova_corrected] = ...
           lc_ancova_for_FCmatrix(...
                                    dir_of_all_origin_mat,... 
                                    path_of_all_cov_files,...
                                    correction_threshold,...
                                    mask,...
                                    is_save)
% 对ROI wise的static/dynamic FC 进行统计分析(ancova+fdr)
% input：
%   ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
%   ID_Mask：感兴趣ROI的id,缺省则对所有的连接进行统计
% output：
%   h:静态或者动态功能连接统计分析的显著情况
%   p：静态或者动态功能连接统计分析的p值

%% All inputs
% input
% save parameters
if nargin < 5
    is_save = 1;
    save_path =  uigetdir(pwd,'select saving folder');;
    % make folder to save results
    if ~exist(save_path,'dir')
        mkdir(save_path);
    end
end

% mask
if nargin < 4
    n_node = str2double(input('Input how many nodes:','s'));
    n_row =n_node;
    n_col = n_node;
    mask = ones(n_row, n_col);
    mask(triu(mask) == 1) = 0;
    mask = mask == 1;
end

% correction
if nargin < 3
    correction_threshold = 0.05;
    correction_method = 'fdr';
end

% covariance directory
if nargin < 2
    n_groups = str2double(input('Input how many groups:','s'));
    path_of_all_cov_files = {};
    for i = 1 : n_groups
        [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd, ...
                                        'MultiSelect', 'off');  % In order to keep order, mutlselect is off
        if ~ file_name
            fprintf('The first covariance not be selected!\n');
            return
        end
        path_of_all_cov_files = cat(1, path_of_all_cov_files, fullfile(path, file_name));
    end
end

% origin matrix
if nargin < 1
    dir_of_all_origin_mat = {};
    for i = 1 : n_groups
        directory = uigetdir(pwd,'select directory of .mat files');
        dir_of_all_origin_mat = cat(1, dir_of_all_origin_mat, directory);
    end

    suffix = '*.mat';
end

%% load fc and cov

% load fc
fprintf('Loading FC...\n');
n_group = length(dir_of_all_origin_mat);
dependent_cell = {};
for i = 1 : n_group
    fc = load_FCmatrix(dir_of_all_origin_mat{i},suffix,n_row,n_col);
    fc = prepare_data(fc,mask);  % prepare data
    dependent_cell = cat (1, dependent_cell, fc);
end
fprintf('Loaded FC\n');

% load covariance
fprintf('Loading covariance...\n');
covariates = {};
for i = 1 : n_group
    cov = load_cov(path_of_all_cov_files{i});
    covariates = cat (1, covariates, cov);
end
fprintf('Loaded covariance\n');

%% ancova
[fvalue_ancova,pvalue_ancova] = ancova(dependent_cell, covariates);

%% Multiple comparison correction
if strcmp(correction_method, 'fdr')
    results = multcomp_fdr_bh(pvalue_ancova, 'alpha', correction_threshold);
elseif strcmp(correction_method, 'fwe')
    results = multcomp_bonferroni(pvalue_ancova, 'alpha', correction_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = results.corrected_h;

%% let h_fdr and p_fdr back to original matrix (2D matrix)
h_ancova_corrected = zeros(n_row, n_col);
h_ancova_corrected(mask) = h_corrected;

F_tmp = zeros(n_row, n_col);
F_tmp(mask) = fvalue_ancova;
fvalue_ancova = F_tmp;

P_tmp = ones(size(mask));
P_tmp(mask) = pvalue_ancova;
pvalue_ancova = P_tmp;

%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['h_ancova_',correction_method,'.mat']),'h_ancova_corrected');
    save (fullfile(save_path,['fvalue_ancova_',correction_method,'.mat']),'fvalue_ancova');
    save (fullfile(save_path,['pvalue_ancova_',correction_method,'.mat']),'pvalue_ancova');
    disp('saved results');
end

fprintf('==================================\n');
fprintf('Completed!\n');
end

function all_subj_fc = load_FCmatrix(path, suffix, n_row, n_col)
% load all matrix in given path
subj = dir(fullfile(path,suffix));
subj = {subj.name}';
subj_path = fullfile(path,subj);

n_subj = length(subj);
all_subj_fc = zeros(n_subj,n_row,n_col);
for i = 1 : n_subj
    all_subj_fc(i,:,:) = importdata(subj_path{i});
end
end

function fc_mat_prepared = prepare_data(fc_mat,mask)
% prepare data

% extract connectvity in ID_Mask. The result is 1D vector for each subject
fc_mat_prepared = fc_mat(:,mask);

% change Inf/NaN to 1/0
fc_mat_prepared(isinf(fc_mat_prepared)) = 1;
fc_mat_prepared(isnan(fc_mat_prepared)) = 0;
end

function cov=load_cov(path)
try
    cov = importdata(path);
catch
    cov = xlsread(path);
end
end

function [F, P] = ancova(dependent_cell, covariates)
% Multiple Predictive Variables

disp('performing ancova for all dependent variables...\n')
n_y = size(dependent_cell{1}, 2);  % how many dependent variables
n_group = length(dependent_cell);  % how many groups

% pre-allocation
fc = (dependent_cell{1});
n_features = size(fc,2);
F = zeros(1,n_features);
P = zeros(1,n_features);

for ith_dependent_var = 1 : n_y
    dependent_var = {};
    for group = 1 : n_group
        dependent_var = cat(2,dependent_var,dependent_cell{group}(:,ith_dependent_var));
    end
    [F(ith_dependent_var),P(ith_dependent_var)] = lc_gretna_ANCOVA1(dependent_var, covariates);
end
end