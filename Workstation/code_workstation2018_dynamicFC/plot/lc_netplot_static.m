%% 画各个组各个状态的均值网络
% 计算net均值
% in_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\MDD';
% out_name='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\static_MDD_Avg';
% if_save=1;
% average_edge = lc_calc_average(in_path,if_save,out_name);


% input
net_path_hc_state1='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\F_ancova.mat';
net_path_hc_state2='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\pvalue_posthoc.mat';
net_path_hc_state3='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\pvalue_posthoc.mat';
net_path_hc_state4='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\pvalue_posthoc.mat';
if_save=0;
if_add_mask=0;
% 

mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\h_fdr_ancova.mat';
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';

% plot
load Mycolormap_state;
subplot(1,4,1)
lc_netplot(net_path_hc_state1,1,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);
% colorbar

subplot(1,4,2)
lc_netplot(net_path_hc_state2,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8])
% colorbar
% 
subplot(1,4,3)
lc_netplot(net_path_hc_state3,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8])
% colorbar


subplot(1,4,4)
lc_netplot(net_path_hc_state4,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8])
% colorbar


% save
if if_save
    set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300','colormap.tiff')
    
    % save colormap
%     ax = gca;
%     mymap = colormap(ax);
%     save('MyColormap','mymap');
end

%% =================================================================
%% 画各个状态组间对比后的网络

% t值和p值的文件
tvalue_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\tvalue_posthoc.mat';
pvalue_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zStatic\results\pvalue_posthoc.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\h_posthoc_fdr.mat';
if_save=0;

% 加载t值和p值
tvalue=importdata(tvalue_path);
pvalue=importdata(pvalue_path);

% 将t值和p值转换
trans_value=-sign(tvalue).*log(pvalue);
trans_value(isnan(trans_value))=0;


% 画图
net_path=trans_value;
if_add_mask=0;
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';


figure
load MyColormap_for_group_dif
subplot(1,3,1)
which_group=1;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-10 10])
% colorbar

subplot(1,3,2)
which_group=2;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-10 10])
% colorbar


subplot(1,3,3)
which_group=3;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-10 10])
% colorbar


% save
if if_save
    set(gcf,'outerposition',get(0,'screensize'));
    saveas(gcf,'state3_group_dif_1.tiff');
%     print(gcf,'-dtiff', '-r300','state3_group_dif10.tiff')
end
