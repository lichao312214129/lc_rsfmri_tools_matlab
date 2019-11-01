function lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)
% Purpose: show a network in a circle format.
% input
%   net_path: network file path
%   mask_path: mask file path
%   how_disp: how to display, only positive OR only negative OR both positive and negative
%   if_binary: if binary the network
%   which_group: if the network data is 3-D, then display which group.
%   if_save: if save the results
%   save_name: output name
%   net_index_path: each node's network index
%   node_name_path: files of nodes' name  % TODO
%   only_disp_consistent: if only display those edges with same signs.
%%
if nargin<1
    net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
    mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\distinct_3_fdr.mat';
    how_disp='all'; 
    if_binary=1; % if binary
    which_group=1;
    if_save=0;
    save_name='state4_distinct_3';
    
    % nodes' network index
    net_index_path='F:\Àè³¬\Workstation_dynamic_fc\Data\Network_and_plot_para\netIndex.mat';
    % node name
    node_name_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\17network_label.xlsx';
    
end

% net
if strcmp(class(net_path),'char')
    net=importdata(net_path);
else 
    net=net_path;
end

% how_disp
if strcmp(how_disp,'only_pos')
    disp('show only positive edges')
    net(net<0)=0;
elseif strcmp(how_disp,'only_neg')
    disp('show only negative edges')
    net(net>0)=0;
elseif strcmp(how_disp,'all')
    disp('show both positive and negative edges')
else
    disp('specify how to display?')
    return
end


% which_group
if numel(size(net))>2
    net=squeeze(net(which_group,:,:));
end

% binary
if if_binary
    net(net<0)=-1;
    net(net>0)=1;
end

% mask
if strcmp(class(mask_path),'char')
    mask=importdata(mask_path);
else
    mask=mask_path; 
end

% which mask
if numel(size(mask))==3
    mask=squeeze(mask(1,:,:));
end

% mask filtering
net=net.*mask;

% re-organize edges acording to nodes' network index.
net_index=importdata(net_index_path);
[index,re_net_index,re_net]=lc_ReorganizeNetForYeo17NetAtlas(net,net_index);

% node name
[~,node_name]=xlsread(node_name_path);
node_name=node_name(index,3);


% Create custom node labels
myLabel = cell(length(re_net));
[ind_i,ind_j,index_nozero]=find(re_net);
for i = 1:length(myLabel)
    myLabel{i,1} = num2str(index(i));
end


% Create custom colormap
% TODO
color=jet(7); % lines£¬hsv
color(color==1)=color(color==1)-0.3;
color(color==0)=color(color==0)+0.2;
color(2,:)=[1 0 1];
color1=color(7,:);
color(7,:)=[0.67 0 0.8];
color(1,:)=color1;
for i=1:114
    myColorMap(i,:)=color(re_net_index(i),:);
end

% plot circle
% figure;
circularGraph_lc(re_net,'Colormap',myColorMap,'Label',myLabel);

% save
if if_save
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300',save_name)
end
end