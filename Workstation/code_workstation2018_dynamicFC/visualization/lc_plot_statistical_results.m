%% This script is used to visualize statistical results of transdiagnostic dynamic functional connectivity (including group mean functional connectivitync).

%% INPUTS
results_root = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\';
cmap_fc = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_net0point5_pospoint8';
cmap_fvalues = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_fvalues';
cmap_posthoc_tvalues = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_posthoc_tvalues';
cmap_posthoc_effectsize = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmap_posthoc_effectsize';
mask_path = '';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};

%% Load
load (cmap_fc)
load(cmap_fvalues)
load(cmap_posthoc_tvalues)
load(cmap_posthoc_effectsize)

idx = importdata(fullfile(results_root, 'idx.mat'));
state1 = importdata(fullfile(results_root, 'group_centroids_1.mat'));
state2 = importdata(fullfile(results_root, 'group_centroids_2.mat'));
state3 = importdata(fullfile(results_root, 'group_centroids_3.mat'));
state1(eye(size(state1))==1)=0;
state2(eye(size(state2))==1)=0;
state3(eye(size(state3))==1)=0;


group_mean_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_group_mean.mat'));
group_mean_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_group_mean.mat'));
group_mean_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_group_mean.mat'));

anova_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_ANCOVA_FDR_Corrected_0.05.mat'));
anova_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_ANCOVA_FDR_Corrected_0.05.mat'));
anova_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_ANCOVA_FDR_Corrected_0.05.mat'));

posthoc_szvshc_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_3vs1_FDR0.05.mat'));
posthoc_szvshc_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_3vs1_FDR0.05.mat'));
posthoc_szvshc_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_3vs1_FDR0.05.mat'));

posthoc_bdvshc_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_4vs1_FDR0.05.mat'));
posthoc_bdvshc_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_4vs1_FDR0.05.mat'));
posthoc_bdvshc_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_4vs1_FDR0.05.mat'));

posthoc_mddvshc_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_2vs1_FDR0.05.mat'));
posthoc_mddvshc_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_2vs1_FDR0.05.mat'));
posthoc_mddvshc_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_2vs1_FDR0.05.mat'));

posthoc_szvsmdd_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_3vs2_FDR0.05.mat'));
posthoc_szvsmdd_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_3vs2_FDR0.05.mat'));
posthoc_szvsmdd_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_3vs2_FDR0.05.mat'));

posthoc_bdvsmdd_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_4vs2_FDR0.05.mat'));
posthoc_bdvsmdd_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_4vs2_FDR0.05.mat'));
posthoc_bdvsmdd_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_4vs2_FDR0.05.mat'));

posthoc_bdvssz_state1 = importdata(fullfile(results_root, 'results_state1', 'state1_4vs3_FDR0.05.mat'));
posthoc_bdvssz_state2 = importdata(fullfile(results_root, 'results_state2', 'state2_4vs3_FDR0.05.mat'));
posthoc_bdvssz_state3 = importdata(fullfile(results_root, 'results_state3', 'state3_4vs3_FDR0.05.mat'));

shared_dysconnectivity_state1 = importdata(fullfile(results_root, 'results_state1', 'shared_1and2and3_fdr.mat'));
shared_dysconnectivity_state2 = importdata(fullfile(results_root, 'results_state2', 'shared_1and2and3_fdr.mat'));
shared_dysconnectivity_state3 = importdata(fullfile(results_root, 'results_state3', 'shared_1and2and3_fdr.mat'));

distinct_sz_dysconnectivity_state1 = importdata(fullfile(results_root, 'results_state1', 'distinct_1_fdr.mat'));
distinct_sz_dysconnectivity_state2 = importdata(fullfile(results_root, 'results_state2', 'distinct_1_fdr.mat'));
distinct_sz_dysconnectivity_state3 = importdata(fullfile(results_root, 'results_state3', 'distinct_1_fdr.mat'));

distinct_mdd_dysconnectivity_state1 = importdata(fullfile(results_root, 'results_state1', 'distinct_2_fdr.mat'));
distinct_mdd_dysconnectivity_state2 = importdata(fullfile(results_root, 'results_state2', 'distinct_2_fdr.mat'));
distinct_mdd_dysconnectivity_state3 = importdata(fullfile(results_root, 'results_state3', 'distinct_2_fdr.mat'));

distinct_bd_dysconnectivity_state1 = importdata(fullfile(results_root, 'results_state1', 'distinct_3_fdr.mat'));
distinct_bd_dysconnectivity_state2 = importdata(fullfile(results_root, 'results_state2', 'distinct_3_fdr.mat'));
distinct_bd_dysconnectivity_state3 = importdata(fullfile(results_root, 'results_state3', 'distinct_3_fdr.mat'));

%% Plot states
figure('Position',[50 50 500 200]);
ax = tight_subplot(1,3,[0.05 0.1],[0.01 0.05],[0.01 0.01]);

axes(ax(1)) 
lc_netplot('-n', state1, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==1))/length(idx));
title(['State 1', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

axes(ax(2)) 
lc_netplot('-n', state2, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==2))/length(idx));
title(['State 2', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square

axes(ax(3)) 
lc_netplot('-n', state3, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_net0point5_pospoint8)
%     colorbar;
caxis([-0.5,0.8])
state_frequency = sprintf('%.2f', (sum(idx==3))/length(idx));
title(['State 3', ' (', state_frequency ,')'], 'FontSize', 8, 'FontWeight', 'bold');
axis square
saveas(gcf,fullfile(results_root, 'states.pdf'))


%% Plot group mean and F-values
figure('Position',[100 100 300 500]);
ax = tight_subplot(5,3,[0.05 0.01],[0.01 0.05],[0.01 0.01]);
% HC
axes(ax(1)) 
lc_netplot('-n', group_mean_state1(:,:,1), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
% colorbar
title('State 1', 'FontSize', 6)
axis square

axes(ax(2)) 
lc_netplot('-n', group_mean_state2(:,:,1), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 2', 'FontSize', 6)
axis square

axes(ax(3))
lc_netplot('-n', group_mean_state3(:,:,1), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 3', 'FontSize', 6)
axis square

% SZ
axes(ax(4)) 
lc_netplot('-n', group_mean_state1(:,:,3), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 1', 'FontSize', 6)
axis square

axes(ax(5)) 
lc_netplot('-n', group_mean_state2(:,:,3), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 2', 'FontSize', 6)
axis square

axes(ax(6)) 
lc_netplot('-n', group_mean_state3(:,:,3), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 3', 'FontSize', 6)
axis square

% BD
axes(ax(7)) 
lc_netplot('-n', group_mean_state1(:,:,4), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 1', 'FontSize', 6)
axis square

axes(ax(8)) 
lc_netplot('-n', group_mean_state2(:,:,4), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 2', 'FontSize', 6)
axis square

axes(ax(9)) 
lc_netplot('-n', group_mean_state3(:,:,4), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 3', 'FontSize', 6)
axis square

% MDD
axes(ax(10))
lc_netplot('-n', group_mean_state1(:,:,2), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 1', 'FontSize', 6)
axis square

axes(ax(11))
lc_netplot('-n', group_mean_state2(:,:,2), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 2', 'FontSize', 6)
axis square

axes(ax(12))
lc_netplot('-n', group_mean_state3(:,:,2), '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
colormap(cmp_net0point5_pospoint8);
caxis([-0.5,0.8])
title('State 3', 'FontSize', 6)
axis square

% Fvalues
axes(ax(13))
lc_netplot('-n', anova_state1.Fvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_fvalues);
caxis([0,12])
title('State 1', 'FontSize', 6)
axis square

axes(ax(14))
lc_netplot('-n', anova_state2.Fvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_fvalues);
caxis([0 12])
title('State 2', 'FontSize', 6)
axis square

axes(ax(15))
lc_netplot('-n', anova_state3.Fvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_fvalues);
caxis([0 12])
title('State 3', 'FontSize', 6)
axis square

saveas(gcf,fullfile(results_root, 'group_mean_and_Fvalues.pdf'))

%% Plot results of posthoc analysis (part1: patients VS healthy controls), and shared and unique dysconnectivity.
figure('Position',[100 100 300 400]);
ax = tight_subplot(4,3,[0.05 0.01],[0.01 0.05],[0.01 0.01]);

% SZ vs HC
axes(ax(1))
lc_netplot('-n', posthoc_szvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 1', 'FontSize', 6)
axis square

axes(ax(2))
lc_netplot('-n', posthoc_szvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 2', 'FontSize', 6)
axis square

axes(ax(3))
lc_netplot('-n', posthoc_szvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 3', 'FontSize', 6)
axis square

% BD vs HC
axes(ax(4))
lc_netplot('-n', posthoc_bdvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 1', 'FontSize', 6)
axis square

axes(ax(5))
lc_netplot('-n', posthoc_bdvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 2', 'FontSize', 6)
axis square

axes(ax(6))
lc_netplot('-n', posthoc_bdvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 3', 'FontSize', 6)
axis square

% MDD vs HC
axes(ax(7))
lc_netplot('-n', posthoc_mddvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 1', 'FontSize', 6)
axis square

axes(ax(8))
lc_netplot('-n', posthoc_mddvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 2', 'FontSize', 6)
axis square

axes(ax(9))
lc_netplot('-n', posthoc_mddvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-5 5])
title('State 3', 'FontSize', 6)
axis square

% Shared dysconnectivity
axes(ax(10))
lc_netplot('-n', posthoc_szvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1,'-m',shared_dysconnectivity_state1, '-lw', 0.2, '-ib', 1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 1', 'FontSize', 6)
axis square

axes(ax(11))
lc_netplot('-n', posthoc_szvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1,'-m',shared_dysconnectivity_state2, '-lw', 0.2, '-ib', 1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 2', 'FontSize', 6)
axis square

axes(ax(12))
lc_netplot('-n', posthoc_szvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1,'-m',shared_dysconnectivity_state3, '-lw', 0.2, '-ib', 1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 3', 'FontSize', 6)
axis square

saveas(gcf,fullfile(results_root,'posthoc_patientsVScontrols_and_shared_dysconnectivity.pdf'))


%% Plot unique dysconnectivity
figure('Position',[100 100 300 300]);
ax = tight_subplot(3,3,[0.05 0.01],[0.01 0.05],[0.01 0.01]);

% Unique dysconnectivity of SZ
axes(ax(1))
lc_netplot('-n', posthoc_szvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_sz_dysconnectivity_state1,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 1', 'FontSize', 6)
axis square

axes(ax(2))
lc_netplot('-n', posthoc_szvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_sz_dysconnectivity_state2,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 2', 'FontSize', 6)
axis square

axes(ax(3))
lc_netplot('-n', posthoc_szvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_sz_dysconnectivity_state3,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 3', 'FontSize', 6)
axis square

% Unique dysconnectivity of BD
axes(ax(4))
lc_netplot('-n', posthoc_bdvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_bd_dysconnectivity_state1,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 1', 'FontSize', 6)
axis square

axes(ax(5))
lc_netplot('-n', posthoc_bdvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_bd_dysconnectivity_state2,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 2', 'FontSize', 6)
axis square

axes(ax(6))
lc_netplot('-n', posthoc_bdvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_bd_dysconnectivity_state3,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 3', 'FontSize', 6)
axis square

% Unique dysconnectivity of MDD
axes(ax(7))
lc_netplot('-n', posthoc_mddvshc_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_mdd_dysconnectivity_state1,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 1', 'FontSize', 6)
axis square

axes(ax(8))
lc_netplot('-n', posthoc_mddvshc_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_mdd_dysconnectivity_state2,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 2', 'FontSize', 6)
axis square

axes(ax(9))
lc_netplot('-n', posthoc_mddvshc_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 1, '-m',distinct_mdd_dysconnectivity_state3,'-lw', 0.2, '-ib',1);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-1 1])
title('State 3', 'FontSize', 6)
axis square

saveas(gcf,fullfile(results_root,'unique_dysconnectivity.pdf'))



%% Plot results of posthoc analysis (part2: patients VS patients)
figure('Position',[100 100 300 300]);
ax = tight_subplot(3,3,[0.05 0.01],[0.01 0.05],[0.01 0.01]);

% SZ vs BD
axes(ax(1))
lc_netplot('-n', -posthoc_bdvssz_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 1', 'FontSize', 6)
axis square

axes(ax(2))
lc_netplot('-n', -posthoc_bdvssz_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 2', 'FontSize', 6)
axis square

axes(ax(3))
lc_netplot('-n', -posthoc_bdvssz_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 3', 'FontSize', 6)
axis square

% SZ vs MDD
axes(ax(4))
lc_netplot('-n', posthoc_szvsmdd_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 1', 'FontSize', 6)
axis square

axes(ax(5))
lc_netplot('-n', posthoc_szvsmdd_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 2', 'FontSize', 6)
axis square

axes(ax(6))
lc_netplot('-n', posthoc_szvsmdd_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 3', 'FontSize', 6)
axis square

% BD vs MDD
axes(ax(7))
lc_netplot('-n', posthoc_bdvsmdd_state1.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 1', 'FontSize', 6)
axis square

axes(ax(8))
lc_netplot('-n', posthoc_bdvsmdd_state2.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 2', 'FontSize', 6)
axis square

axes(ax(9))
lc_netplot('-n', posthoc_bdvsmdd_state3.Tvalues, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmp_posthoc_tvalues);
caxis([-4 4])
title('State 3', 'FontSize', 6)
axis square

saveas(gcf,fullfile(results_root,'posthoc_patientsVSpatients.pdf'))


%% Plot effect size (including patients vs controls, and patients VS patients)
figure('Position',[100 100 300 700]);
ax = tight_subplot(6,3,[0.05 0.01],[0.01 0.05],[0.01 0.01]);

% SZ vs HC
axes(ax(1))
lc_netplot('-n', posthoc_szvshc_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(2))
lc_netplot('-n', posthoc_szvshc_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(3))
lc_netplot('-n', posthoc_szvshc_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

% BD vs HC
axes(ax(4))
lc_netplot('-n', posthoc_bdvshc_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(5))
lc_netplot('-n', posthoc_bdvshc_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(6))
lc_netplot('-n', posthoc_bdvshc_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

% MDD vs HC
axes(ax(7))
lc_netplot('-n', posthoc_mddvshc_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(8))
lc_netplot('-n', posthoc_mddvshc_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(9))
lc_netplot('-n', posthoc_mddvshc_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

% SZ vs BD
axes(ax(10))
lc_netplot('-n', -posthoc_bdvssz_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(11))
lc_netplot('-n', -posthoc_bdvssz_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(12))
lc_netplot('-n', -posthoc_bdvssz_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

% SZ vs MDD
axes(ax(13))
lc_netplot('-n', posthoc_szvsmdd_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(14))
lc_netplot('-n', posthoc_szvsmdd_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(15))
lc_netplot('-n', posthoc_szvsmdd_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

% BD vs MDD
axes(ax(16))
lc_netplot('-n', posthoc_bdvsmdd_state1.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 1', 'FontSize', 6)
axis square

axes(ax(17))
lc_netplot('-n', posthoc_bdvsmdd_state2.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 2', 'FontSize', 6)
axis square

axes(ax(18))
lc_netplot('-n', posthoc_bdvsmdd_state3.cohen_d_posthoc, '-ni', net_index_path,'-il',0, '-lg', legends, '-lgf', 7, '-iam', 0, '-lw', 0.2);
fig = gca;
colormap(fig,cmap_posthoc_effectsize);
caxis([-0.6 0.6])
title('State 3', 'FontSize', 6)
axis square

saveas(gcf,fullfile(results_root,'posthoc_effect_size.pdf'))