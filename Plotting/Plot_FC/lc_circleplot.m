function lc_circleplot(net_path,mask_path,how_disp,if_binary,which_group,if_save,save_name,net_index_path,node_name_path)
% 用途：用circle的形式，画出功能连接矩阵
% input
%   net_path:带路径的功能连接网络文件名
%   mask: 带路径的mask文件名
%   how_disp：显示正还是负
%   only_disp_consistent:是否只显示多组间正负号一致的连接
%   which_group:显示哪一个组
%%
if nargin<1
    net_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\tvalue_posthoc_fdr.mat';
    mask_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all\state4\result\distinct_3_fdr.mat';
    how_disp='all';% or 'only_neg'
    if_binary=1; %二值化处理，正值为1，负值为-1
    which_group=1;
    if_save=0;
    save_name='state4_distinct_3';
    
    % 网络index路径，用于重构功能网络（按照网络的顺序）
    net_index_path='F:\黎超\Workstation_dynamic_fc\Data\Network_and_plot_para\netIndex.mat';
    % 节点名字
    node_name_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\17network_label.xlsx';
    
end

% net
if strcmp(class(net_path),'char')
    net=importdata(net_path);
else 
    net=net_path;
end

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
if numel(size(net))>2
    net=squeeze(net(which_group,:,:));
end

% 二值化网络
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

% 筛选mask（哪一组的mask）
if numel(size(mask))==3
    mask=squeeze(mask(1,:,:));
end

% 求mask内的网络
net=net.*mask;

% 按照网络划分，重新组织net
net_index=importdata(net_index_path);
[index,re_net_index,re_net]=lc_ReorganizeNetForYeo17NetAtlas(net,net_index);

% 节点名字,按照网络重新组织节点名字
[~,node_name]=xlsread(node_name_path);
node_name=node_name(index,3);


% Create custom node labels
myLabel = cell(length(re_net));
[ind_i,ind_j,index_nozero]=find(re_net);
for i = 1:length(myLabel)
    myLabel{i,1} = num2str(index(i));
%     myLabel{i,1} = '';
end
% myLabel=node_name;
% for i=1:length(index_nozero)
%     myLabel{ind_i(i)} =node_name{ind_i(i),2};
%     myLabel{ind_j(i)} =node_name{ind_j(i),2};
% end

% Create custom colormap
color=jet(7); % lines，hsv
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
circularGraph(re_net,'Colormap',myColorMap,'Label',myLabel);

% save
if if_save
%     set(gcf,'outerposition',get(0,'screensize'));
    print(gcf,'-dtiff', '-r300',save_name)
end
end