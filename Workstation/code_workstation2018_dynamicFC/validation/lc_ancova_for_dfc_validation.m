function  lc_ancova_for_dfc_validation(data_dir, cov_files, correction_threshold, is_save)
% This function is used to validate the transdiagnostic dysconnectivity by adding other factors as covariances.
% Perform ANCOVA + FDR correction for dynamic functional connectivity.
% input:
% 	data_dir: data directory of dynamic functional connectivity.
% 	cov_files: covariances' file names
% 	correction_threshold: currently, there is only FDR correction (e.g., correction_threshold = 0.05).
% 	is_save: save flag.
% output:f, h and p values.
% NOTE. Make sure the order of the dependent variables matches the order of the covariances
% Thanks to NBS software.
%% Inputs
if nargin < 1
    % your dfc network size
    n_row = 114;
    n_col = 114;

    % save results
    is_save = 1;
    save_path =  uigetdir(pwd,'select saving folder');
    if ~exist(save_path,'dir')
        mkdir(save_path);
    end
    
    % multiple correction
    correction_threshold = 0.05;
    correction_method = 'fdr';
    
    % covariances
    [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd,'MultiSelect', 'off');
    [~, ~, suffix] = fileparts(file_name);
    if strcmp(suffix, '.txt')
        cov = importdata(fullfile(path, file_name));
    elseif strcmp(suffix, '.xlsx')
        cov = xlsread(fullfile(path, file_name));
    else
        disp('Unspport file type');
        return;
    end
    group_label = cov(:,2);
    group_design = zeros(size(cov,1),4);
    for i =  1:4
        group_design(:,i) = ismember(group_label, i);
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
        fprintf('%d/%d\n',i,n_subj);
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
    % In this case, uID of Y is subj, uID of X is the first co of cov (covariances file is a .xlsx format).
    ms = regexp( subj, '(?<=\w+)[1-9][0-9]*', 'match' );
    nms = length(ms);
    subjid = zeros(nms,1);
    for i = 1:nms
        tmp = ms{i}{1};
        subjid(i) = str2double(tmp);
    end
   [Lia,Locb] = ismember(subjid, cov(:,1));
   loc_matched_cov = Locb(Lia);
   cov_matched = cov(loc_matched_cov,:);
   all_subj_fc_matched = all_subj_fc(Lia,:);
   group_design_matched = group_design(loc_matched_cov,:);
   design_matrix = cat(2, group_design_matched, cov_matched(:,3:end));
end

%% ancova using GLM from NBS
perms = 0;
test_type = 'ftest';
GLM.perms = perms;
contrast = [1 1 1 1 0 0 0 ];
GLM.X = design_matrix;
GLM.y = all_subj_fc_matched;
y_name = 'triu_features';
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
    save (fullfile(save_path,['dfc_STATS_results_',correction_method,'.mat']),'y_name','Fvalues','Pvalues','H');
    disp('saved results');
end
fprintf('--------------------------All Done!--------------------------\n');
end