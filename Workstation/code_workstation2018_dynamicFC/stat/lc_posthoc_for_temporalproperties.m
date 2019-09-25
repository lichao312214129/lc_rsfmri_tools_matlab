function  lc_posthoc_for_temporalproperties()
% Perform posthoc ttest2s + FDR correction for temporal properties of dynamic functional connectivity (mean dwell time, fractional windows and number of transitions).
% input:
% 	dir_of_temporal_properties: directory of temporal properties.
% 	path_of_cov_files: directory of of covariances
% 	correction_threshold: currently, there is only FDR correction (e.g., correction_threshold = 0.05).
% 	is_save: save flag.
% output:f, h and p values.
% NOTE. Make sure the order of the dependent variables matches the order of the covariances
%% Inputs
if nargin < 1
    n_state = 2;
    % make folder to save results
    is_save = 0;
    save_path =  uigetdir(pwd,'select saving folder');
    if ~exist(save_path,'dir')
        mkdir(save_path);
    end
    
    % correction
    correction_threshold = 0.05;
    correction_method = 'fdr';
    
    % covariance
    [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd,'MultiSelect', 'off');
    cov = xlsread(fullfile(path, file_name));
    group_label = cov(:,2);
    group_design = zeros(size(cov,1),4);
    for i =  1:4
        group_design(:,i) = ismember(group_label, i);
    end
    design_matrix = cat(2, group_design, cov(:,[3,4,5,6]));
    
    % dependent variable, Y
    directory = uigetdir(pwd,'select directory of .mat files');
    suffix = '*.mat';
    % load fc
    fprintf('Loading temporal properties...\n');
    dependent_var = dir(fullfile(directory, suffix));
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
end

%% ancova
GLM.perms =0;
GLM.X = design_matrix(:,[1 2 3 4]);
GLM.y = [mean_dwelltime, fractional_window, num_transitions];
y_name = 'mean_dwelltime, fractional_window';
GLM.test =  'ttest';

test_stat = zeros(3,5);
pvalues = ones(3,5);
for i =1:3
    contrast = cat(2,-1,zeros(1,3));
    contrast(i+1)=1;
    GLM.contrast = contrast;
    [test_stat(i,:),pvalues(i,:)]=NBSglm(GLM);
end

pall=[p_sz(1:end-1),p_mdd(1:end-1),p_bd(1:end-1),p_szbd(1:end-1),p_szmdd(1:end-1),p_bdmdd(1:end-1)];
%% Multiple comparison correction
if strcmp(correction_method, 'fdr')
    results = multcomp_fdr_bh(pvalues, 'alpha', correction_threshold);
elseif strcmp(correction_method, 'fwe')
    results = multcomp_bonferroni(pvalues, 'alpha', correction_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = results.corrected_h;

%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['STATS_results_',correction_method,'.mat']),'y_name','test_stat','h_corrected','pvalues');
    disp('saved results');
end
fprintf('--------------------------All Done!--------------------------\n');
end

[h,p,ci,s]=ttest2(GLM.y(GLM.X(:,3)==1,:),GLM.y(GLM.X(:,1)==1,:))