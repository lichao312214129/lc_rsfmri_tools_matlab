%% show distinct network for each state

% input
if_binary=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';
node_name_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\17network_label.xlsx';
if_save=0;
save_name='';
how_disp='all';% or 'only_neg'

% plot
figure
set(gcf,'outerposition',get(0,'screensize'));
ha = tight_subplot(3,3,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% state 1£¨According to the order:SZ--BD--MDD for all states£©
axes(ha(1)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\distinct_1_fdr.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(2)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\distinct_2_fdr.mat';
which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\distinct_3_fdr.mat';
which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)


% state 2
axes(ha(4)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\distinct_1_fdr.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(5)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\distinct_2_fdr.mat';
which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(6)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\distinct_3_fdr.mat';
which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)


% state 4
axes(ha(7)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\distinct_1_fdr.mat';
which_group=1;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(8)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\distinct_2_fdr.mat';
which_group=2;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

axes(ha(9)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\distinct_3_fdr.mat';
which_group=3;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)

% set the background to black
set(gcf,'color','k');
set(ha(1:4),'XTickLabel',''); 
set(ha,'YTickLabel','')

% save
if if_save
    set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\figure\shared_all3.tiff')
end