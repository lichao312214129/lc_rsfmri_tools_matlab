% This was used for validation analyses

% 1 verify the window width (correlate the 17 TRs and 20 TRs)
s1_17='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_1.mat';
s2_17='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_2.mat';
s3_17='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_3.mat';
s4_17='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState17_4\Cluster_4.mat';

s1_20='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState20_4\Cluster_1.mat';
s2_20='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState20_4\Cluster_2.mat';
s3_20='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState20_4\Cluster_3.mat';
s4_20='D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\state\allState20_4\Cluster_4.mat';

s1mat_17=importdata(s1_17);
s2mat_17=importdata(s2_17);
s3mat_17=importdata(s3_17);
s4mat_17=importdata(s4_17);

s1mat_20=importdata(s1_20);
s2mat_20=importdata(s2_20);
s3mat_20=importdata(s3_20);
s4mat_20=importdata(s4_20);


%% plot
corr(s2mat_17(:),a(:))
% plot scatter
plot(s2mat_17(:),a(:),'.');
box off

if issave
    print(gcf,'-dtiff', '-r300',['s1', 'scatter', '.tif'])
end

% input net
net_path1=s2_17;
net_path2=s1_20;
% params
issave=0;
load D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\Mycolormap_state;
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state1\result\h_posthoc_fdr.mat';
if_add_mask=0;
how_disp='all'; % or 'only_neg'
if_binary=0;
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';

% plot net
% 20 TRs
lc_netplot(net_path1,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);
% 17 TRs
lc_netplot(net_path2,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(mymap_state)
caxis([-0.8 0.8]);



% save
if issave
    [~, name] = fileparts(net_path2);
    print(gcf,'-dtiff', '-r300',[name, 'net', '.tiff'])
end
