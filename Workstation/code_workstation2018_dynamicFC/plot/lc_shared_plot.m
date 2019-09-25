net_path1='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual';
net_path2='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual';
mask_path = '';
node_name_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V2\Data\Network_and_plot_para\17network_label.xlsx';
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';

figure
[index1,re_net_index1,re_net1] = lc_netplot(Tvalues,1,shared_1and2and3,'all',1,1, net_index_path);
colormap(jet)
% caxis([-6 5]);

figure
lc_circleplot(Tvalues,shared_1and2and3,'only_neg',1,1,0,'',net_index_path,node_name_path)




% save fig
set(gcf,'outerposition',get(0,'screensize'));
% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\shared_all_net.tif')
% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\mddvshc_fdr.tif')

