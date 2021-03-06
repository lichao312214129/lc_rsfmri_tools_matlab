%% show shared network for static FC

% input
if_binary=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';
node_name_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\17network_label.xlsx';
if_save=0;
save_name='';
how_disp='all';% or 'only_neg'

%% plot
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(3,4,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% shared
axes(ha(1)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\shared_1and2and3.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(2)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\shared_1and2.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\shared_1and3.mat';
which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(4)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\shared_2and3.mat';
which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)


% distinct
axes(ha(5)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\distinct_1.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(6)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\distinct_2.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(7)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\distinct_3.mat';
which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(8)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\shared_2and3.mat';
which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

% set the backgroud to black
set(gcf,'color','k');
set(ha(1:4),'XTickLabel',''); 
set(ha,'YTickLabel','')

% save
if if_save
    set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\figure\shared_all3.tiff')
end