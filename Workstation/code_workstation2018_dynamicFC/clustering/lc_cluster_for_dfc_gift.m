function lc_cluster_for_dfc_gift(subj_path, out_dir, krange, distance_measure, nreplicates)
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

% input :
%   subj_path: subject's dFC files' path (matlab .mat or .txt file type with dimension of n_node*n_node*n_window)
%   krange: The search window of k, such as  2:1:20;
%   distance_measure: distance measure, such as 'cityblock', 'sqeuclidean', 'cosine', 'correlation', 'hamming'.
%   nreplicates: repeated nreplicates times with random initial cluster centroid positions to escape local minima
%   out_dir: directory to save results
% output:
    % Saving meta informations: idx, C, sumd, D
    % Saving median network for each state
    
% NOTE: We tend to use icatb_optimal_clusters.m function in GIFT software to identify the optimal number of clusters
% Thanks to GIFT software
% Author: Li Chao
% Email:lichao19870617@gmail.com OR lichao19870617@163.com
% Add(2020/1/2): 
%   1. I added elbow criterion.
%   2. Function will save criterion values.
%   3. Besides kmeans, I added fractional analysis to get brain states.

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
    out_dir = uigetdir(pwd, 'Select the folder containing results');
end

if nargin < 1
    subj_folder = uigetdir(pwd, 'Select the folder containing subjects'' network');
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
file_name = fullfile(subj_folder,subj_path(1).name);
dynamic_mats = importdata(file_name);
n_node = size(dynamic_mats,1);
n_window = length(dynamic_mats);
mask_of_up_mat = triu(ones(n_node, n_node),1)==1;  % mask of upper triangular matrix 
n_feature = sum(mask_of_up_mat(:));
mat_of_one_sub = zeros(n_feature, n_window);
whole_mat = zeros(n_feature, n_window, n_subj);

% Load dfc
for i = 1:n_subj
    fprintf('Loading %dth dynamic matrix...\n',i);
    file_name = fullfile(subj_folder, subj_path(i).name);
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
    count = count + sum(islocalmax(variance));
end
localmaxima_mat = zeros(count, n_feature);

whole_mat_reshaped = zeros(n_subj*n_window,n_feature);  % for clustering whole dfc
startpoint = 1;
for i = 1:n_subj
    fprintf('\tFinding %dth local maxima...\n',i);
    mat = whole_mat(:,:,i)';  % n_window*n_features
    whole_mat_reshaped(i*n_window-n_window+1:i*n_window,:) = mat;
    variance = squeeze(var(mat,0,2));
    maxima_loc = islocalmax(variance);
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
% Reference2: Dynamic functional connectivity changes associated with dementia in Parkinson’s disease:doi:10.1093/brain/awz192
% The search window of k from 2 to N.
% TODO: expant to other criterion such as elbow criterion etc.
% [ratio, centroid] = lc_kmeans_identifyK_elbowcriterion(localmaxima_mat,krange, distance_measure, nreplicates, 1);
fprintf('Kmeans clustering to subject exemplars (local maxima in FC variance) to find the optimal k and corresponding centroid...\n');
% First I try to use icatb_optimal_clusters.m function in GIFT software to identify the optimal clusters number
% If no icatb_optimal_clusters to use, we use the default MATLAB fuction evalclusters.m.
disp('Running icatb_optimal_clusters function...');
stream = RandStream('mlfg6331_64');
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);

eva_silhoutte = icatb_optimal_clusters(localmaxima_mat, krange, 'method' , 'silhoutte');  % For main results
silhouette_values = eva_silhoutte{1}.values;
k_optimal = eva_silhoutte{1}.K;
save(fullfile(out_dir, 'silhouette_values.mat'), 'silhouette_values');

% eva_elbow = icatb_optimal_clusters(localmaxima_mat, krange, 'method' , 'elbow');  % For validation
% elbow_values = eva_elbow{1}.values;
% save(fullfile(out_dir, 'elbow_values.mat'), 'elbow_values');
% subplot(1,2,1);
plot(silhouette_values,'-o','linewidth',2);
title('Silhouette values');
% subplot(1,2,2);
% plot(elbow_values);
% title('Elbow values');

% disp('Running MATLAB default evalclusters.m function...');
% try
%     pool = parpool; 
% catch
%     fprintf('Already opened parpool\n');
% end
% stream = RandStream('mlfg6331_64');
% options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
% myKmeans = @(X,K)(kmeans(X, K, 'emptyaction','singleton','Start', 'plus','replicate',nreplicates, 'Options', options,'Display','final'));
% eva_silhoutte = evalclusters(localmaxima_mat, myKmeans, 'silhouette','klist',krange,'Distance', distance_measure);
% k_optimal = eva_silhoutte.OptimalK;
% silhouette_values = eva_silhoutte.CriterionValues;
% save(fullfile(out_dir, 'silhouette_values.mat'), 'silhouette_values');
% plot(silhouette_values);
% title('silhouette values');

fprintf('Clustering subject exemplars to %d (optimal k) clusters for getting start centroid...\n', k_optimal);
[~, centroid_optimal, ~, ~] = kmeans(localmaxima_mat, k_optimal, 'Distance', distance_measure, 'Options', options, 'emptyaction','singleton','Start', 'plus','replicate',nreplicates, 'Display','off');
clear localmaxima_mat;

%% kmeans clustering to all dfc using the optimal centroid identified by using the subject exemplars to the optimal number of clusters
fprintf('Clustering all dfc to %d (optimal k) clusters using centroid derived from subject exemplar...\n', k_optimal);
fprintf('This step may cost many memory and take a long time!\n');
[idx, C, sumd, D] = kmeans(whole_mat_reshaped, k_optimal, 'Distance', distance_measure,'Replicates', 1, 'Options', options, 'Start', centroid_optimal);
fprintf('Kmeans clustering to all subjects finished!\n')
fprintf('------------------------------------------------\n')

% Saving meta info
fprintf('saving meta info...\n');
save(fullfile(out_dir,'idx.mat'),'idx');
save(fullfile(out_dir,'C.mat'),'C');
save(fullfile(out_dir,'sumd.mat'),'sumd');
save(fullfile(out_dir,'D.mat'),'D');

% Save the centroid of each state of the whole group
fprintf('Getting and saving the median network of each state of the whole group...\n')
for i = 1 : k_optimal
    median_mat = C(i,:);
    square_median_mat = eye(n_node);
    square_median_mat(mask_of_up_mat) = median_mat;
    square_median_mat = square_median_mat + square_median_mat';
    square_median_mat(eye(n_node) == 1) = 1;
    save(fullfile(out_dir,['group_centroids_',num2str(i), '.mat']), 'square_median_mat');
end

%% -----------------------------------------------------------------
% fprintf('Using dimensional latent method (Fractor analysis) to extract dfc states...\n');
% whole_mat_pca = zeros(n_feature*n_subj,n_window);
% loc_start = 1;
% loc_end = n_feature;
% for i = 1:n_subj
%     whole_mat_pca(loc_start:loc_end,:) = whole_mat(:,:,i);
%     loc_start = loc_start + n_feature;
%     loc_end = loc_start + n_feature - 1;
% end
% [Lambda,~,~,~,fractors] = factoran(whole_mat_pca, k_optimal, 'scores','regression');  % Factoran
% % Contribut = 100*sum(Lambda.^2)/173;
% % CumCont = cumsum(Contribut);
% C1 = fractors;
% % Save the centroid of each state of the whole group
% fprintf('Getting and saving the Fractors...\n')
% for i = 1 : k_optimal
%     C1_reshaped = reshape(C1(:,i), n_feature, n_subj)';
%     median_mat = median( C1_reshaped);
%     square_median_mat = eye(n_node);
%     square_median_mat(mask_of_up_mat) = median_mat;
%     square_median_mat = square_median_mat + square_median_mat';
%     square_median_mat(eye(n_node) == 1) = 1;
%     save(fullfile(out_dir,['frator_',num2str(i), '.mat']), 'square_median_mat');
% end
% fprintf('Fractor analysis done!...\n')

fprintf('------------All Done!------------\n');
toc
end
