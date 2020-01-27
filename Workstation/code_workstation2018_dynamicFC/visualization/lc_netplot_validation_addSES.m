% This script is used for visualization shared dysconnectivity for validation results (add SES as covariances) 
if_add_mask=1;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%% Plot
ax = tight_subplot(3,2,[0.05 0.05],[0.05 0.05],[0.01 0.01]);

%% ANCOVA
axes(ax(1))
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_STATS_results_fdr;
net_path = Fvalues;
mask_path = H;
lc_netplot(net_path,if_add_mask, mask_path, how_disp, if_binary, which_group, net_index_path);
colormap(jet)
caxis([0 14]);
colorbar;
%% Posthoc ttest
% SZ
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_posthoc_szvshc_results_fdr.mat;
axes(ax(2))
net_path = Tvalues;
mask_path = H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(jet)
caxis([-6 4]);
colorbar;
% BD
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_posthoc_bdvshc_results_fdr.mat;
axes(ax(3))
net_path = Tvalues;
mask_path = H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(jet)
caxis([-6 4]);
colorbar;
% MDD
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_posthoc_mddvshc_results_fdr.mat;
axes(ax(4))
net_path = Tvalues;
mask_path = H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(jet)
caxis([-6 4]);
colorbar;
%% shared dysconnectivity
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\mycolormap_state_new;
axes(ax(5))
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_posthoc_szvshc_results_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\shared_1and2and3_fdr.mat';
load (net_path)
lc_netplot(Tvalues,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
% caxis([-6 4]);
colorbar;

