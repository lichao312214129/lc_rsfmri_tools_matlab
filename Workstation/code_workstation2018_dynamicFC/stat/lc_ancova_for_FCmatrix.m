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
    save_path =  uigetdir(pwd,'select saving folder');
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
    is_cov = input('Are you sure you don''t load the covariates\nY/N:','s');
    n_groups = str2double(input('Input how many groups:','s'));
    path_of_all_cov_files = {};
    for i = 1 : n_groups
        if strcmp(is_cov,'Y')
            [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd, ...
                'MultiSelect', 'off');  % In order to keep order, mutlselect is off
            if ~ file_name
                fprintf('The first covariance not be selected!\n');
                return
            end
            path_of_all_cov_files = cat(1, path_of_all_cov_files, fullfile(path, file_name));
        else
            path_of_all_cov_files = cell(n_groups,1);
        end
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
    fc = lc_load_FCmatrix(dir_of_all_origin_mat{i},suffix,n_row,n_col);
    fc = prepare_data(fc,mask);  % prepare data
    dependent_cell = cat (1, dependent_cell, fc);
end
fprintf('Loaded FC\n');

% load covariance
if strcmp(is_cov,'Y')
    fprintf('Loading covariance...\n');
    covariates = {};
    for i = 1 : n_group
        cov = lc_load_cov(path_of_all_cov_files{i});
        covariates = cat (1, covariates, cov);
    end
    fprintf('Loaded covariance\n');
else
    covariates = {};
end
%% ancova
[fvalue_ancova,pvalue_ancova] = lc_ancova(dependent_cell, covariates);

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