% This script is used to shared dysconnectivity for validation results (add SES as covariances) 
if_add_mask=1;
how_disp='all';
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%%
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\mycolormap_state_new;
figure
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\dfc_posthoc_szvshc_results_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\results_ancova_posthocttest_validataion_addSES\shared_1and2and3_fdr.mat';
load (net_path)

lc_netplot(Tvalues,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path);
colormap(mymap)

