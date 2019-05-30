%% Circular Graph Examples
% Copyright 2016 The MathWorks, Inc.

%% 1. Adjacency matrix of 1s and 0s
% Create an example adjacency matrix made up of ones and zeros.
% rng(0);
% x = rand(50);
% thresh = 0.93;
% x(x >  thresh) = 1;
% x(x <= thresh) = 0;
% 
% %%
% % Call CIRCULARGRAPH with only the adjacency matrix as an argument.
% circularGraph(x);

%%
% Click on a node to make the connections that emanate from it more visible
% or less visible. Click on the 'Show All' button to make all nodes and
% their connections visible. Click on the 'Hide All' button to make all
% nodes and their connections less visible.

%% 2. Supply custom properties
% Create an example adjacency matrix made up of various values and supply
% custom properties.
% rng(0);
% x = rand(20);
% thresh = 0.93;
% x(x >  thresh) = 1;
% x(x <= thresh) = 0;
% for i = 1:numel(x)
%   if x(i) > 0
%     x(i) = rand(1,1);
%   end
% end

%%
% input
mat_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\results\F_ancova.mat';
mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\results\h_fdr_ancova.mat';
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';

%
mat=importdata(mat_path);
mask=importdata(mask_path);
net_index=importdata(net_index_path);
mat_in_mask=mat.*mask;

% 按照网络划分，重新组织mat
[index,sortedNetIndex,re_net]=lc_ReorganizeNetForYeo17NetAtlas(mat_in_mask,net_index);



% Create custom node labels
myLabel = cell(length(re_net));
for i = 1:length(myLabel)
  myLabel{i} = '';
end

% Create custom colormap
figure;
% lines，hsv
color=lines(7);
for i=1:114
     myColorMap(i,:)=color(re_net_index(i),:);
end

circularGraph(re_net,'Colormap',myColorMap,'Label',myLabel);
