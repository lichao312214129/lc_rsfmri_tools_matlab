% Used to plot Fvalues map
load D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\dfc_ancova_results_fdr.mat
mask_path = '';
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';


% identify colorbar limit
max1 = max(Fvalues(:));
min1 = min(Fvalues(:));
% Fvalues(H==0)=0;

figure
[index1,re_net_index1,re_net1] = lc_netplot(Fvalues,1,H,'all',0,1, net_index_path);
colormap(jet)
% caxis([0 10]);


% save fig
set(gcf,'outerposition',get(0,'screensize'));
print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\Fvalues_v1.tif')

% internetwork connectivity strength
% netid = 6;
% net_vis1 = re_net1(re_net_index1==netid,re_net_index1==netid);
% mean(net_vis1(:));
% 
% net_vis2 = re_net2(re_net_index2==netid,re_net_index2==netid);
% mean(net_vis2(:));