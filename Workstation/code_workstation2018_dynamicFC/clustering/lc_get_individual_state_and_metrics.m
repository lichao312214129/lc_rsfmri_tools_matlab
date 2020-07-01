function lc_get_individual_state_and_metrics(varargin)
% PURPOSE:  To get subject's centroid and state metrics of each state according group centroid (idx)
% Each subject's dynamic FC data is nNode*nNode*nWindow tensor
% NOTE: Not all subjects have all state, but all subjects have state metrics.
% INPUTS:
%   [--idx_file, -idf]: Cluster indices
%   [--subname, -sn]: Ordered subject names which are used to match idx and dfc.
%   [--cluster_number, -k]: number of clusters
%   [--dir_of_dFC, -dod]: folder containing the dFC (Producing a tensor with dimension nNode*nNode*nWindow*nSubj after loading)
%   [--ordered_subjname, -os]: ordered subject names; the order of idx must match the ordered_subjname
%   [--out_dir, -od]: directory to save the results
% OUTPUTS:
    % Saving all subjects' centroid networks to out_dir
    % subname_of_each_state: subjects' names of each state group used to extract covariates such as age, sex, headmotion etc.
% 
% EXAMPLE:
% Input LC_GET_INDIVIDUAL_STATE_AND_METRICS without any varargin will interactively run. 

%% ---------------------------VARARGIN PARSER-------------------------------
if( sum(or(strcmpi(varargin,'--idx_file'),strcmpi(varargin,'-idf')))==1)
    idx_file = varargin{find(or(strcmpi(varargin,'--idx_file'),strcmp(varargin,'-idf')))+1};
else
    [idx_name, idx_path] = uigetfile({'*.mat';'*.*'},'Select cluster indices');  
    idx_file = fullfile(idx_path,idx_name);
end
idx = importdata(idx_file);

if( sum(or(strcmpi(varargin,'--subname'),strcmpi(varargin,'-sn')))==1)
    subname = varargin{find(or(strcmpi(varargin,'--subname'),strcmp(varargin,'-sn')))+1};
else
    [sn, sub_path] = uigetfile({'*.txt';'*.*'},'Select ordered subjects names');  
    subname = fullfile(sub_path,sn);
    subname = importdata(subname);
end

if( sum(or(strcmpi(varargin,'--cluster_number'),strcmpi(varargin,'-k')))==1)
    cluster_number = varargin{find(or(strcmpi(varargin,'--cluster_number'),strcmp(varargin,'-k')))+1};
else
    cluster_number = input('Enter cluster_number:');
end

if( sum(or(strcmpi(varargin,'--dir_of_dFC'),strcmpi(varargin,'-dod')))==1)
    dir_of_dFC = varargin{find(or(strcmpi(varargin,'--dir_of_dFC'),strcmp(varargin,'-dod')))+1};
else
    dir_of_dFC = uigetdir(pwd, 'Select directory of DFC');
end

if( sum(or(strcmpi(varargin,'--out_dir'),strcmpi(varargin,'-od')))==1)
    out_dir = varargin{find(or(strcmpi(varargin,'--out_dir'),strcmp(varargin,'-od')))+1};
else
    out_dir = uigetdir(pwd, 'Select directory for saving results');
end
%% ---------------------------END VARARGIN PARSER-------------------------------

%%
% Make dir for saving individual states
for i=1:cluster_number
    if ~exist(fullfile(out_dir,['individual_state',num2str(i)]),'dir')
        mkdir(fullfile(out_dir,['individual_state',num2str(i)]));
    end
end

% check input
n_subj = length(subname);
[n_row,~] = size(idx);
if fix(n_row/n_subj) ~= n_row/n_subj
    fprintf('Number of subjects'' name and number of rows are mismatched\n');
    return
else
    num_window = n_row/n_subj;
end

% Get dfc files' path
dfc_file=dir(fullfile([dir_of_dFC,filesep, '*.mat']));
dFCName={dfc_file.name}';
dfc_file=fullfile(dir_of_dFC,dFCName);

% Get each subject's median network
n_subj = length(subname);
ind_start = 1:num_window:n_row;
ind_end = num_window:num_window:n_row;

for ithSubj = 1:n_subj
    fprintf('%d/%d\n',ithSubj,n_subj);
    subjname = subname{ithSubj};
    get_median_network(idx, cluster_number, ithSubj,ind_start,ind_end,dfc_file,subjname, out_dir);
end
fprintf('------------------------All Done!------------------------\n');
end


function state_fc = get_median_network(idx, k, ithSubj, ind_start, ind_end, dfc_file, subjname, out_dir)
idx_current_subj = idx(ind_start(ithSubj):ind_end(ithSubj));
% Metrics
[F, TM, MDT, NT] = lc_icatb_dfnc_statevector_stats(idx_current_subj, k);

% Make dir for saving metrics
metrics_dir = fullfile(out_dir,'metrics');
if ~exist(metrics_dir,'dir')
    mkdir(metrics_dir);
end
out_dir_metrics = fullfile(metrics_dir, subjname);
save(out_dir_metrics, 'F', 'TM', 'MDT', 'NT');

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