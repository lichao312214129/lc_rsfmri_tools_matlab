function  [fvalue_ancova, pvalue_ancova, h_ancova_corrected] = ...
    lc_ancova_for_temporal_properties(dir_of_temporal_properties, path_of_cov_files, correction_threshold, is_save)
% Perform ANCOVA + FDR correction for temporal properties of dynamic functional connectivity (mean dwell time, fractional windows and number of transitions).
% input:
% 	dir_of_temporal_properties: directory of temporal properties.
% 	path_of_cov_files: directory of of covariances
% 	correction_threshold: currently, there is only FDR correction (e.g., correction_threshold = 0.05).
% 	is_save: save flag.
% output:f, h and p values.
% NOTE. Make sure the order of the dependent variables matches the order of the covariances
%% Inputs
if nargin < 1
    n_state = 3;
    colnum_id = 1;
    columns_covariates = [3,4,6];
    % make folder to save results
    is_save = 1;
%     save_path =  uigetdir(pwd,'select saving folder');
    save_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610';
    if ~exist(save_path,'dir')
        mkdir(save_path);
    end
    
    % correction
    correction_threshold = 0.05;
    correction_method = 'fdr';
    
    % covariance
%     [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd,'MultiSelect', 'off');
%     cov = xlsread(fullfile(path, file_name));
    cov = xlsread('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_737.xlsx');
    group_label = cov(:,2);
    group_design = zeros(size(cov,1),4);
    for i =  1:4
        group_design(:,i) = ismember(group_label, i);
    end
    design_matrix = cat(2, group_design, cov(:,columns_covariates));
    
    % dependent variable, Y
%     directory = uigetdir(pwd,'select directory containing DFC metrics');
    suffix = '*.mat';
% 
%     % load fc
%     fprintf('Loading temporal properties...\n');
%     dependent_var = dir(fullfile(directory, suffix));
    directory = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\metrics';
    dependent_var = dir(fullfile(directory, suffix));
    subj = {dependent_var.name}';
    dependent_var = fullfile(directory, {dependent_var.name})';
    n_sub = length(dependent_var);
    mean_dwelltime = zeros(n_sub, n_state);
    fractional_window = zeros(n_sub, n_state);
    num_transitions = zeros(n_sub, 1);
    for i = 1: n_sub
        data = importdata(dependent_var{i});
        mean_dwelltime(i, :) = data.MDT;
        fractional_window(i, :) = data.F;
        num_transitions(i) = data.NT;
    end
    fprintf('Loaded temporal properties\n');

% match Y and X
% Y and X must have the unique ID.
% In this case, uID of Y is subj, uID of X is the first co of demographics (covariances file is a .xlsx format).
ms = regexp( subj, '(?<=\w+)[1-9][0-9]*', 'match' );
nms = length(ms);
subjid = zeros(nms,1);
for i = 1:nms
    tmp = ms{i}{1};
    subjid(i) = str2double(tmp);
end

[Lia,Locb] = ismember(subjid, cov(:,colnum_id));
Locb_matched = Locb(Lia);
cov_matched = cov(Locb_matched,:);
group_design_matched = group_design(Locb_matched,:);
design_matrix = cat(2, group_design_matched, cov_matched(:, columns_covariates));

% Exclude NaN
loc_nan = sum(isnan(design_matrix),2) > 0;
design_matrix(loc_nan, :) = [];
mean_dwelltime(loc_nan, :) = [];
fractional_window(loc_nan, :) = [];
num_transitions(loc_nan,:) = [];
end

%% ancova
GLM.perms = 0;
GLM.X = design_matrix;
GLM.y = [mean_dwelltime, fractional_window,num_transitions];
y_name = 'mean_dwelltime, fractional_window, num_transitions';
GLM.contrast = [1 1 1 1 0 0 0 ];
GLM.test = 'ftest';
[test_stat,pvalues]=NBSglm(GLM);

%% Multiple comparison correction
if strcmp(correction_method, 'fdr')
    results = multcomp_fdr_bh(pvalues, 'alpha', correction_threshold);
elseif strcmp(correction_method, 'fwe')
    results = multcomp_bonferroni(pvalues, 'alpha', correction_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = results.corrected_h;

%% Ttest2 for significance
loc_hc = group_design_matched(:,1)==1;
loc_sz = group_design_matched(:,3)==1;
loc_bd = group_design_matched(:,4)==1;
loc_mdd = group_design_matched(:,2)==1;

md_hc_s1 = fractional_window(loc_hc,1);
md_sz_s1 = fractional_window(loc_sz,1);
md_bd_s1 = fractional_window(loc_bd,1);
md_mdd_s1 = fractional_window(loc_mdd,1);

md_hc_s2 = fractional_window(loc_hc,2);
md_sz_s2 = fractional_window(loc_sz,2);
md_bd_s2 = fractional_window(loc_bd,2);
md_mdd_s2 = fractional_window(loc_mdd,2);

[h,p1] = ttest2(md_hc_s1, md_sz_s1);
[h,p2] = ttest2(md_hc_s1, md_bd_s1);
[h,p3] = ttest2(md_hc_s1, md_mdd_s1);
[h,p4] = ttest2(md_sz_s1, md_bd_s1);
[h,p5] = ttest2(md_sz_s1, md_mdd_s1);
[h,p6] = ttest2(md_bd_s1, md_mdd_s1);
results_posthoc = multcomp_fdr_bh([p1,p2,p3,p4,p5,p6], 'alpha', correction_threshold);

%% corr
fractional_window_hc = fractional_window(loc_hc,:);
cov_matched_hc = cov_matched(loc_hc,:);

fractional_window_sz = fractional_window(loc_sz,:);
cov_matched_sz = cov_matched(loc_sz,:);

fractional_window_bd = fractional_window(loc_bd,:);
cov_matched_bd = cov_matched(loc_bd,:);

fractional_window_mdd = fractional_window(loc_mdd,:);
cov_matched_mdd = cov_matched(loc_mdd,:);

for i = 1:3
    for j = 7:15
        [r(i,j), p(i,j)] = corr(fractional_window_mdd(:,i), cov_matched_mdd(:,j), 'rows' ,'complete');
%         fprintf('r=%.4f\t', r)
%         fprintf('p=%.4f\n',p)
    end
end
%% 
save(fullfile(save_path, 'temporal_propertities.mat'),'mean_dwelltime', 'fractional_window', 'num_transitions', 'group_design_matched')


%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['dfc_metrics_',correction_method,'.mat']),'y_name','test_stat','h_corrected','pvalues');
    disp('saved results');
end
fprintf('--------------------------All Done!--------------------------\n');
end