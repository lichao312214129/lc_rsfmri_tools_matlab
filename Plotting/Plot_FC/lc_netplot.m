function lc_netplot(net_path,if_add_mask,mask_path,how_disp,if_binary,which_group, net_index_path)
% 用途：用circle的形式，画出功能连接矩阵
% input
%   net_path:带路径的功能连接网络文件名
%   mask: 带路径的mask文件名
%   how_disp：显示正还是负
%   which_group:显示哪一个组
%%
%%
if nargin<1
    net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\mean_state1_HC_Avg.txt';
    if_add_mask=0;
    mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\results\shared_1and2and3.mat';
    how_disp='all';% or 'only_neg'
    if_binary=0; %二值化处理，正值为1，负值为-1
    which_group=1;
    
    % 网络index路径，用于重构功能网络（按照网络的顺序）
    net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';
end

% net
net=importdata(net_path);

% 显示正或者负
if strcmp(how_disp,'only_pos')
    net(net<0)=0;%只显示正
elseif strcmp(how_disp,'only_neg')
    net(net>0)=0;%只显示负
elseif strcmp(how_disp,'all')
    disp('正和负都显示')
else
    disp('请指明显示正还是负!')
    return
end

% 显示哪一组
if numel(size(net))==3
    net=squeeze(net(which_group,:,:));
end

% 二值化网络
if if_binary
    net(net<0)=-1;
    net(net>0)=1;
end

% mask
if if_add_mask
    mask=importdata(mask_path);
    
    % 筛选mask（哪一组的mask）
    if numel(size(mask))==3
        mask=squeeze(mask(1,:,:));
    end
    
    % 求mask内的网络
    net=net.*mask;
end
% 按照网络划分，重新组织net
net_index=importdata(net_index_path);
[index,re_net_index,re_net]=lc_ReorganizeNetForYeo17NetAtlas(net,net_index);

% plot
% figure;
lc_InsertSepLineToNet(re_net)
colormap(jet)
axis square

end
