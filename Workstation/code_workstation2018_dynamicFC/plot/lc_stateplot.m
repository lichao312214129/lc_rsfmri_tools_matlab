net_path1='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\group_centroids_1.mat';
net_path2='D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\group_centroids_2.mat';
mask_path = '';
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\MyColormap_state.mat;
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';


% identify colorbar limit
net1 = importdata(net_path1);
net1(eye(114)==1) = 0;
max1 = max(net1(:));
min1 = min(net1(:));

net2 = importdata(net_path2);
net2(eye(114)==1) = 0;
max2 = max(net2(:));
min2 = min(net2(:));

subplot(1,2,1)
[index1,re_net_index1,re_net1] = lc_netplot(net1,0,mask_path,'all',0,1, net_index_path);
colormap(jet)
% caxis([-0.5 0.8]);

subplot(1,2,2)
[index2,re_net_index2,re_net2] = lc_netplot(net2,0,mask_path,'all',0,1, net_index_path);
colormap(jet)
% caxis([-0.5 0.8]);

% save fig
set(gcf,'outerposition',get(0,'screensize'));
% print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results_cluster\figure\state3.tif')

% internetwork connectivity strength
% netid = 6;
% net_vis1 = re_net1(re_net_index1==netid,re_net_index1==netid);
% mean(net_vis1(:));
% 
% net_vis2 = re_net2(re_net_index2==netid,re_net_index2==netid);
% mean(net_vis2(:));