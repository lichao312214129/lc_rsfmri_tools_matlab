function subname_of_each_state = lc_get_individual_state_DynamicBC(idx, k, dir_of_dFC, out_dir)
% PURPOSE: get subject's centroid of each state according Pearson's correlation coefficient with group centroid
% If a FC matrix in a window have the largest Pearson's correlation coefficient with group centroid A, 
% then I assign the FC matrix to the state A.
% NOTE: All subjects have all state.
% input:
    % k: number of clusters
    % dir_of_dFC: folder containing the dFC (Producing a tensor with dimension nNode*nNode*nWindow*nSubj after loading)
    % ordered_subjname: ordered subject names; the order of idx must match the ordered_subjname
    % out_dir: directory to save the results
% output:
    % Saving all subjects' centroid networks to out_dir
    % subname_of_each_state: subjects' names of each state group 
    
%% input
if nargin < 1
    idx_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\Cluster_Test\resutls\idx.mat';
    k = 2;
    dir_of_dFC = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\Cluster_Test\dfc';
    subj_name = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\Cluster_Test\resutls\ordered_subjname_201991231116.txt';
    out_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\Cluster_Test';
    
    idx = importdata(idx_path);
    subj_name = importdata(subj_name);
end

%%
% make results' directory
for i=1:k
    if ~exist(fullfile(out_dir,['state',num2str(i)]),'dir')
        mkdir(fullfile(out_dir,['state',num2str(i)]));
    end
end

% check input
n_subj = length(subj_name);
[n_row,~] = size(idx);
if fix(n_row/n_subj) ~= n_row/n_subj
    fprintf('Number of subjects'' name and number of rows are mismatched\n');
    return
else
    num_window = n_row/n_subj;
end

% Get dfc files' path
dFCFile=dir(fullfile([dir_of_dFC,'\*.mat']));
dFCName={dFCFile.name}';
dFCFile=fullfile(dir_of_dFC,dFCName);

% Get each subject's median network
n_subj = length(subj_name);
ind_start = 1:num_window:n_row;
ind_end = num_window:num_window:n_row;

for ithSubj=1:n_subj
    fprintf('%d/%d\n',ithSubj,n_subj);
    get_median_network(idx,ithSubj,ind_start,ind_end,dFCFile,subj_name{ithSubj},out_dir);
end
fprintf('------------------------All Done!------------------------\n');
end

function state_fc=get_median_network(idx,ithSubj,ind_start,ind_end,dFCFile,subjname,out_path)

idx_current_subj=idx(ind_start(ithSubj):ind_end(ithSubj));
unique_idx=unique(idx_current_subj);
% 
dFC=importdata(dFCFile{ithSubj});
for i=1:length(unique_idx)
    ith_state=unique_idx(i);
    state_fc=median(dFC(:,:,idx_current_subj==ith_state),3);
    outpath=fullfile(out_path,['state',num2str(ith_state)],subjname);
    save(outpath,'state_fc');
end
end