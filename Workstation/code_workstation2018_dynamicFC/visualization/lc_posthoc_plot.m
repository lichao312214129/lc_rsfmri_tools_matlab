net_path1='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual';
net_path2='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual';
mask_path = '';
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';

[index1,re_net_index1,re_net1] = lc_netplot(Tvalues,1,H_posthoc,'all',0,1, net_index_path);
colormap(jet)
caxis([-6 5]);



% save fig
% set(gcf,'outerposition',get(0,'screensize'));
% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\mddvshc_original.tif')
print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\bdvshc_fdr.tif')
