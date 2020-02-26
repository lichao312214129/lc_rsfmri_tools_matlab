function lc_netplot(net, if_add_mask, mask, how_disp, if_binary, which_group, net_index, is_legend, legends)
% PURPOSE: plot functional connectivity network using grid format. 
% NOTO: This function will automatically sort network according to net_index.
% Parameters:
% -----------
%   net: path str | .mat matrix
%        Functional connectivity network that needs to be plotted.
%   if_add_mask: int, 0 or 1
%        If add mask to net for filtering.
%   mask: path str | .mat matrix
%        Mask that used to filter the net.
%   how_disp: str:: 'only_neg', 'only_pos' or 'all'
%        how display the network
%   if_binary: int, 0 or 1
%        If binary the network.
%   which_group: int
%        If the network .mat file has multiple 2D matrix, then choose which one to display.
%   net_index: path str | .mat vector
%        network index, each node has a net_index indicating its network index.
%   is_legend: int
%       If show legend.
%   legends: cell
%       legends of each network.
%% -----------------------------------------------------------------
% net
if isa(net, 'char')
    net=importdata(net);
else
    net=net;
end

% show postive and/or negative
if strcmp(how_disp,'only_pos')
    net(net<0)=0;
elseif strcmp(how_disp,'only_neg')
    net(net>0)=0;
elseif strcmp(how_disp,'all')
    disp('show both postive and negative')
else
    disp('Did not specify show positive or negative!')
    return
end

% when matrix is 3D, show which (the 3ith dimension)
if numel(size(net))==3
    %     net=squeeze(net(which_group,:,:));
    net=squeeze(net(:,:,which_group));
end

% transfer the weighted matrix to binary
if if_binary
    net(net<0)=-1;
    net(net>0)=1;
end

% mask
if if_add_mask
    if isa(mask, 'char')
        mask=importdata(mask);
    else
        mask=mask;
    end
    
    % when mask is 3D, show which (the 3ith dimension)
    if numel(size(mask))==3
        mask=squeeze(mask(which_group,:,:));
    end
    
    % extract data in mask
    net=net.*mask;
end

% sort the matrix according to network index
net_index=importdata(net_index);
[index,re_net_index,re_net]=lc_ReorganizeNetForYeo17NetAtlas(net,net_index);

% plot: insert separate line between each network
lc_InsertSepLineToNet(re_net, re_net_index, 0.4, is_legend, legends);
% axis square
end

function lc_InsertSepLineToNet(net, re_net_index, linewidth, is_legend, legends)
% 此代码的功能：在一个网络矩阵种插入网络分割线，以及bar
% 此分割线将不同的脑网络分开
% 不同颜色的区域，代表一个不同的网络
% input
%   net:一个网络矩阵，N*N,N为节点个数，必须为对称矩阵
%   network_index: network index of each node.
%   location_of_sep:分割线的index，为一个向量，比如[3,9]表示网络分割线分别位于3和9后面
%% input
% if not given location_of_sep, then generate it using network_index;
uni_id = unique(re_net_index);
location_of_sep = [0; cell2mat(arrayfun( @(id) max(find(re_net_index == id)), uni_id, 'UniformOutput',false))];

if size(net,1)~=size(net,2)
    error('Not a symmetric matrix!\n');
end

%%
n_node = length(net);
imagesc(net);
% insert separate line
lc_line(location_of_sep, n_node, linewidth);
hold on;
% bar region
extend = n_node / 10;
xlim([0, n_node + extend]);
ylim([0, n_node + extend]);
lc_bar_region_of_each_network(location_of_sep, n_node, extend, is_legend, legends);
axis off
end

function lc_line(sepIndex, n_node, linewidth)
% nNode: node个数
n_net = length(sepIndex);
for i=1:n_net
    if (i == 1) || (i == n_net)
        % Y
        line([sepIndex(i), sepIndex(i)],[0, n_node],'color','k','LineWidth',linewidth);
        % X
        line([0, n_node],[sepIndex(i), sepIndex(i)],'color','k','LineWidth',linewidth)
    else
        % Y
        line([sepIndex(i) + 0.5, sepIndex(i) + 0.5],[0, n_node],'color','k','LineWidth',linewidth);
        % X
        line([0, n_node],[sepIndex(i) + 0.5, sepIndex(i) + 0.5],'color','k','LineWidth',linewidth)
    end
    
end
end

function lc_bar_region_of_each_network(location_of_sep, n_node, extend, is_legend, legends)
% TO plot bar with sevral regions, each region with a unique color
% representting a network.
n_net = length(location_of_sep);
randseed(1);
color = jet(n_net) / 1.1;
barwidth = abs((n_node + extend / 2) - (n_node+extend));
extend_of_legends = extend + 4 ;
h = zeros(n_net - 1, 1);
for i = 1 : n_net-1
    h(i) = fill([location_of_sep(i), location_of_sep(i+1), location_of_sep(i+1), location_of_sep(i)], [n_node + extend / 2, n_node + extend / 2, n_node+extend n_node + extend], color(i,:));
    fill([ n_node + barwidth, n_node + barwidth, n_node + extend, n_node + extend], [location_of_sep(i), location_of_sep(i+1), location_of_sep(i+1), location_of_sep(i)], color(i,:))
    if is_legend
        % Y axix
        text(n_node + extend_of_legends, (location_of_sep(i+1) - location_of_sep(i)) / 2 +  location_of_sep(i),...
            legends{i}, 'fontsize', 5, 'rotation', 0);
         % X axix
        text((location_of_sep(i+1) - location_of_sep(i)) / 2 +  location_of_sep(i), n_node + extend_of_legends,...
            legends{i}, 'fontsize', 5, 'rotation', -90);
    end
end
end