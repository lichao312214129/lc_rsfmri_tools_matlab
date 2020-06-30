%% This script is used to perform correlation analysis between results of silhoutte method and davies-bouldin

% INPUTS
results_root = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin';
cmap = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_net0point5_pospoint8';
mask_path = '';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};

%
daviesbouldin_results =fullfile(results_root, 'daviesbouldin');
silhoutte_results = fullfile(results_root, 'silhoutte');
idx_davies_bouldin = importdata(fullfile(daviesbouldin_results, 'idx.mat'));
idx_silhoutte = importdata(fullfile(silhoutte_results, 'idx.mat'));

%
load (cmap)
c1 = importdata(fullfile(silhoutte_results, 'group_centroids_1.mat'));
c2 = importdata(fullfile(silhoutte_results, 'group_centroids_2.mat'));
c1_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(1),'.mat']));
c2_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(2),'.mat']));
c3_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(3),'.mat']));
c_db{1} = c1_db;
c_db{2} = c2_db;
c_db{3} = c3_db;

c1(eye(size(c1))==1)=0;
c2(eye(size(c2))==1)=0;
c_db{1}(eye(size(c_db{1}))==1)=0;
c_db{2}(eye(size(c_db{2}))==1)=0;
c_db{3}(eye(size(c_db{3}))==1)=0;

coef(1) = corr(c1(:), c_db{1}(:));
coef(2) = corr(c1(:), c_db{2}(:));
coef(3) = corr(c1(:), c_db{3}(:));

coef(4) = corr(c2(:), c_db{1}(:));
coef(5) = corr(c2(:), c_db{2}(:));
coef(6) = corr(c2(:), c_db{3}(:));
coef = reshape(coef, [2,3]);

matrix = [c1(:),c2(:), c_db{1}(:), c_db{2}(:), c_db{3}(:)];


%%
figure('Position',[50 50 500 1000]);
subplot(3,2,1);
lc_netplot('-n', c1, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx_silhoutte==1))/length(idx_silhoutte));
title(['Silhouette state 1', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

ax = subplot(3,2,2);
matrixplot( corr(matrix), '','');
title('Correlations of centroids', 'FontSize', 8, 'FontWeight', 'bold');
colormap(ax,gray)

subplot(3,2,3);
lc_netplot('-n', c_db{3}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx_davies_bouldin==3))/length(idx_davies_bouldin));
title(['Davies-bouldin state 3', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

subplot(3,2,4);
lc_netplot('-n', c_db{2}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx_davies_bouldin==2))/length(idx_davies_bouldin));
title(['Davies-bouldin state 2', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

% figure;
%     colorbar;
subplot(3,2,5);
lc_netplot('-n', c2, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx_silhoutte==2))/length(idx_silhoutte));
title(['Silhouette state 2', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

subplot(3,2,6)
lc_netplot('-n', c_db{1}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx_davies_bouldin==1))/length(idx_davies_bouldin));
title(['Davies-bouldin state 1', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\HBM\Revision\correlation_silhoutte_and_daviesbouldin_state1.tif')
% set(gcf,'PaperType','a2');
saveas(gcf,fullfile('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin', 'correlation_silhoutte_and_daviesbouldin.pdf'))

