function  [h_posthoc_fdr,pvalue_posthoc,tvalue_posthoc]=...
            lc_posthoc_ttest2_for_FCmatrix_zhj( )
% 对ROI wise的static/dynamic FC 进行统计分析(post-hoc ttest2+组间水平的FDR校正)
% input：
%   ZFC_*：ROI wise的静态和动态功能连接矩阵,size=N*N,N为ROI个数
%   Mask：感兴趣功能连接网络二值矩阵（2D,维度与个体网络矩阵维度一致）,缺省则对所有的连接进行统计
%   fdr_threshold： FDR校正的q值
% output：
%   H_FDR:经过FDR校正后的静态或者动态功能连接统计分析的显著情况
%   P：静态或者动态功能连接统计分析的p值
%   T: ...T值

%% all input
% origin matrix
n_groups = str2double(input('Input how many groups:','s'));
path_of_all_origin_mat = {};
for i = 1 : n_groups
    [name, directory] = uigetfile(pwd,'select .mat files');
    path = fullfile(directory, name);
    path_of_all_origin_mat = cat(1, path_of_all_origin_mat, path);
end


% mask: significant inmask of ANCONVA
[file_name, path] = uigetfile({'*.mat'; '*.txt'; '*.*'},'select mask file',pwd, ...
                                        'MultiSelect', 'off');
mask = importdata(fullfile(path, file_name));
mask = mask == 1;
if sum(mask(:)) == 0
    fprintf('All mask data are zero!');
    return
end

% t-test parameters

% correction
correction_threshold = 0.05;
correction_method = 'fdr';

% save
if_save = 1;
save_path = uigetdir(pwd,'select saving folder');

%% load fc and cov
% load fc
fprintf('Loading FC...\n');
n_group = length(path_of_all_origin_mat);
dependent_cell = {};
for i = 1 : n_group
    fc = importdata(path_of_all_origin_mat{i});
    fc = fc.aBc;
    fc = fc(:,mask);
    dependent_cell = cat (1, dependent_cell, fc);
end
fprintf('Loaded FC\n');

%% post-hoc ttest2
disp('performing post-hoc ttest2 for all dependent variables...')
[h_posthoc_without_fdr, pvalue_posthoc,tvalue_posthoc] = lc_ttest2_allpair(dependent_cell);

%% 组间水平的fdr correction,此时的FDR校正的对象应该是所有组的某个特征，而不是某个组的所有特征
[h_posthoc_fdr] = lc_post_hoc_fdr(pvalue_posthoc,correction_threshold,correction_method);

%% let h_fdr and p_fdr back to 2D matrix
% note. 统一都取上三角（不包括对角线）
h_posthoc_fdr = lc_data2orignalspace(h_posthoc_fdr, mask);
pvalue_posthoc = lc_data2orignalspace(pvalue_posthoc, mask);
tvalue_posthoc = lc_data2orignalspace(tvalue_posthoc, mask);

% save
if if_save
    disp('save results...');
    save (fullfile(save_path,['h_posthoc_',correction_method,'.mat']),'h_posthoc_fdr');
    save (fullfile(save_path,['tvalue_posthoc_',correction_method,'.mat']),'tvalue_posthoc');
    save (fullfile(save_path,['pvalue_posthoc_',correction_method,'.mat']),'pvalue_posthoc');
    disp('saved results');
end

fprintf('==================================\n');
fprintf('Completed\n');
end