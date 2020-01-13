%% This scri  is used to plot networks for static fucntional connectivity
if_add_mask=0;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat'; % Not for mask
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc_heldOutSamples\cmp_state;
%%
figure
% state 1
subplot(1,2,1)
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc_heldOutSamples\group_centroids_2.mat;
net_path=square_median_mat;
net_path(eye(length(net_path))==1) =0;
lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
colormap(cmp_state)
caxis([-0.4 0.8]);
set(get(colorbar,'label'),'string','Correlations (Z)','fontsize',15)
title('State 1','fontsize',15)

% state 2
subplot(1,2,2)
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc_heldOutSamples\group_centroids_1.mat;
net_path=square_median_mat;
net_path(eye(length(net_path))==1) =0;
lc_netplot(net_path,0,mask_path,how_disp,0,which_group, net_index_path);
colormap(cmp_state)
caxis([-0.4 0.8]);
set(get(colorbar,'label'),'string','Correlations (Z)','fontsize',15)
title('State 2','fontsize',15)

%%
print(gcf,'-dtiff', '-r600','States_of_heldOutSamples.tif')

