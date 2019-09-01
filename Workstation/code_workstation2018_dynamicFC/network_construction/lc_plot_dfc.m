%% plot test
load Mycolormap_state;
if_save=0;
if_add_mask=0;
mask_path=ones(114)==1;
net_path='ROISignals_00558_resting_Covremoved.mat';
how_disp='all';% or 'only_neg'
if_binary=0; %¶þÖµ»¯´¦Àí£¬ÕýÖµÎª1£¬¸ºÖµÎª-1
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';
lc_netplot(net_path,1,mask_path,how_disp,if_binary,which_group, net_index_path);

ct = 1;
for i = 1: 5: 160
    subplot(6,6,ct)
    lc_netplot(FNCdyn(:,:,i),1,mask_path,how_disp,if_binary,which_group, net_index_path);
%     imagesc(FNCdyn(:,:,i));
    colormap(mymap_state)
    caxis([-0.8 0.8]);
    ct = ct +1;
end