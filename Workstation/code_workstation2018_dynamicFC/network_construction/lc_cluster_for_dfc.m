function lc_cluster_for_dfc(subj_path,k,clustering_method, out_dir)
% cluster for dynamic fc matrix
% output:
    % meta informations: idx, C, sumd, D
    % median network for each state
    
% NOTE:
    % 1£ºOnly use upper triangular matrix as features (not include diagonal)
    % 2£ºOnly use results from group level. So not every subject has all the states.

%% input
if nargin < 4
    out_dir = uigetdir(pwd, 'Select the folder containing results');
end

if nargin < 3
    clustering_method = 'cityblock';
end

if nargin < 2
    k = str2double(input('Enter the K you want to cluster:', 's'));
end

if nargin < 1
    subj_folder = uigetdir(pwd, 'Select the folder containing subjects'' network');
    subj_path = dir(fullfile(subj_folder,'*.mat'));  
    % TODO: expand the .mat file to other file like txt
end

%%  *save subjects's_name, 
% so that we can align subject's order with index_of_state.
%(Required!)
subj_name = {subj_path.name}';
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

timenow = strrep(num2str(fix(clock)),' ','');
savename = strcat('ordered_subjname_', timenow, '.txt');
savefullname = fullfile(out_dir,savename);
fid = fopen(savefullname,'wt');
n_subj = length(subj_name);
for i = 1:n_subj
    fprintf(fid,'%s\n',subj_name{i});
end
fclose(fid);

%% pre-allocating space to speed up
n_subj = size(subj_path,1);
file_name = fullfile(subj_path,subj_path(1).name);
dynamic_mats = importdata(file_name);
n_node = size(dynamic_mats,1);
n_window = length(dynamic_mats);
mask_of_up_mat = triu(ones(n_node, n_node),1)==1;  % mask of upper triangular matrix 
n_feature = sum(mask_of_up_mat(:));
mat_of_one_state = zeros(n_feature, n_window);
all_mat = zeros(n_feature, n_window, n_subj);

%% load all subjects matrix
for i = 1:n_subj
    fprintf('load %dth dynamic matrix to all matrix\n',i);
    file_name = fullfile(subj_path, subj_path(i).name);
    dynamic_mats = importdata(file_name);
    
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
fprintf('Congratulations! the kmeans clustering finished finally!\n')

%% save
% saving meta info
fprintf('saving meta info...\n');
save(fullfile(out_dir,'idx.mat'),'idx');
save(fullfile(out_dir,'C.mat'),'C');
save(fullfile(out_dir,'sumd.mat'),'sumd');
save(fullfile(out_dir,'D.mat'),'D');

% Save the median network of each state of the whole group
% OR directly save the 'C'
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