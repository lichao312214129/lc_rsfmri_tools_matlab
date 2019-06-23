%% plot dynamic network for dfc

% mean fc
% all_dfc_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V1\Data\zDynamic\DynamicFC_length17_step1_screened';
% all_dfc = dir(fullfile(all_dfc_dir, '*.mat'));
% all_dfc_name = {all_dfc.name}';
% all_dfc_path = fullfile(all_dfc_dir, all_dfc_name);
% % load all dfc
% nsub = length(all_dfc_name);
% mean = zeros(114, 114, 174);
% for i = 1:nsub
%     fprintf('%d/%d\n',i, nsub);
% 	tmp = importdata(all_dfc_path{i});
%     mean = mean+tmp;
% end
% mean_all_dfc = mean/nsub;
% save('D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\meandfc.mat','mean_all_dfc');

% save to figure
c = 1;
for i = 1:5:174
    fprintf('%d/%d\n',i, nsub);
	tmp = mean_all_dfc(:,:,i);
    subplot(5,4,c)
    imagesc(tmp);
    colormap(jet)
    axis square
    axis off
    c=c+1;
end

c=var(mean,1,3);
net_path=c;
lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
colormap(gray)
caxis([-0.8 0.8]);
