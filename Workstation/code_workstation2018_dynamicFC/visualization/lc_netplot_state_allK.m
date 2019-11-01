%% plot states for k=2,4,5,8
% utf-8
if_add_mask=0;
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
mask_path=[];
net_index_path='D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Network_and_plot_para\netIndex.mat';
load D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Network_and_plot_para\MyColormap_state.mat;
issavefig = 0;


%% K=2
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(1,2,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

axes(ha(1));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_2\Cluster_1.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(2));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_2\Cluster_2.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

if issavefig
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','s2a.tif')
end


%% K=4
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(1,4,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

axes(ha(1));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_1.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(2));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_2.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(3));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_3.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(4));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_4.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

if issavefig
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','s4.tif')
end


%% K=5
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(1,5,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

axes(ha(1));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_1.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(2));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_2.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(3));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_3.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(4));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_4.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(5));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_5\Cluster_5.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

if issavefig
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','s5.tif')
end


%% K=8
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(1,8,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

axes(ha(1));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_1.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(2));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_2.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(3));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_3.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(4));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_4.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(5));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_5.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(6));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_6.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(7));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_7.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

axes(ha(8));
net_path='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_8\Cluster_8.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);

if issavefig
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','s8.tif')
end