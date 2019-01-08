function lc_InsertSepLineToNet(reorgNet)
% 此代码的功能：在一个网络矩阵种插入网络分割线，此分割线将不同的脑网络分开
% input
%   net:一个网络矩阵，N*N,N为节点个数，必须为对称矩阵
%   sepIndex:分割线的index，为一个向量，比如[3,9]表示网络分割线分别位于3和9后面

%% input
%     sepIndex=2*[0,5,10,17,28,30,44,57];% Yeo17 net atals
sepIndex=importdata('D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\sepIndex.mat');
if size(reorgNet,1)~=size(reorgNet,2)
    error('不是对称矩阵');
end
%%
% figure
imagesc(reorgNet)
% insert separate line
lc_line(sepIndex,length(reorgNet))
colormap(jet)
axis off
end

function lc_line(sepIndex,nNode)
% nNode:node个数
for i=1:length(sepIndex)
    line([sepIndex(i)+0.5,sepIndex(i)+0.5],[-10,nNode*2],'color','w','LineWidth',1)
    line([0,nNode*2],[sepIndex(i)+0.5,sepIndex(i)+0.5],'color','w','LineWidth',1)
end
end