% This script is used to perform correlation analysis between results of silhoutte method and davies-bouldin

daviesbouldin_results = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength20__silhoutte_and_davies-bouldin\daviesbouldin';
silhoutte_results = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength20__silhoutte_and_davies-bouldin\silhoutte';
cmap = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_net0point5_pospoint8';
mask_path = '';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};
%
load (cmap)
c1 = importdata(fullfile(silhoutte_results, 'group_centroids_1.mat'));
c2 = importdata(fullfile(silhoutte_results, 'group_centroids_2.mat'));
c1_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(1),'.mat']));
c2_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(2),'.mat']));
c3_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(3),'.mat']));
c_db{2} = c1_db;
c_db{3} = c2_db;
c_db{4} = c3_db;

coef(1) = corr(c1(:), c_db{2}(:));
coef(2) = corr(c1(:), c_db{3}(:));
coef(3) = corr(c1(:), c_db{4}(:));

coef(4) = corr(c2(:), c_db{2}(:));
coef(5) = corr(c2(:), c_db{3}(:));
coef(6) = corr(c2(:), c_db{4}(:));
coef = reshape(coef, [2,3]);

matrix = [c1(:),c2(:), c_db{2}(:), c_db{3}(:), c_db{4}(:)];
matrixplot(corr(matrix), 'FigShap','d');
colormap(gray)

%%
figure('Position',[100 100 500 650]);
subplot(3,2,1);
lc_netplot('-n', c1, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 7);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
axis square


subplot(3,2,3);
lc_netplot('-n', c_db{2}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 7);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
axis square

subplot(3,2,4);
lc_netplot('-n', c_db{3}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 7);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
axis square

% figure;
%     colorbar;
subplot(3,2,5);
lc_netplot('-n', c2, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 7);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
axis square

subplot(3,2,6)
lc_netplot('-n', c_db{4}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 7);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
axis square

% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\HBM\Revision\correlation_silhoutte_and_daviesbouldin_state1.tif')
% set(gcf,'PaperType','a2');
saveas(gcf,'D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\HBM\Revision\correlation_silhoutte_and_daviesbouldin11.pdf')

