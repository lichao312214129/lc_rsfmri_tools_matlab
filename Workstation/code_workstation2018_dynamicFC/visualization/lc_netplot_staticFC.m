% This scri  is used to plot networks for static fucntional connectivity

if_add_mask=0;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%%
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\mycolormap_state_new;
figure
% sz
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fdr.mat
subplot(1,4,1); 
net_path=Tvalues;
mask_path=H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-4 4]);

% bd
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_bdvshc_results_fdr.mat
subplot(1,4,2); 
net_path=Tvalues;
mask_path=H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-4 4]);

% mdd
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_mddvshc_results_fdr.mat
subplot(1,4,3)
net_path=Tvalues;
mask_path=H_posthoc;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
caxis([-4 4]);

% shared
subplot(1,4,4)
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\sfc_posthoc_szvshc_results_fdr.mat
net_path=Tvalues;
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_sfc\shared_1and2and3_fdr.mat';
lc_netplot(net_path,1,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)
% caxis([-4 4]);