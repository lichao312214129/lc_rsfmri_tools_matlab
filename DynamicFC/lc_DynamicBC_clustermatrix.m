function lc_DynamicBC_clustermatrix(k,subj_dir, out_dir, clustering_method)
% 对动态功能连接矩阵进行聚类
% 请务必引用DynamicBC
% 此代码以及被我修改：
% 1：只是用上三角矩阵（不包括对角线）
% 2：只使用组水平的聚类结果，从而导致某些被试缺乏某些状态，但是很多研究是如此

%%
% input
k=5;
subj_folder = 'D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\DynamicFC_length17_step1_screened';
out_dir = 'D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state_test';
clustering_method = 'cityblock';
%% load all subject's matrix
subj_dir = dir(fullfile(subj_folder,'*.mat'));

% *save subjects's_name, so that we can align subject's order with index_of_state.
subj_name = {subj_dir.name}';
mkdir(out_dir);
save(fullfile(out_dir,'subj_name.mat'),'subj_name');

% pre-allocating space to speed up
n_subj = size(subj_dir,1);
file_name = fullfile(subj_dir,subj_dir(1).name);
dynamic_mats = importdata(file_name);
n_node = size(dynamic_mats,1);
n_window = length(dynamic_mats);
mask_of_up_mat = triu(ones(n_node, n_node),1)==1;  % mask of upper triangular matrix 
n_feature = sum(mask_of_up_mat(:));
mat_of_one_state = zeros(n_feature, n_window);
all_mat = zeros(n_feature, n_window, n_subj);

for i = 1:n_subj
    fprintf('load %dth dynamic matrix to all matrix\n',i);
    % if isfile(fullfile(subjdir,subFold(i+2).name))
    file_name=fullfile(subj_dir,subj_dir(i).name);
    dynamic_mats=importdata(file_name);
    
    % only extract the upper triangular matrix, and not include the diagonal
    for imat = 1:n_window
        triup_mat=dynamic_mats(:,:,imat);
        triup_mat=triup_mat(mask_of_up_mat);
        mat_of_one_state(:,imat)=triup_mat;
    end
    
    all_mat(:,:,i) = mat_of_one_state;
end
fprintf('======loaded all mat!======\n')


%% kmeans
fprintf('This process will take a while!\nWaiting for kmeans clustering...\n');

% prepare data
all_mat(isinf(all_mat)) = 1;
all_mat(isnan(all_mat)) = 0;

% flatten the each subject's 2D matrix to 1D row vector
all_mat = reshape(all_mat,n_feature,n_window*n_subj)';

% Randomly repeat clustering using new initial cluster centroid .
% Large sample size will be very time-consuming.
% Please use a high-performance computer, and wait patiently.
opts = statset('Display', 'final');
[idx, C, sumd, D] = kmeans(all_mat, k, 'Distance', clustering_method,...
                               'Replicates', 100, 'Options', opts);
fprintf('***kmeans clustering finished!***\n')


%% save

% saving meta info
fprintf('saving meta info...\n');
save(fullfile(out_dir,'idx.mat'),'idx');
save(fullfile(out_dir,'C.mat'),'C');
save(fullfile(out_dir,'sumd.mat'),'sumd');
save(fullfile(out_dir,'D.mat'),'D');

% Save the median network of each state of the whole group
fprintf('Getting and saving the median network of each state of the whole group...\n')
for i = 1 : k
    ind = idx==i;
    mat_of_one_state = all_mat(ind,:);
    median_mat = median(mat_of_one_state, 1);
    square_median_mat = eye(n_node);
    square_median_mat(mask_of_up_mat) = median_mat;
    square_median_mat = square_median_mat + square_median_mat';
    square_median_mat(eye(n_node) == 1) = 1;
    save(fullfile(out_dir,['cluster_',num2str(i), '.mat']), 'square_median_mat');
end

fprintf('============All Done!============\n');
end