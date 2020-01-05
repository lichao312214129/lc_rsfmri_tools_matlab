% This scri  is used to plot networks for states derived from factoral analysis (dimensional latent construct with multiple indicators)

if_add_mask=0;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%%
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\mycolormap_state_new;
figure
% state1
subplot(1,2,1); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\test_results\group_centroids_pca_1.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state1\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-1.5 2]);

% state2
subplot(1,2,2); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\test_results\group_centroids_pca_2.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state2\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-1.5 2]);


% static fc
figure
net_path=H';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state2\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-1.5 2]);
