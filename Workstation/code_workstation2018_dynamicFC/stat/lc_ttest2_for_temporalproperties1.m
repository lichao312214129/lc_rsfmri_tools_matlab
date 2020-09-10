function  lc_ttest2_for_temporalproperties1(varargin)
% Perform Posthoc ttest2 + FDR correction for functional connectivity.
% INPUTS:
%       [--data_dir, -dd]: data directory of dynamic functional connectivity.
%       [--demographics_file,-dmf]: File of demographics of participants, demographics includes unique index, group label and covariates.
%       [--suffix_fc, -sfc]: suffix of functional connectivity, default is '.mat'.
%       [--column_id, -cid]: which column is subject unique index, default is 1.
%       [--column_group_label, -cgl]:which column is group label, default is 2.
%       [--columns_covariates,-ccov]:which columns are covariates.
%       [--correction_method, -cm]: Multiple correction method (FDR, FWE, None; default is FDR).
%       [--correction_threshold, -ct]: Multiple correction threshold (e.g., correction_threshold = 0.05), default is 0.05.
%       [--is_save, -is]: If save results, default is 1.
%       [--output_directory, -od]: directiory for saving results, default is current directory.
%       [--output_name, -on]: prefix of output name, default is ''.
% 
% OUTPUTS:T-values, h and p-values.
% 
% EXAMPLE:
% lc_ttest2_for_temporalproperties1('-dd', 'F:\The_first_training\results\ROISignals_data\dfc\cluster_results\metrics', ...
% '-dmf', 'F:\The_first_training\cov\covariates.xlsx', ...
% '-cid', 1, '-cgl', 2,'-ccov',[3,4],...
% '-od', 'F:\The_first_training\statatistic_results_for_states', ...
% '-on', 'state1');
% 
% NOTE. Make sure the order of the dependent variables matches the order of the covariances
% Thanks to NBS software.

%% ---------------------------VARARGIN PARSER-------------------------------
if nargin == 0
    help lc_ttest2_for_temporalproperties1
    return;
end

if( sum(or(strcmpi(varargin,'--data_dir'),strcmpi(varargin,'-dd')))==1)
    data_dir = varargin{find(or(strcmpi(varargin,'--data_dir'),strcmp(varargin,'-dd')))+1};
else
    data_dir = uigetdir(pwd,'select DFC files');
end

if( sum(or(strcmpi(varargin,'--suffix_fc'),strcmpi(varargin,'-sfc')))==1)
    suffix_fc = varargin{find(or(strcmpi(varargin,'--suffix_fc'),strcmp(varargin,'-sfc')))+1};
else
    suffix_fc = '*.mat';
end

if( sum(or(strcmpi(varargin,'--demographics_file'),strcmpi(varargin,'-dmf')))==1)
    demographics_file = varargin{find(or(strcmpi(varargin,'--demographics_file'),strcmp(varargin,'-dmf')))+1};
else
    [demographics_file, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of demographics files', pwd,'MultiSelect', 'off');
    demographics_file = fullfile(path, demographics_file);
end

% if( sum(or(strcmpi(varargin,'--contrast'),strcmpi(varargin,'-ctr')))==1)
%     contrast = varargin{find(or(strcmpi(varargin,'--contrast'),strcmp(varargin,'-ctr')))+1};
% else
%     contrast = input('Enter contrast:');
% end

if(sum(or(strcmpi(varargin,'--colnum_id'),strcmpi(varargin,'-cid')))==1)
    colnum_id = varargin{find(or(strcmpi(varargin,'--colnum_id'),strcmp(varargin,'-cid')))+1};
else
    colnum_id = 1;
end

if( sum(or(strcmpi(varargin,'--column_group_label'),strcmpi(varargin,'-cgl')))==1)
    column_group_label = varargin{find(or(strcmpi(varargin,'--column_group_label'),strcmp(varargin,'-cgl')))+1};
else
    column_group_label = 2;
end

if( sum(or(strcmpi(varargin,'--columns_covariates'),strcmpi(varargin,'-ccov')))==1)
    columns_covariates = varargin{find(or(strcmpi(varargin,'--columns_covariates'),strcmp(varargin,'-ccov')))+1};
else
    columns_covariates = input('Enter columns_covariates:');
end

if( sum(or(strcmpi(varargin,'--correction_method'),strcmpi(varargin,'-cm')))==1)
    correction_method = varargin{find(or(strcmpi(varargin,'--correction_method'),strcmp(varargin,'-cm')))+1};
else
    correction_method = 'FDR';
end

if( sum(or(strcmpi(varargin,'--correction_threshold'),strcmpi(varargin,'-ct')))==1)
    correction_threshold = varargin{find(or(strcmpi(varargin,'--correction_threshold'),strcmp(varargin,'-ct')))+1};
else
    correction_threshold = 0.05;
end

if( sum(or(strcmpi(varargin,'--is_save'),strcmpi(varargin,'-is')))==1)
    is_save = varargin{find(or(strcmpi(varargin,'--is_save'),strcmp(varargin,'-is')))+1};
else
    is_save = 1;
end

if( sum(or(strcmpi(varargin,'--output_directory'),strcmpi(varargin,'-od')))==1)
    output_directory = varargin{find(or(strcmpi(varargin,'--output_directory'),strcmp(varargin,'-od')))+1};
else
    output_directory = uigetdir(pwd, 'Select directory for saving results');
end

if( sum(or(strcmpi(varargin,'--output_name'),strcmpi(varargin,'-on')))==1)
    output_name = varargin{find(or(strcmpi(varargin,'--output_name'),strcmp(varargin,'-on')))+1};
else
    output_name = input('Input prefix of output name:', 's');
end

test_info = ['Ttest2-', correction_method, '-threshold_', num2str(correction_threshold)];
%% ---------------------------END VARARGIN PARSER-------------------------------

%% Prepare
% Covariates
[~, ~, suffix] = fileparts(demographics_file);
if strcmp(suffix,  '.txt')
    cov = importdata(demographics_file);
    error('Only supportted covariance type is excel');
    cov.data;
    cov.textdata;
elseif suffix == '.xlsx'
    [~, header, demographics] = xlsread(demographics_file);
end
demographics = demographics(2:end,:);

% design matrix
group_label = demographics(:,column_group_label);
group_label = cell2mat(group_label);
uni_group_label = unique(group_label);
group_design = zeros(size(demographics,1),numel(uni_group_label));
for i =  1:numel(uni_group_label)
    group_design(:,i) = ismember(group_label, uni_group_label(i));
end
design_matrix = cat(2, group_design, cell2mat(demographics(:,columns_covariates)));

% dependent variable, Y
fprintf('Loading temporal properties...\n');
subj = dir(fullfile(data_dir,suffix_fc));
subj = {subj.name}';
subj_path = fullfile(data_dir,subj);
n_subj = length(subj);
subjname = cell(n_subj,1);
for i = 1:n_subj
    data = importdata(subj_path{i});
    if i == 1
        [~, n_states] = size(data.MDT);
        mean_dwelltime = zeros(n_subj, n_states);
        fractional_window = zeros(n_subj, n_states);
        num_transitions = zeros(n_subj, 1);
    end
    mean_dwelltime(i, :) = data.MDT;
    fractional_window(i, :) = data.F;
    num_transitions(i) = data.NT;  
    [~,subjname{i}, ~] = fileparts(subj{i});
end
fprintf('Loaded temporal properties\n');

% match Y and X
% Y and X must have the unique ID.
% In this case, uID of Y is subj, uID of X is the first co of demographics (covariances file is a .xlsx format).
subjname_in_cov = demographics(:,colnum_id);
for  i = 1:n_subj
    subjname_in_cov{i}(isspace(subjname_in_cov{i})) = [] ;
end
[Lia,Locb] = ismember(subjname, subjname_in_cov);
Locb_matched = Locb(Lia);
cov_matched = demographics(Locb_matched,:);
group_design_matched = group_design(Locb_matched,:);
design_matrix = cat(2, group_design_matched, cell2mat(cov_matched(:, columns_covariates)));

% Ttest2
perms = 0;
GLM.perms = perms;
GLM.X = group_design_matched;
GLM.y = [mean_dwelltime, fractional_window, num_transitions];
GLM.test = 'ttest';
n_f = size(GLM.y,2);

test_stat = zeros(n_groups*(n_groups-1)/2,n_f);
pvalues = ones(n_groups*(n_groups-1)/2,n_f);
cohen_d = ones(n_groups*(n_groups-1)/2, n_f);
count = 1;
savename = cell((n_groups*(n_groups-1)/2),1);
for i =1:(n_groups-1)
    for j = (i+1):n_groups
        uni_groups(i);
        savename{count} = [num2str(j), 'vs', num2str(i)];  % 1:HC;2:MDD;3:SZ;4:BD.
        contrast = zeros(1,n_groups);
        contrast(i) = -1;
        contrast(j) = 1;
        GLM.contrast = contrast;
        [test_stat(count,:),pvalues(count,:)]=lc_NBSglm(GLM);
        cohen_d(count,:) = lc_calc_cohen_d_effective_size(GLM.y(GLM.X(:,contrast==1)==1,:),GLM.y(GLM.X(:,contrast==-1)==1,:));
        count = count +1;
    end
end

% Get group mean
group_mean = zeros(size(H_matrix_of_anova,1), size(H_matrix_of_anova,2), n_groups);
for i = 1:n_groups
    gm = group_mean(:,:,i);
    gm = mean(all_subj_fc_all(group_design_matched(:,i)==1, :));
    gm = reshape(gm,size(H_matrix_of_anova));
    group_mean(:,:,i) = gm; 
end
save(fullfile(output_directory,[output_name, '_group_mean.mat']), 'group_mean')

% correction
h_corrected = post_hoc_fdr(pvalues,correction_threshold,correction_method);

% Save
for i = 1:(n_groups*(n_groups-1)/2)
    % to original space (2d matrix)
    Tvalues = zeros(size(H_matrix_of_anova));
    Tvalues(H_matrix_of_anova) = test_stat(i,:);
    Tvalues = Tvalues+Tvalues';
    
    Pvalues_posthoc = zeros(size(H_matrix_of_anova));
    Pvalues_posthoc(H_matrix_of_anova) = pvalues(i,:);
    Pvalues_posthoc = Pvalues_posthoc+Pvalues_posthoc';
    
    H_posthoc = zeros(size(H_matrix_of_anova));
    H_posthoc(H_matrix_of_anova) = h_corrected(i,:);
    H_posthoc = H_posthoc+H_posthoc';
    
    cohen_d_posthoc = zeros(size(H_matrix_of_anova));
    cohen_d_posthoc(H_matrix_of_anova) = cohen_d(i,:);
    cohen_d_posthoc = cohen_d_posthoc + cohen_d_posthoc';
    
    % save
    if is_save
        disp('save results...');
        timenow = strrep(num2str(fix(clock)),' ','');
        save (fullfile(output_directory,[output_name, '_', savename{i}, '_',correction_method, num2str(correction_threshold), '.mat']),'test_info','Tvalues','Pvalues_posthoc','H_posthoc', 'cohen_d_posthoc');
        disp('saved results');
    end
end
fprintf('--------------------------All Done!--------------------------\n');
end

function [h_fdr] = post_hoc_fdr(pvalues,correction_threshold, correction_method)
[n_g,n_f]=size(pvalues);
h_fdr=zeros(n_g,n_f);
for i=1:n_f
    if strcmp(correction_method,'FDR')
        results=multcomp_fdr_bh(pvalues(:,i),'alpha', correction_threshold);
    elseif strcmp(correction_method,'FWE')
        results=multcomp_bonferroni(pvalues(:,i),'alpha', correction_threshold);
    else
        fprintf('Please indicate the correct correction method!\n');
    end
    h_fdr(:,i)=results.corrected_h;
end
end