function subname_of_each_state = lc_get_individual_statemetrics_gift(idx,k,dir_of_dFC,all_subjname,out_dir)
% PURPOSE:  get subject's centroid and state metrics of each state according group centroid (idx)
% Each subject's dynamic FC data is nNode*nNode*nWindow tensor
% NOTE: Not all subjects have all state, but all subjects have state metrics.
% input:
    % k: number of clusters
    % dir_of_dFC: folder containing the dFC (Producing a tensor with dimension nNode*nNode*nWindow*nSubj after loading)
    % ordered_subjname: ordered subject names; the order of idx must match the ordered_subjname
    % out_dir: directory to save the results
% output:
    % Saving all subjects' centroid networks to out_dir
    % subname_of_each_state: subjects' names of each state group used to extract covariates such as age, sex, headmotion etc.
%% input
if nargin < 1
    idx_path = fullfile(pwd,'idx.mat');
    k = 2;
    dir_of_dFC = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\dfc_whole';
    subname = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\ordered_subjname_2019912151910.txt';
    out_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\results_of_individual';
    idx = importdata(idx_path);
    all_subjname = importdata(subname);
end

%%
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
n_subj = length(all_subjname);
[n_row,~] = size(idx);
if fix(n_row/n_subj) ~= n_row/n_subj
    fprintf('Number of subjects'' name and number of rows are mismatched\n');
    return
else
    num_window = n_row/n_subj;
end

% Get dfc files' path
dfc_file=dir(fullfile([dir_of_dFC,'\*.mat']));
dFCName={dfc_file.name}';
dfc_file=fullfile(dir_of_dFC,dFCName);

% Get each subject's median network
n_subj = length(all_subjname);
ind_start = 1:num_window:n_row;
ind_end = num_window:num_window:n_row;

for ithSubj=1:n_subj
    fprintf('%d/%d\n',ithSubj,n_subj);
    subjname = all_subjname{ithSubj};
    get_median_network(idx, k, ithSubj,ind_start,ind_end,dfc_file,subjname,out_dir);
end
fprintf('------------------------All Done!------------------------\n');
end


function state_fc=get_median_network(idx, k, ithSubj,ind_start,ind_end,dfc_file,subjname,out_dir)
idx_current_subj=idx(ind_start(ithSubj):ind_end(ithSubj));

% Metrics
[F, TM, MDT, NT] = lc_icatb_dfnc_statevector_stats(idx_current_subj, k);
metrics_dir = fullfile(out_dir,'metrics',subjname);
save(metrics_dir, 'F', 'TM', 'MDT', 'NT');

% Centroid
unique_idx=unique(idx_current_subj);
dFC=importdata(dfc_file{ithSubj});
for i=1:length(unique_idx)
    ith_state=unique_idx(i);
    state_fc=median(dFC(:,:,idx_current_subj==ith_state),3);
    outpath=fullfile(out_dir,['individual_state',num2str(ith_state)],subjname);
    save(outpath,'state_fc');
end
end