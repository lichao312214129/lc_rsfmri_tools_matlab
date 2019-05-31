net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\h_ancova_fdr.mat';
if_add_mask=1;
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';

%% plot
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(3,1,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% state1
axes(ha(1)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
load colormap_ancova
colormap(mymap_ancova)
caxis([0 10]);

% state2
axes(ha(2)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
load colormap_ancova
colormap(mymap_ancova)
caxis([0 10]);

% state3
% axes(ha(3)); 
% net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state3\result\fvalue_ancova_fdr.mat';
% mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state3\result\h_ancova_fdr.mat';
% lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)

% state4
axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\fvalue_ancova_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\h_ancova_fdr.mat';
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
load colormap_ancova
colormap(mymap_ancova)
caxis([0 10]);
