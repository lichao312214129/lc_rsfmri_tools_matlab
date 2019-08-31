function lc_get_individual_state(idx,k,dir_of_dFC,subj_name,out_dir)
% Fetch each subject's median network for each state according idex from kmeans cluster methods
% Each subject's dynamic FC data is nNode*nNode*nWindow tensor
% NOTE: not all subjects have all state
% input
    % idx: index from kmeans cluster method
    % k
    % dir_of_dFC: folder containing the dFC（nNode*nNode*nWindow*nSubj）
    % ordered_subjname: ordered subject names
    % out_dir: save folder
% output
    % each network of each state for each subject
    
%% input
if nargin < 1
    idx_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\IDX.mat';
    k = 4;
    dir_of_dFC = 'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\DynamicFC_length17_step1_screened';
    subj_name = 'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\covariances\subjName.mat';
    out_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\test';
    
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

% 判断输入IDX\subj_name是否正确，并自动计算窗口数目
n_subj = length(subj_name);
[n_row,~] = size(idx);
if fix(n_row/n_subj) ~= n_row/n_subj
    fprintf('输入的窗口数目*被试数目不等于idx！\n');
    return
else
    num_window = n_row/n_subj;
end

% 加载被试的动态功能连接矩阵
dFCFile=dir(fullfile([dir_of_dFC,'\*.mat']));
dFCName={dFCFile.name}';
dFCFile=fullfile(dir_of_dFC,dFCName);

% get each subject's median network
n_subj = length(subj_name);
ind_start = 1:num_window:n_row;
ind_end = num_window:num_window:n_row;

for ithSubj=1:n_subj
    fprintf('%d/%d\n',ithSubj,n_subj);
    calc_median_or_mean(idx,ithSubj,ind_start,ind_end,dFCFile,subj_name{ithSubj},out_dir);
end
fprintf('============All Done!============\n');
end

function state_fc=calc_median_or_mean(IDX,ithSubj,ind_start,ind_end,dFCFile,subjname,out_path)

idx_current_subj=IDX(ind_start(ithSubj):ind_end(ithSubj));
unique_idx=unique(idx_current_subj);
% 当前被试的所有状态
dFC=importdata(dFCFile{ithSubj});%  载入当前被试
for i=1:length(unique_idx)
    % 求匹配当前状态的窗口的中位数
    ith_state=unique_idx(i);
    state_fc=median(dFC(:,:,idx_current_subj==ith_state),3);
%     state_fc=mean(dFC(:,:,idx_current_subj==ith_state),3);
    % 将当前结果保存到当前被试的当前状态文件夹下面
    outpath=fullfile(out_path,['state',num2str(ith_state)],subjname);
    my_save(outpath,state_fc)
end
end

function my_save(outpath,state_fc)
save(outpath,'state_fc');
end