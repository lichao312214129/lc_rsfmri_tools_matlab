results_root = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\737';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex17.mat';
cmap_fc = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_net0point5_pospoint8';
legends = {'Central visual', 'Peripheral visual', ...
            'SomMot A', 'SomMot B', ...
            'DorsAttn A', 'DorsAttn B',...
            'Sal/VentAtt A', 'Sal/VentAtt B', ...
            'Limbic A', 'Limbic B', ...
            'Control A', 'Control B', 'Control C', ...
            'Default A', 'Default B', 'Default C', 'Default D'};

%% Load
load (cmap_fc)
idx = importdata(fullfile(results_root, 'idx.mat'));
state1 = importdata(fullfile(results_root, 'group_centroids_1.mat'));
state2 = importdata(fullfile(results_root, 'group_centroids_2.mat'));
state3 = importdata(fullfile(results_root, 'group_centroids_3.mat'));
state1(eye(size(state1))==1)=0;
state2(eye(size(state2))==1)=0;
state3(eye(size(state3))==1)=0;

%% Plot states
figure('Position',[50 50 500 400]);
ax = tight_subplot(1,3,[0.05 0.1],[0.01 0.05],[0.01 0.01]);

axes(ax(1)) 
lc_netplot('-n', state1, '-ni', net_index_path,'-lw',0.01,'-il',1, '-lg', legends, '-lgf', 3.5);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==1))/length(idx));
title(['State 1', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

axes(ax(2)) 
lc_netplot('-n', state2, '-ni', net_index_path,'-lw',0.01,'-il',1, '-lg', legends, '-lgf', 3.5);
colormap(cmp_net0point5_pospoint8)

caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==2))/length(idx));
title(['State 2', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

axes(ax(3)) 
lc_netplot('-n', state3, '-ni', net_index_path,'-lw',0.01,'-il',1, '-lg', legends, '-lgf', 3.5);
colormap(cmp_net0point5_pospoint8)
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==3))/length(idx));
title(['State 3', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

cb = colorbar('horiz','position',[0.35 0.15 0.28 0.02]); % 显示colorbar
get(cb, 'YTick')
set(cb, 'YTick', [-1 -0.5 0 0.5 1])
set(cb,'YTickLabel',{'-9','0','0.5','1','2'})
ylabel(cb,'Functional connectivity (Z)', 'FontSize', 10);  % 设置colorbar的title
saveas(gcf,fullfile('D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\HBM\Revision_1\Figures', 'states_17networks.pdf'))
