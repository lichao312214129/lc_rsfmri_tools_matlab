% utf-8
if_add_mask=1;
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
net_index_path='D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Network_and_plot_para\netIndex.mat';

%% plot
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(2,3,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% state1
axes(ha(1)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state1\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state1\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_ancova)
caxis([0 10]);

% state2
axes(ha(2)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state2\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state2\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_ancova)
caxis([0 10]);

% state3
axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state3\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state3\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_ancova)
caxis([0 10]);

% state4
axes(ha(4)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state4\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state4\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_ancova)
caxis([0 10]);


% state5
axes(ha(5)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state5\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state5\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_ancova)
caxis([0 10]);


if_add_mask=0;
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_1.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\state5_all\state1\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
load D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Network_and_plot_para\MyColormap_state.mat
colormap(mymap_state)
caxis([-0.8 0.8]);