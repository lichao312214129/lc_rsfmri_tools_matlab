function  lc_correlation_analysis_for_validation_when_add_ses(data_dir, cov_files, correction_threshold, is_save)
% This function is used to validate the transdiagnostic dysconnectivity by performing correction analysis between dysconnectivity and 'SES'.
% input:
% 	data_dir: data directory of functional connectivity.
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
    
    % Mask
    mask_file = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\shared_1and2and3_fdr.mat';
    mask = importdata(mask_file);
    
    % covariances
    [file_name, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'select path of cov files',pwd,'MultiSelect', 'off');
    [~, ~, suffix] = fileparts(file_name);
    if strcmp(suffix, '.txt')
        cov = importdata(fullfile(path, file_name));
    elseif strcmp(suffix, '.xlsx')
        [cov, ~, ~] = xlsread(fullfile(path, file_name));
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
            mask_triu = triu(ones(size(onemat,1)),1) == 1;
            mask_comb = logical (mask_triu .* mask);
            all_subj_fc = zeros(n_subj,sum(mask_comb(:)));
        end
        onemat = onemat(mask_comb);
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
   cov_to_corr = cov_matched(:,6:end);
end

%% Perform correlation analysis
[r, pvalues] = corr(all_subj_fc_matched, cov_to_corr, 'type', 'Spearman');

%% Multiple comparison correction
if strcmp(correction_method, 'fdr')
    results = multcomp_fdr_bh(pvalues(:), 'alpha', correction_threshold);
    h = results.corrected_h;
    h = reshape(h,size(r,1),size(r,2));
    
elseif strcmp(correction_method, 'fwe')
    results = multcomp_bonferroni(pvalues, 'alpha', correction_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = h;

%% to original space (2d matrix)
rvalues1 = zeros(n_row,n_col);
rvalues1(mask_comb) = r(:,1);
rvalues1 = rvalues1+rvalues1';

rvalues2 = zeros(n_row,n_col);
rvalues2(mask_comb) = r(:,2);
rvalues2 = rvalues2+rvalues2';

rvalues3 = zeros(n_row,n_col);
rvalues3(mask_comb) = r(:,3);
rvalues3 = rvalues3+rvalues3';

H1 = zeros(n_row,n_col);
H1(mask_comb) = h_corrected(:,1);
H1 = H1+H1';

H2 = zeros(n_row,n_col);
H2(mask_comb) = h_corrected(:,2);
H2 = H2+H2';

H3 = zeros(n_row,n_col);
H3(mask_comb) = h_corrected(:,3);
H3 = H3+H3';

%% save
if is_save
    disp('save results...');
    save (fullfile(save_path,['validation_results_of_correlation_between_dysconnectivity_and_SES',correction_method,'.mat']),...
        'H1','H2','H3','rvalues1','rvalues2','rvalues3');
    disp('saved results');
end

%% This script is used for visualization the correlations between shared dysconnectivity and SES.
if_add_mask=1;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

ax = tight_subplot(2,3,[0.05 0.05],[0.05 0.05],[0.01 0.01]);

% co1
axes(ax(1))
net_path = rvalues1;
mask_path = logical(H1);
lc_netplot(net_path,if_add_mask, mask_path, how_disp, if_binary, which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;

% cov2
axes(ax(2))
net_path = rvalues2;
mask_path = logical(H2);
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;

% cov3
axes(ax(3))
net_path = rvalues3;
mask_path = logical(H3);
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;


% Plot post-shared
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\shared_1and2and3_fdr;
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\dfc_posthoc_szvshc_results_original_fdr.mat;
% post-shared cov1
axes(ax(4))
net_path = Tvalues;
mask_path = shared_1and2and3 & H1==0;
lc_netplot(net_path,if_add_mask, mask_path, how_disp, 1, which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;

% cov2
axes(ax(5))
net_path = Tvalues;
mask_path = shared_1and2and3 & H2==0;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;

% cov3
axes(ax(6))
net_path = Tvalues;
mask_path = shared_1and2and3 & H3==0;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mycmp)
caxis([-0.16 0.15]);
axis square
colorbar;
fprintf('--------------------------All Done!--------------------------\n');
% ax = gca;
% mycmp = colormap(ax); 
% save('mycmp','mycmp');
end