function lc_cluster_for_dfc_gift_v3(subj_path, out_dir, krange, distance_measure, nreplicates)
% PURPOSE: To clustering dfc to K state.
% HOW:
% 	1: Initial clustering was performed on a subset of windows, consisting of local maxima in
% 	functional connectivity variance, as subject exemplars to decrease the redundancy 
% 	between windows and computational demands (Allen et al., 2014).
% 	The K-means clustering was performed to all exemplars and repeated N (nreplicates) times
% 	with random initial cluster centroid positions to escape local minima. 
% 	The optimal number of clusters was estimated using methods: gap, silhoutte (used in our paper), bic, aic and dunns 
% 	(implemented using icatb_optimal_clusters.m function in GIFT software)
% 	2: These sets of initial group centroids using the optimal number of clusters were used as starting points
%	to cluster all data into the optimal number of clusters.

% How to get subjects exemplars?
% 	First, wo compute variance of dynamic connectivity across all pairs at each window. 
% 	Second, we select windows corresponding to local maxima in this variance time course.

% INPUTS:
%   subj_path: subject's dFC files' path (matlab .mat or .txt file type with dimension of n_node*n_node*n_window)
%   krange: The search window of k, such as  2:1:20;
%   distance_measure: distance measure, such as 'cityblock', 'sqeuclidean', 'cosine', 'correlation', 'hamming'.
%   nreplicates: repeated nreplicates times with random initial cluster centroid positions to escape local minima
%   out_dir: directory to save results
% OUTPUTS:
    % Saving meta informations: idx, C, sumd, D
    % Saving median network for each state
    
% NOTE: We tend to use icatb_optimal_clusters.m function in GIFT software to identify the optimal number of clusters
% Thanks to GIFT software
% Author: Li Chao
% Email:lichao19870617@gmail.com OR lichao19870617@163.com
% Updated (2020/06/26): 
% Using both Davies-Bouldin and Silhouettes methods to identify the best k (optimal centroids).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
%% ----------------------------------input---------------------------------
if nargin < 5
    nreplicates = 10;
end

if nargin < 4
    distance_measure = 'cityblock';  % L1 distance
end

if nargin < 3
    krange = 2:1:10;
end

if nargin < 2
    out_dir = uigetdir(pwd, 'Select the folder for containing results');
end

if nargin < 1
    subj_folder = uigetdir(pwd, 'Select the folder containing subjects'' DFC network');
    subj_path_struct = dir(fullfile(subj_folder,'*.mat'));  
    subj_name = {subj_path_struct.name}';
    subj_path = fullfile(subj_folder, subj_name);
    % TODO: expand the .mat file to other file, e.g. .txt file
end
%% ----------------------------------input end---------------------------------

% Saving subjects's_name, so that we can align subject's order with index_of_state, Required and very important!
fprintf('Saving subject''s name according loading order...\n');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
timenow = strrep(num2str(fix(clock)),' ','');
savename = strcat('sorted_subjname_', timenow, '.txt');
savefullname = fullfile(out_dir,savename);
fid = fopen(savefullname,'wt');
n_subj = length(subj_path);
for i = 1:n_subj
    [~, sn] = fileparts(subj_path{i});
    fprintf(fid,'%s\n', sn);
end
fclose(fid);

% pre-allocating space to speed up
n_subj = size(subj_path,1);
file_name = subj_path{1};
dynamic_mats = importdata(file_name);
[n_node,n_node,n_window] = size(dynamic_mats);
mask_of_up_mat = triu(ones(n_node, n_node),1)==1;  % mask of upper triangular matrix 
n_feature = sum(mask_of_up_mat(:));
mat_of_one_sub = zeros(n_feature, n_window);
whole_mat = zeros(n_feature, n_window, n_subj);

% Load dfc
for i = 1:n_subj
    fprintf('Loading %dth dynamic matrix...\n',i);
    file_name = subj_path{i};
    dynamic_mats = importdata(file_name);
    % only extract the upper triangular matrix, and not include the diagonal
    for imat = 1:n_window
        triup_mat=dynamic_mats(:,:,imat);
        triup_mat=triup_mat(mask_of_up_mat);
        mat_of_one_sub(:,imat)=triup_mat;
    end
    whole_mat(:,:,i) = mat_of_one_sub;
end
fprintf('------------Loaded all mat!------------\n')

% prepare data
whole_mat(isinf(whole_mat)) = 1;
whole_mat(isnan(whole_mat)) = 0;

% find local maxima, and reshape all_mat at the same time.
fprintf('Finding local maxima in functional connectivity variance...\n');
count = 0; 
for i = 1:n_subj
    mat = whole_mat(:,:,i)';  % n_window*n_features
    variance = squeeze(var(mat,0,2));
    count = count + sum(islocalmax_matlab(variance,true));
end
localmaxima_mat = zeros(count, n_feature);

whole_mat_reshaped = zeros(n_subj*n_window,n_feature);  % for clustering whole dfc
startpoint = 1;
for i = 1:n_subj
    fprintf('\tFinding %dth local maxima...\n',i);
    mat = whole_mat(:,:,i)';  % n_window*n_features
    whole_mat_reshaped(i*n_window-n_window+1:i*n_window,:) = mat;
    variance = squeeze(var(mat,0,2));
    maxima_loc = islocalmax_matlab(variance,true);
    mat = mat(maxima_loc,:);  % n_localmaxima_window*n_features
    n_locmax_current = size(mat,1);
    if i ==1
        startpoint = 1;
    else
        startpoint = startpoint + n_locmax_delay;
    end
    endpoint = startpoint + n_locmax_current - 1;
    n_locmax_delay = n_locmax_current;
    localmaxima_mat(startpoint:endpoint,:) = mat;
end
clear whole_mat;
save(fullfile(out_dir, 'localmaxima.mat'), 'localmaxima_mat');
fprintf('------------Found all subjects'' local maxima!------------\n')

%% kmeans clustering to subject exemplars (local maxima)
% The optimal number of centroid states was estimated using the silhouette criterion.
% Reference1: Silhouettes: a graphical aid to the interpretation and validation of cluster analysis:doi:10.1016/0377-0427(87)90125-7
% Reference2: Dynamic functional connectivity changes associated with dementia in Parkinson¡¯s disease:doi:10.1093/brain/awz192
% The search window of k from 2 to N.
fprintf('Kmeans clustering to subject exemplars (local maxima in FC variance) to find the optimal k and corresponding centroid...\n');
% First I try to use icatb_optimal_clusters.m function in GIFT software to identify the optimal clusters number
% If no icatb_optimal_clusters to use, we use the default MATLAB fuction evalclusters.m.
disp('Running icatb_optimal_clusters function...');
stream = RandStream('mlfg6331_64');
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);

% Identify best k using Davies-Bouldin method
% This method is recommended by Victor M. Vergara <Determining the Number of States in Dynamic Functional Connectivity
% Using Cluster Validity Indexes>
disp('Identify best k using Davies-Bouldin method...');
try
    pool = parpool; 
catch
    fprintf('Already opened parpool\n');
end
myKmeans = @(X,K)(kmeans(X, K, 'emptyaction','singleton','Start', 'plus','replicate',nreplicates, 'Options', options,'Display','final'));
daviesbouldin = evalclusters(localmaxima_mat, myKmeans, 'DaviesBouldin','klist',krange);
k_optimal_daviesbouldin = daviesbouldin.OptimalK;  % The best k is determined by Davies-Bouldin method
daviesbouldin_values = daviesbouldin.CriterionValues;
save(fullfile(out_dir, 'daviesbouldin_values.mat'), 'daviesbouldin_values');

% Identify best k using silhoutte
disp('Identify best k using silhoutte...');
eva_silhoutte = icatb_optimal_clusters(localmaxima_mat, krange, 'method' , 'silhoutte');  % For main results
silhouette_values = eva_silhoutte{1}.values;
k_optimal_silhouette = eva_silhoutte{1}.K;
save(fullfile(out_dir, 'silhouette_values.mat'), 'silhouette_values');

% Identify best k using gap
% disp('Identify best k using gap stat...');
% eva_gap = icatb_optimal_clusters(localmaxima_mat, krange, 'method' , 'gap');  % For main results
% gap_values = eva_gap{1}.values;
% k_optimal_gap = eva_gap{1}.K;
% save(fullfile(out_dir, 'gap_values.mat'), 'gap_values');

% Get centroid
fprintf('Clustering subject exemplars to %d (optimal k) clusters for getting start centroid...\n', k_optimal_silhouette);
[~, centroid_optimal_silhouette, ~, ~] = kmeans(localmaxima_mat, k_optimal_silhouette, 'Distance', distance_measure, 'Options', options, 'emptyaction','singleton','Start', 'plus','replicate',nreplicates, 'Display','off');
if k_optimal_silhouette ~= k_optimal_daviesbouldin
    [~, centroid_optimal_daviesbouldin, ~, ~] = kmeans(localmaxima_mat, k_optimal_daviesbouldin, 'Distance', distance_measure, 'Options', options, 'emptyaction','singleton','Start', 'plus','replicate',nreplicates, 'Display','off');
end
clear localmaxima_mat;

%% kmeans clustering to all dfc using the optimal centroid identified by using the subject exemplars to the optimal number of clusters (silhoutte)
fprintf('Clustering all dfc to %d (optimal k) clusters using centroid derived from subject exemplar...\n', k_optimal_silhouette);
fprintf('This step may cost many memory and take a long time!\n');
[idx, C, sumd, D] = kmeans(whole_mat_reshaped, k_optimal_silhouette, 'Distance', distance_measure,'Replicates', 1, 'Options', options, 'Start', centroid_optimal_silhouette);
fprintf('Kmeans clustering to all subjects finished!\n')
fprintf('------------------------------------------------\n')

% Saving meta info
fprintf('saving meta info...\n');
out_dir_silhoutte = fullfile(out_dir, 'silhoutte');
if ~exist(fullfile(out_dir_silhoutte), 'dir')
    mkdir(fullfile(out_dir_silhoutte));
end
save(fullfile(out_dir_silhoutte,'idx.mat'),'idx');
save(fullfile(out_dir_silhoutte,'C.mat'),'C');
save(fullfile(out_dir_silhoutte,'sumd.mat'),'sumd');
save(fullfile(out_dir_silhoutte,'D.mat'),'D');

% Save the centroid of each state of the whole group
fprintf('Getting and saving the median network of each state of the whole group...\n')
for i = 1 : k_optimal_silhouette
    median_mat = C(i,:);
    square_median_mat = eye(n_node);
    square_median_mat(mask_of_up_mat) = median_mat;
    square_median_mat = square_median_mat + square_median_mat';
    square_median_mat(eye(n_node) == 1) = 1;
    save(fullfile(out_dir_silhoutte, ['group_centroids_',num2str(i), '.mat']), 'square_median_mat');
end
clear idx C sumd D square_median_mat median_mat

%% kmeans clustering to all dfc using the optimal centroid identified by using the subject exemplars to the optimal number of clusters (daviesbouldin)
if k_optimal_silhouette ~= k_optimal_daviesbouldin
    fprintf('Clustering all dfc to %d (optimal k) clusters using centroid derived from subject exemplar...\n', k_optimal_daviesbouldin);
    fprintf('This step may cost many memory and take a long time!\n');
    [idx, C, sumd, D] = kmeans(whole_mat_reshaped, k_optimal_daviesbouldin, 'Distance', distance_measure,'Replicates', 1, 'Options', options, 'Start', centroid_optimal_daviesbouldin);
    fprintf('Kmeans clustering to all subjects finished!\n')
    fprintf('------------------------------------------------\n')

    % Saving meta info
    out_dir_daviesbouldin = fullfile(out_dir, 'daviesbouldin');
    if ~exist(fullfile(out_dir_daviesbouldin), 'dir')
        mkdir(fullfile(out_dir_daviesbouldin));
    end

    fprintf('saving meta info...\n');
    save(fullfile(out_dir_daviesbouldin,'idx.mat'),'idx');
    save(fullfile(out_dir_daviesbouldin,'C.mat'),'C');
    save(fullfile(out_dir_daviesbouldin,'sumd.mat'),'sumd');
    save(fullfile(out_dir_daviesbouldin,'D.mat'),'D');

    % Save the centroid of each state of the whole group
    fprintf('Getting and saving the median network of each state of the whole group...\n')
    for i = 1 : k_optimal_daviesbouldin
        median_mat = C(i,:);
        square_median_mat = eye(n_node);
        square_median_mat(mask_of_up_mat) = median_mat;
        square_median_mat = square_median_mat + square_median_mat';
        square_median_mat(eye(n_node) == 1) = 1;
        save(fullfile(out_dir_daviesbouldin,['group_centroids_',num2str(i), '.mat']), 'square_median_mat');
    end
end

%%==================================================================
fprintf('------------All Done!------------\n');
toc
end
