% plot shared dynamic fc

%% input
if_binary = 1; % transfer weighted matrix to binary 
how_disp = 'all';% or 'only_neg'
net_index_path = 'F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Network_and_plot_para\netIndex.mat';
node_name_path = 'F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Network_and_plot_para\17network_label.xlsx';
which_group = 1;
if_save_subfigure = 0;
save_name = '';
if_save_wholefigure = 0;
savename = 'D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\figure\shared_all3.tiff';

%% begain plot
figure
set(gcf,'Position',get(0,'ScreenSize'))
ha = tight_subplot(3,4,[0.05 0.01],[0.01 0.01],[0.01 0.01]);

% state 1
axes(ha(1)); 
net_path='F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Dynamic\state1\tvalue_posthoc_fdr.mat';
mask_path='F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Dynamic\state1\result1\shared_1and2_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(2)); 
net_path='F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Dynamic\state1\tvalue_posthoc_fdr.mat';
mask_path='F:\¿Ë≥¨\Workstation_dynamic_fc\Data\Dynamic\state1\shared_1and2_fdr.mat';

lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(3)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\shared_1and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(4)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\shared_2and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)


% state 2
axes(ha(5)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and2and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(6)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and2_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(7)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_1and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(8)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state2\result\shared_2and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)


% state 4
axes(ha(9)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and2and3_fdr.mat';;
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(10)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and2_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(11)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_1and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

axes(ha(12)); 
net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\shared_2and3_fdr.mat';
lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save_subfigure,save_name,net_index_path,node_name_path)

%%  set background to black
set(gcf,'color','k');
set(ha(1:4),'XTickLabel',''); 
set(ha,'YTickLabel','')

%% save
if if_save_wholefigure
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300',savename)
end