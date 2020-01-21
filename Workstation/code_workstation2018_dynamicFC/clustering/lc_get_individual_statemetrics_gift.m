function subname_of_each_state = lc_get_individual_state_and_metrics(idx, dir_of_dfc, dfc_suffix, allsubjname, out_dir)
% PURPOSE:  To get subject's centroid and state metrics according group index (idx)
% NOTE: Not all subjects have all state, but all subjects have state metrics.
% Inputs:
    % idx: index of all subjects (derived from kmeans).
    % dir_of_dfc: folder containing the dfc (a tensor with dimension of nNode*nNode*nWindow).
    % dfc_suffix:  suffix of the dfc files, e.g. 'mat'.
    % allsubjname: all subject names in the order of dfc files. This file is used to give name to individual state file and metrics.
    % out_dir: directory to save the results
% Outputs:
    % Saving all subjects' centroid networks to out_dir
    % subname_of_each_state: subjects' names of each state group used to extract covariates such as age, sex, headmotion etc.
%% ----------------------------------input---------------------------------
% idx_path = fullfile('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster','idx.mat');
% idx = importdata(idx_path);
% dir_of_dfc = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\dfc_whole';
% dfc_suffix = 'mat'.
% subjname_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\ordered_subjname_2019912151910.txt';
% allsubjname = importdata(subjname_path);
% out_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\results_of_individual';
%% ----------------------------------input end---------------------------------

% make results' directory
metrics_dir = fullfile(out_dir,'metrics');
if ~exist(metrics_dir,'dir')
    mkdir(metrics_dir);
end

for i=1:k
    if ~exist(fullfile(out_dir,['individual_state',num2str(i)]),'dir')
        mkdir(fullfile(out_dir,['individual_state',num2str(i)]));
    end
end

% check input
n_subj = length(allsubjname);
[n_row,~] = size(idx);
if fix(n_row/n_subj) ~= n_row/n_subj
    fprintf('Number of subjects'' name and number of rows are mismatched\n');
    return
else
    num_window = n_row/n_subj;
end

% Get dfc files' path
dfc_file=dir(fullfile([dir_of_dfc,'\*.', dfc_suffix]));
dfcName={dfc_file.name}';
dfc_file=fullfile(dir_of_dfc,dfcName);

% Get each subject's median network
n_subj = length(allsubjname);
ind_start = 1:num_window:n_row;
ind_end = num_window:num_window:n_row;

for ithSubj=1:n_subj
    fprintf('%d/%d\n',ithSubj,n_subj);
    subjname = allsubjname{ithSubj};
    get_median_network(idx, k, ithSubj, ind_start, ind_end, dfc_file, subjname, out_dir);
end
fprintf('------------------------All Done!------------------------\n');
end


function state_fc = get_median_network(idx, k, ithSubj, ind_start, ind_end, dfc_file, subjname, out_dir)
idx_current_subj=idx(ind_start(ithSubj):ind_end(ithSubj));

% Metrics
[F, TM, MDT, NT] = lc_icatb_dfnc_statevector_stats(idx_current_subj, k);
metrics_dir = fullfile(out_dir,'temporal_properties',subjname);
save(metrics_dir, 'F', 'TM', 'MDT', 'NT');

% Centroid
unique_idx=unique(idx_current_subj);
dfc=importdata(dfc_file{ithSubj});
for i=1:length(unique_idx)
    ith_state=unique_idx(i);
    state_fc=median(dfc(:,:,idx_current_subj==ith_state),3);
    outpath=fullfile(out_dir,['individual_state',num2str(ith_state)],subjname);
    save(outpath,'state_fc');
end
end