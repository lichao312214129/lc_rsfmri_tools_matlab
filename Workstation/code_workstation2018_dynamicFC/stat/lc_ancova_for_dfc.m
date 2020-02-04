function  lc_ancova_for_dfc(data_dir, sub_info, parm_of_sub_info, contrast, correction_threshold, is_save)
% Perform ANCOVA + FDR correction for temporal properties of dynamic functional connectivity.
% input:
% 	data_dir: data directory of dynamic functional connectivity.
%
%   parm_of_sub_info: parameters of subject information, including the following fields:
%                                                       parm_of_sub_info.id = 1; which column is subject unique index.
%                                                       parm_of_sub_info.group_label = 2; which column is group label.
%                                                       parm_of_sub_info.covariates = [3,4,6]; which column(s) is(are) covariate(s).
%
% 	sub_info: file containing subject information, including unique index, group label and covariates.
% 	correction_threshold: currently, there is only FDR correction (e.g., correction_threshold = 0.05).
% 	is_save: save flag.
% output:f, h and p values.
% NOTE. Make sure the order of the dependent variables matches the order of the covariances
% Thanks to NBS software.
% -----------------------------------------------------------------------------------------------------
%% Inputs
if nargin < 1
    % your dfc network size
    n_row = 114;
    n_col = 114;

    % save results
    is_save = 1;
    save_name = ['dfc_ANCOVA_results_fdr','.mat'];
    save_path =  uigetdir(pwd,'select saving folder');
    if ~exist(save_path,'dir')
        mkdir(save_path);
    end
    
    % Test type and Contrast
    test_type = 'ftest';
    contrast = [1 1 1 1 0 0 0 ];
    test_info = 'ANCOVA-FDR-thrd0.05';

    % multiple correction
    correction_threshold = 0.05;
    correction_method = 'fdr';
    
    % Covariates
    parm_of_sub_info.id = 1;
    parm_of_sub_info.group_label = 2;
    parm_of_sub_info.covariates = [3,4,5];

    [sub_info_file, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd,'MultiSelect', 'off');
    [~, ~, suffix] = fileparts(sub_info_file);
    if strcmp(suffix, '.txt')
        sub_info = importdata(fullfile(path, sub_info_file));
        sub_info = sub_info.data;
    elseif strcmp(suffix, '.xlsx')
        [sub_info, ~, ~] = xlsread(fullfile(path, sub_info_file));
    else
        disp('Unspport file type');
        return;
    end
    group_label = sub_info(:, parm_of_sub_info.group_label);
    
    % TMP
    uni_groups = unique(group_label);
    n_groups = numel(unique(group_label));
    group_design = zeros(size(group_label,1), n_groups);
    for i =  1:n_groups
        group_design(:,i) = ismember(group_label, uni_groups(i));
    end
    
    % dependent variable, Y
    fprintf('Loading data...\n');
    data_dir = uigetdir(pwd,'select data_dir of .mat files');
    suffix = '*.mat';
    subj = dir(fullfile(data_dir,suffix));
    subj = {subj.name}';
    subj_path = fullfile(data_dir,subj);
    n_subj = length(subj);
    for i = 1:n_subj
        onemat = importdata(subj_path{i});
        if i == 1
            mask = triu(ones(size(onemat,1)),1) == 1;
            all_subj_fc = zeros(n_subj,sum(mask(:)));
        end
        onemat = onemat(mask);
        all_subj_fc(i,:)=onemat;
    end
    fprintf('Loaded data\n');
    
    % match Y and X
    % Y and X must have the unique ID.
    % In this case, uID of Y is subj, uID of X is the first co of sub_info (covariances file is a .xlsx format).
    ms = regexp( subj, '(?<=\w+)[1-9][0-9]*', 'match' );
    nms = length(ms);
    subjid = zeros(nms,1);
    for i = 1:nms
        tmp = ms{i}{1};
        subjid(i) = str2double(tmp);
    end

   [Lia,Locb] = ismember(subjid, sub_info(:,parm_of_sub_info.id));
   Locb_matched = Locb(Lia);
   cov_matched = sub_info(Locb_matched,:);
   group_design_matched = group_design(Locb_matched,:);
   design_matrix = cat(2, group_design_matched, cov_matched(:, parm_of_sub_info.covariates));
   
   % Exclude NaN
   loc_nan = sum(isnan(design_matrix),2) > 0;
   design_matrix(loc_nan, :) = [];
   all_subj_fc(loc_nan, :) = [];
end

%% ancova using GLM from NBS
perms = 0;
GLM.perms = perms;
GLM.X = design_matrix;
GLM.y = all_subj_fc;
GLM.contrast = contrast;
GLM.test = test_type;
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

%% to original space (2d matrix)
Fvalues = zeros(n_row,n_col);
Fvalues(mask) = test_stat;
Fvalues = Fvalues+Fvalues';

Pvalues = zeros(n_row,n_col);
Pvalues(mask) = pvalues;
Pvalues = Pvalues+Pvalues';

H = zeros(n_row,n_col);
H(mask) = h_corrected;
H = H+H';

%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['dfc_ANCOVA_results_',correction_method,'.mat']),'test_info','Fvalues','Pvalues','H');
    disp('saved results');
end
fprintf('--------------------------All Done!--------------------------\n');
end