function lc_InsertSepLineToNet(net,network_index, location_of_sep)
% 此代码的功能：在一个网络矩阵种插入网络分割线，此分割线将不同的脑网络分开
% input
%   net:一个网络矩阵，N*N,N为节点个数，必须为对称矩阵
%   network_index: network index of each node.
%   location_of_sep:分割线的index，为一个向量，比如[3,9]表示网络分割线分别位于3和9后面
%% input
if nargin < 3
    % if not given location_of_sep, then generate it using network_index;
    uni_id = unique(network_index);
    location_of_sep = [0; cell2mat(arrayfun( @(id) max(find(network_index == id)), uni_id, 'UniformOutput',false))];
%     sepIndex=importdata('D:\WorkStation_2018\WorkStation_dynamicFC_V2\Data\Network_and_plot_para\sepIndex.mat');
end

if size(net,1)~=size(net,2)
    error('Not a symmetric matrix!\n');
end

%%
% figure
% figure;
imagesc(net)
% insert separate line
lc_line(location_of_sep,length(net))
axis off
end

function lc_line(sepIndex,nNode)
% nNode: node个数
for i=1:length(sepIndex)
    line([sepIndex(i)+0.5,sepIndex(i)+0.5],[-10,nNode*2],'color','k','LineWidth',0.8)
    line([0,nNode*2],[sepIndex(i)+0.5,sepIndex(i)+0.5],'color','k','LineWidth',0.8)
end
end