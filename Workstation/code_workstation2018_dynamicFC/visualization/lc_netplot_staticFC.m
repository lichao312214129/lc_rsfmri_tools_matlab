% This scri  is used to plot networks for static fucntional connectivity
if_add_mask=0;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%% -----------------------ACOVA--------------------------------------
% figure
% load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\colormap_ancova;
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_STATS_results_fdr.mat
% net_path=Fvalues;
% mask_path=H;
% lc_netplot(net_path,1,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap_ancova)
% title('SZ - HC')
% 
% %% -----------------------FDR--------------------------------------
% figure
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\mycolormap_state_new;
% ax = tight_subplot(2,2,[0.05 0.05],[0.05 0.05],[0.01 0.01]);
% % sz
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fdr.mat
% axes(ax(1)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('SZ - HC')
% % colorbar
% 
% % bd
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_bdvshc_results_fdr.mat
% axes(ax(2)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('BD - HC')
% 
% % mdd
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_mddvshc_results_fdr.mat
% axes(ax(3)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('MDD - HC')
% 
% % shared
% axes(ax(4)) 
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fdr.mat
% net_path=Tvalues;
% mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
% lc_netplot(net_path,1,mask_path,how_disp,1,which_group, net_index_path);
% colormap(mymap)
% title('Shared')
% % caxis([-4 4]);
% 
% %% -----------------------FWE--------------------------------------
% figure
% ax = tight_subplot(2,2,[0.05 0.05],[0.05 0.05],[0.01 0.01]);
% % sz
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fwe.mat
% axes(ax(1)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('SZ - HC')
% % colorbar
% 
% % bd
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_bdvshc_results_fwe.mat
% axes(ax(2)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('BD - HC')
% 
% % mdd
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_mddvshc_results_fwe.mat
% axes(ax(3)) 
% net_path=Tvalues;
% mask_path=H_posthoc;
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
% colormap(mymap)
% caxis([-4 4]);
% title('MDD - HC')
% 
% % shared
% axes(ax(4)) 
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fwe.mat
% net_path=Tvalues;
% mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
% lc_netplot(net_path,1,mask_path,how_disp,1,which_group, net_index_path);
% colormap(mymap)
% title('Shared')
% % caxis([-4 4]);
% 
% % Mean FC
% figure
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\mean_static_fc.mat;
% net_path=mean_mat;
% mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
% lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
% colormap(mymap)
% % caxis([-0.4 0.8]);
% title('Mean FC')
% 
% % Median FC
% figure
% load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\median_mat.mat;
% net_path=median_mat;
% mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
% lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
% colormap(mymap)
% % caxis([-0.4 0.8]);
% title('median_mat')



%% Factors
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V2_revision\mycmap_fractor
figure
% facor1
subplot(1,2,1)
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V2_revision\frator_1.mat;
net_path=square_median_mat;
net_path(eye(length(net_path))==1) =0;
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
colormap(mycmap_fractor)
caxis([-1 2]);
title('Factor1')

% facor2
subplot(1,2,2)
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V2_revision\frator_2.mat;
net_path=square_median_mat;
net_path(eye(length(net_path))==1) =0;
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
colormap(mycmap_fractor)
caxis([-1 2]);
title('Factor2')

