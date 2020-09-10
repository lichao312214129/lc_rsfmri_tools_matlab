function lc_netplot(varargin)
% LC_NETPLOT
% PURPOSE: plot functional connectivity network using grid format. 
% NOTO: This function will automatically sort network according to net_index.
% This code used brewermap.
% Thank brewermap.
% Parameters:
% -----------
%   REQUIRED:
%       [--net, -n]: path str | .mat matrix
%           Functional connectivity network that needs to be plotted.
%       [--net_index, -ni]: path str | .mat vector
%           network index, each node has a net_index indicating its network index
%   OPTIONAL:
%      [--if_add_mask, -iam]: int, 0 or 1
%           If add mask to net for filtering.
%      [--mask, -m]: path str | .mat matrix
%           Mask that used to filter the net.
%      [--how_disp, -hd]: str:: 'only_neg', 'only_pos' or 'all'
%           how display the network
%      [--if_binary, -ib]: int, 0 or 1
%           If binary the network.
%      [--which_group, -wg]: int
%           If the network .mat file has multiple 2D matrix, then choose which one to display.
%      [--thred_for_gen_new_net, -thred]: int
%           The threshold for generating new net for plot (insert zeros into network), default=100
%      [--linewidth, -lw]: float 
%           separation line width
%      [--linecolor, -lc]: color string 
%           separation line color
%      [--is_legend, -il]: int
%          If show legend.
%      [--legends, -lg]: cell
%          legends of each network.
%      [--legend_fontsize, -lgf]: float
%          fontsize of the legends
%      [--legend_color_scheme, -lcs]: the legend color scheme (see BrewerMap for details)
%   
% EXAMPLE 1:
% figure('Position',[100 100 300 300]);
% lc_netplot('-n', './toy_data/sub001.mat', '-ni',  './toy_data/netIndex.mat');
% axis square  % 让图片变成方形，增加美观度
% colormap(jet);  
% cb = colorbar('horiz','position',[0.22 0.1 0.5 0.02]); % 显示colorbar
% caxis([-1,1]);  % 设置图片的显示范围，此处范围为-1 到 1.
% ylabel(cb,'Functional connectivity (Z)', 'FontSize', 8);  % 设置colorbar的title
% saveas(gcf,fullfile('toy_data', 'functional_connectivity.pdf'));  % 保存为pdf格式，保留高清的图片信息，后续可以用PS来保存为tiff
% % matlab显示出来的图像，可能部分超出图片范围，但是没有关系。因为，保存的pdf图片是完整的。保存的图片请见./toy_data./functional_connectivity.pdf
% 
% EXAMPLE 2:
% % 用不同的颜色表示不同的网络，因为我用的是yeo 7网络模板，所以应该有七个legend。
% legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};
% figure('Position',[100 100 300 300]);
% lc_netplot('-n', './toy_data/sub001.mat', '-ni',  './toy_data/netIndex.mat','-il',1, '-lg', legends);
% axis square  % 让图片变成方形，增加美观度
% colormap(jet);  
% % 显示colorbar，由于增加网络legends, 我们讲colorba显示在左侧，后面可以用PS讲colorbar移动到其他地方
% cb = colorbar('position',[0.1 0.2 0.02 0.5]); 
% caxis([-1,1]);  % 设置图片的显示范围，此处范围为-1 到 1.
% ylabel(cb,'Functional connectivity (Z)', 'FontSize', 10);  % 设置colorbar的title
% saveas(gcf,fullfile('toy_data', 'functional_connectivity_add_network_legends.pdf'));  % 保存为pdf格式，保留高清的图片信息，后续可以用PS来保存为tiff
% % matlab显示出来的图像，可能部分超出图片范围，但是没有关系。因为，保存的pdf图片是完整的。保存的图片请见./toy_data./functional_connectivity_add_network_legends.pdf
% 
% AUTHOR: Li Chao
% EMAIL: lichao19870617@gmail.com, lichao19870617@163.com
% If you use this code, please cite it.

if nargin == 0
    help lc_netplot
    return;
end

[net, if_add_mask, mask, how_disp, if_binary, which_group, thred_for_gen_new_net, net_index, linewidth, linecolor, is_legend, legends, legend_fontsize, legend_color_scheme] = ...
            parseInputs(varargin{:});

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
%     disp('show both postive and negative')
else
%     disp('Did not specify show positive or negative!')
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

% Sort the matrix according to network index
if ischar(net_index)
    net_index=importdata(net_index);
end
net_index = reshape(net_index,[],1);
[re_net_index,index] = sort(net_index);
re_net = net(index,index);

% plot: insert separate line between each network
lc_InsertSepLineToNet(re_net, re_net_index, thred_for_gen_new_net, linewidth, linecolor, is_legend, legends, legend_fontsize, legend_color_scheme);
end

function [net, if_add_mask, mask, how_disp, if_binary, which_group, thred_for_gen_new_net, net_index, linewidth, linecolor, is_legend, legends, legend_fontsize, legend_color_scheme] = ...
            parseInputs(varargin)
% Varargin parser

% Initialize
if_add_mask = 0;
mask = '';
how_disp='all';
if_binary=0;
which_group=1;
thred_for_gen_new_net = 100;
linewidth = 0.5;
linecolor = 'k';
is_legend = 0;
legends = '';
legend_fontsize = 10;
legend_color_scheme = 'Spectral';

if( sum(or(strcmpi(varargin,'--net'),strcmpi(varargin,'-n')))==1)
    net = varargin{find(or(strcmpi(varargin,'--net'),strcmp(varargin,'-n')))+1};
else
    error('Please specify net!');
end

if( sum(or(strcmpi(varargin,'--if_add_mask'),strcmpi(varargin,'-iam')))==1)
    if_add_mask = varargin{find(or(strcmpi(varargin,'--if_add_mask'),strcmp(varargin,'-iam')))+1};
end

if( sum(or(strcmpi(varargin,'--mask'),strcmpi(varargin,'-m')))==1)
    mask = varargin{find(or(strcmpi(varargin,'--mask'),strcmp(varargin,'-m')))+1};
end

if( sum(or(strcmpi(varargin,'--how_disp'),strcmpi(varargin,'-hd')))==1)
    how_disp = varargin{find(or(strcmpi(varargin,'--how_disp'),strcmp(varargin,'-hd')))+1};
end

if( sum(or(strcmpi(varargin,'--if_binary'),strcmpi(varargin,'-ib')))==1)
    if_binary = varargin{find(or(strcmpi(varargin,'--if_binary'),strcmp(varargin,'-ib')))+1};
end

if( sum(or(strcmpi(varargin,'--which_group'),strcmpi(varargin,'-wg')))==1)
    which_group = varargin{find(or(strcmpi(varargin,'--which_group'),strcmp(varargin,'-wg')))+1};
end

if( sum(or(strcmpi(varargin,'--thred_for_gen_new_net'),strcmpi(varargin,'-thred')))==1)
    thred_for_gen_new_net = varargin{find(or(strcmpi(varargin,'--thred_for_gen_new_net'),strcmp(varargin,'-thred')))+1};
end

if( sum(or(strcmpi(varargin,'--net_index'),strcmpi(varargin,'-ni')))==1)
    net_index = varargin{find(or(strcmpi(varargin,'--net_index'),strcmp(varargin,'-ni')))+1};
end

if( sum(or(strcmpi(varargin,'--linewidth'),strcmpi(varargin,'-lw')))==1)
    linewidth = varargin{find(or(strcmpi(varargin,'--linewidth'),strcmp(varargin,'-lw')))+1};
end

if( sum(or(strcmpi(varargin,'--linecolor'),strcmpi(varargin,'-lc')))==1)
    linecolor = varargin{find(or(strcmpi(varargin,'--linecolor'),strcmp(varargin,'-lc')))+1};
end

if( sum(or(strcmpi(varargin,'--is_legend'),strcmpi(varargin,'-il')))==1)
    is_legend = varargin{find(or(strcmpi(varargin,'--is_legend'),strcmp(varargin,'-il')))+1};
end

if( sum(or(strcmpi(varargin,'--legends'),strcmpi(varargin,'-lg')))==1)
   legends = varargin{find(or(strcmpi(varargin,'--legends'),strcmp(varargin,'-lg')))+1};
end

if( sum(or(strcmpi(varargin,'--legend_fontsize'),strcmpi(varargin,'-lgf')))==1)
   legend_fontsize = varargin{find(or(strcmpi(varargin,'--legend_fontsize'),strcmp(varargin,'-lgf')))+1};
end

if( sum(or(strcmpi(varargin,'--legend_color_scheme'),strcmpi(varargin,'-lcs')))==1)
   legend_color_scheme = varargin{find(or(strcmpi(varargin,'--legend_color_scheme'),strcmp(varargin,'-lcs')))+1};
end

end

function [index,sortedNetIndex,reorgNet]=lc_sort_network(net,netIndex)
% 将Yeo17网络模板分离的脑网络的边，整合到相邻的网络内
% input:
%   net:一个对称的相关矩阵
%   netIndex:网络中每个节点的网络index，例如Yeo的17网络模板对应由114个脑区，那么每个脑区对应到一个网络
%   那么对应的那个网络的index即为此index
% output:
%   index:排序后的网络在原始网络中的index
%   sortedNetIndex: 排序后网络的顺序
%   reorgNet:排序后的网络
%% fetch netIndex
% 以后netIndex 时，直接load

if nargin<2
    netIndex=importdata('D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat');
end

[sortedNetIndex,index]=sort(netIndex);
reorgNet=net(index,index);
end

function lc_InsertSepLineToNet(net, re_net_index, thred_for_gen_new_net, linewidth, linecolor, is_legend, legends, legend_fontsize, legend_color_scheme)
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

%% Gen new sep line and new network
n_node = length(net);
% New sep
num_sep = numel(location_of_sep);
location_of_sep_new = location_of_sep;

if length(net) > thred_for_gen_new_net  % Only greater than 50 node, than generate new network matrix
    for i =  1 : num_sep
        location_of_sep_new(i:end) = location_of_sep_new(i:end) + 1;
    end
    % New network
    net_insert_line = zeros(n_node + num_sep, n_node + num_sep);
    for i = 1:num_sep-1
        % Rows iteration
        start_point =  location_of_sep_new(i) + 1;
        end_point = location_of_sep_new(i+1) - 1;
        start_point_old =  location_of_sep(i) + 1;
        end_point_old = location_of_sep(i+1);
        % Columns iteration
        for j = 1 : num_sep - 1
            start_point_j =  location_of_sep_new(j) + 1;
            end_point_j = location_of_sep_new(j+1) - 1;
            start_point_old_j =  location_of_sep(j) + 1;
            end_point_old_j = location_of_sep(j+1);
            net_insert_line(start_point : end_point, start_point_j : end_point_j) = ...
                        net(start_point_old : end_point_old, start_point_old_j : end_point_old_j);
        end
    end
else
    net_insert_line = net;
end

imagesc(net_insert_line); hold on;
x = repmat(location_of_sep_new', num_sep ,1);
y = repmat(location_of_sep_new,1, num_sep);

if length(net) <= thred_for_gen_new_net
    x = x + 0.5;
    y = y + 0.5;
end
z = zeros(size(x));
mesh(x,y,z,...
    'EdgeColor',linecolor,...
    'FaceAlpha',0,...
    'LineWidth',linewidth);
view(2);
grid off
% lc_line(location_of_sep, n_node, linewidth, linecolor);
hold on;
% bar region
n_node_new = length(net_insert_line);
extend = n_node_new / 10;
xlim([0.5-extend, n_node_new+extend+0.5]);
ylim([0.5-extend, n_node_new+extend+0.5]);
% location_of_sep_new = location_of_sep_new + extend - 0.5;
lc_bar_region_of_each_network(location_of_sep_new, n_node_new, extend, is_legend, legends, legend_fontsize, legend_color_scheme);
axis off
end

function lc_bar_region_of_each_network(location_of_sep, n_node, extend, is_legend, legends, legend_fontsize, legend_color_scheme)
% To plot bar with sevral regions, each region with a unique color
% representting a network.
n_net = length(location_of_sep);
location_of_sep = location_of_sep + 0.5;
randseed(1);
color = brewermap(n_net, legend_color_scheme);
width_of_legends = extend/2;
h = zeros(n_net - 1, 1);
for i = 1 : n_net-1
     if is_legend
        % X axix
        y1 = location_of_sep(end) + extend/2;
        y2 = y1 + width_of_legends;
        h(i) = fill([location_of_sep(i), location_of_sep(i+1), location_of_sep(i+1), location_of_sep(i)], [y1,y1,y2,y2], color(i,:));
        
        % Y axix
        x1 = location_of_sep(end) + extend/2;
        x2 = x1 + width_of_legends;
        fill([x1,x1,x2,x2 ], [location_of_sep(i), location_of_sep(i+1), location_of_sep(i+1), location_of_sep(i)], color(i,:))
   
        % Y axix
        little_sep = extend/10;
        text(y2 + little_sep, (location_of_sep(i+1) - location_of_sep(i)) / 2 +  location_of_sep(i),...
            legends{i}, 'fontsize', legend_fontsize, 'rotation', 0);
         % X axix
        text((location_of_sep(i+1) - location_of_sep(i)) / 2 +  location_of_sep(i), x2 + little_sep,...
            legends{i}, 'fontsize', legend_fontsize, 'rotation', -90);
    end
end
end

function [map,num,typ] = brewermap(N,scheme)
% The complete selection of ColorBrewer colorschemes (RGB colormaps).
%
% (c) 2014 Stephen Cobeldick
%
% Returns any RGB colormap from the ColorBrewer colorschemes, especially
% intended for mapping and plots with attractive, distinguishable colors.
%
%%% Syntax (basic):
%  map = brewermap(N,scheme); % Select colormap length, select any colorscheme.
%  brewermap('plot')          % View a figure showing all ColorBrewer colorschemes.
%  schemes = brewermap('list')% Return a list of all ColorBrewer colorschemes.
%  [map,num,typ] = brewermap(...); % The current colorscheme's number of nodes and type.
%
%%% Syntax (preselect colorscheme):
%  old = brewermap(scheme); % Preselect any colorscheme, return the previous scheme.
%  map = brewermap(N);      % Use preselected scheme, select colormap length.
%  map = brewermap;         % Use preselected scheme, length same as current figure's colormap.
%
% See also CUBEHELIX RGBPLOT3 RGBPLOT COLORMAP COLORBAR PLOT PLOT3 SURF IMAGE AXES SET JET LBMAP PARULA
%
%% Color Schemes %%
%
% This product includes color specifications and designs developed by Cynthia Brewer.
% See the ColorBrewer website for further information about each colorscheme,
% colour-blind suitability, licensing, and citations: http://colorbrewer.org/
%
% To reverse the colormap sequence simply prefix the string token with '*'.
%
% Each colorscheme is defined by a set of hand-picked RGB values (nodes).
% If <N> is greater than the requested colorscheme's number of nodes then:
%  * Sequential and Diverging schemes are interpolated to give a larger
%    colormap. The interpolation is performed in the Lab colorspace.
%  * Qualitative schemes are repeated to give a larger colormap.
% Else:
%  * Exact values from the ColorBrewer sequences are returned for all colorschemes.
%
%%% Diverging
%
% Scheme|'BrBG'|'PRGn'|'PiYG'|'PuOr'|'RdBu'|'RdGy'|'RdYlBu'|'RdYlGn'|'Spectral'|
% ------|------|------|------|------|------|------|--------|--------|----------|
% Nodes |  11  |  11  |  11  |  11  |  11  |  11  |   11   |   11   |    11    |
%
%%% Qualitative
%
% Scheme|'Accent'|'Dark2'|'Paired'|'Pastel1'|'Pastel2'|'Set1'|'Set2'|'Set3'|
% ------|--------|-------|--------|---------|---------|------|------|------|
% Nodes |   8    |   8   |   12   |    9    |    8    |   9  |  8   |  12  |
%
%%% Sequential
%
% Scheme|'Blues'|'BuGn'|'BuPu'|'GnBu'|'Greens'|'Greys'|'OrRd'|'Oranges'|'PuBu'|
% ------|-------|------|------|------|--------|-------|------|---------|------|
% Nodes |   9   |  9   |  9   |  9   |   9    |   9   |  9   |    9    |  9   |
%
% Scheme|'PuBuGn'|'PuRd'|'Purples'|'RdPu'|'Reds'|'YlGn'|'YlGnBu'|'YlOrBr'|'YlOrRd'|
% ------|--------|------|---------|------|------|------|--------|--------|--------|
% Nodes |   9    |  9   |    9    |  9   |  9   |  9   |   9    |   9    |   9    |
%
%% Examples %%
%
%%% Plot a scheme's RGB values:
% rgbplot(brewermap(9,'Blues'))  % standard
% rgbplot(brewermap(9,'*Blues')) % reversed
%
%%% View information about a colorscheme:
% [~,num,typ] = brewermap(0,'Paired')
% num = 12
% typ = 'Qualitative'
%
%%% Multi-line plot using matrices:
% N = 6;
% axes('ColorOrder',brewermap(N,'Pastel2'),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
%%% Multi-line plot in a loop:
% set(0,'DefaultAxesColorOrder',brewermap(NaN,'Accent'))
% N = 6;
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
%%% New colors for the COLORMAP example:
% load spine
% image(X)
% colormap(brewermap([],'YlGnBu'))
%
%%% New colors for the SURF example:
% [X,Y,Z] = peaks(30);
% surfc(X,Y,Z)
% colormap(brewermap([],'RdYlGn'))
% axis([-3,3,-3,3,-10,5])
%
%%% New colors for the CONTOURCMAP example:
% brewermap('PuOr'); % preselect the colorscheme.
% load topo
% load coast
% figure
% worldmap(topo, topolegend)
% contourfm(topo, topolegend);
% contourcmap('brewermap', 'Colorbar','on', 'Location','horizontal',...
% 'TitleString','Contour Intervals in Meters');
% plotm(lat, long, 'k')
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
% N = NumericScalar, N>=0, an integer to specify the colormap length.
%   = *[], same length as the current figure's colormap (see COLORMAP).
%   = NaN, same length as the defining RGB nodes (useful for Line ColorOrder).
%   = CharRowVector, to preselect a ColorBrewer colorscheme for later use.
%   = 'plot', create a figure showing all of the ColorBrewer colorschemes.
%   = 'list', return a cell array of strings listing all ColorBrewer colorschemes.
% scheme = CharRowVector, a ColorBrewer colorscheme name.
%        = *none, uses the preselected colorscheme (must be set previously!).
%
%%% Outputs:
% map = NumericMatrix, size Nx3, a colormap of RGB values between 0 and 1.
% num = NumericScalar, the number of nodes defining the ColorBrewer colorscheme.
% typ = CharRowVector, the colorscheme type: 'Diverging'/'Qualitative'/'Sequential'.
% OR
% schemes = CellOfCharRowVectors, a list of every ColorBrewer colorscheme.
%
% [map,num,typ] = brewermap(*N,*scheme)
% OR
% schemes = brewermap('list')

%% Input Wrangling %%
%
persistent raw tok isr idp
%
if isempty(raw)
	raw = bmColors();
end
%
msg = 'A colorscheme must be preselected before calling without a colorscheme name.';
%
if nargin==0 % Current figure's colormap length and the preselected colorscheme.
	assert(~isempty(idp),msg)
	[map,num,typ] = bmSample([],isr,raw(idp));
elseif nargin==2 % Input colormap length and colorscheme.
	assert(isnumeric(N),'The first argument must be a scalar numeric, or empty.')
	assert(ischar(scheme)&&isrow(scheme),'The second argument must be a 1xN char.')
	tmp = strncmp('*',scheme,1);
	[map,num,typ] = bmSample(N,tmp,raw(bmMatch(scheme,tmp,raw)));
elseif isnumeric(N) % Input colormap length and the preselected colorscheme.
	assert(~isempty(idp),msg)
	[map,num,typ] = bmSample(N,isr,raw(idp));
else
	assert(ischar(N)&&isrow(N),'The first argument must be a 1xN char or a scalar numeric.')
	switch lower(N)
		case 'plot' % Plot all colorschemes in a figure.
			bmPlotFig(raw)
		case 'list' % Return a list of all colorschemes.
			map = {raw.str};
			typ = {raw.typ};
			num = [raw.num];
		otherwise % Store the preselected colorscheme token.
			tmp = strncmp('*',N,1);
			idp = bmMatch(N,tmp,raw);
			typ = raw(idp).typ;
			num = raw(idp).num;
			% Only update persistent values if colorscheme name is okay:
			isr = tmp;
			map = tok;
			tok = N;
	end
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%brewermap
function idx = bmMatch(str,tmp,raw)
% Match the requested colorscheme name to names in the raw data structure.
str = str(1+tmp:end);
idx = strcmpi({raw.str},str);
assert(any(idx),'Colorscheme "%s" is not supported. Check the colorscheme list.',str)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmMatch
function [map,num,typ] = bmSample(N,isr,raw)
% Pick a colorscheme, downsample/interpolate to the requested colormap length.
%
num = raw.num;
typ = raw.typ;
%
if isempty(N)
	N = size(get(gcf,'colormap'),1);
elseif isscalar(N)&&isnan(N)
	N = num;
else
	assert(isscalar(N),'First argument must be a numeric scalar, or empty.')
	assert(isreal(N),'Input <N> must be a real numeric: %g+%gi',N,imag(N))
	assert(fix(N)==N&&N>=0,'Input <N> must be positive integer: %g',N)
end
%
if N==0
	map = nan(0,3);
	return
end
%
% downsample:
[idx,itp] = bmIndex(N,num,typ);
map = raw.rgb(idx,:)/255;
% interpolate:
if itp
	M = [...
		+3.2406255,-1.5372080,-0.4986286;...
		-0.9689307,+1.8757561,+0.0415175;...
		+0.0557101,-0.2040211,+1.0569959];
	wpt = [0.95047,1,1.08883]; % D65
	%
	map = bmRGB2Lab(map,M,wpt); % optional
	%
	% Extrapolate a small amount at both ends:
	%vec = linspace(0,num+1,N+2);
	%map = interp1(1:num,map,vec(2:end-1),'linear','extrap');
	% Interpolation completely within ends:
	map = interp1(1:num,map,linspace(1,num,N),'spline');
	%
	map = bmLab2RGB(map,M,wpt); % optional
end
% reverse order:
if isr
	map = map(end:-1:1,:);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmSample
function rgb = bmGammaCor(rgb)
% Gamma correction of sRGB data.
idx = rgb <= 0.0031308;
rgb(idx) = 12.92 * rgb(idx);
rgb(~idx) = real(1.055 * rgb(~idx).^(1/2.4) - 0.055);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmGammaCor
function rgb = bmGammaInv(rgb)
% Inverse gamma correction of sRGB data.
idx = rgb <= 0.04045;
rgb(idx) = rgb(idx) / 12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055) / 1.055).^2.4);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmGammaInv
function lab = bmRGB2Lab(rgb,M,wpt) % Nx3 <- Nx3
% Convert a matrix of sRGB values to Lab.
%
%applycform(rgb,makecform('srgb2lab','AdaptedWhitePoint',wpt))
%
% RGB2XYZ:
xyz = bmGammaInv(rgb) / M.';
% Remember to include my license when copying my implementation.
% XYZ2Lab:
xyz = bsxfun(@rdivide,xyz,wpt);
idx = xyz>(6/29)^3;
F = idx.*(xyz.^(1/3)) + ~idx.*(xyz*(29/6)^2/3+4/29);
lab(:,2:3) = bsxfun(@times,[500,200],F(:,1:2)-F(:,2:3));
lab(:,1) = 116*F(:,2) - 16;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmRGB2Lab
function rgb = bmLab2RGB(lab,M,wpt) % Nx3 <- Nx3
% Convert a matrix of Lab values to sRGB.
%
%applycform(lab,makecform('lab2srgb','AdaptedWhitePoint',wpt))
%
% Lab2XYZ
tmp = bsxfun(@rdivide,lab(:,[2,1,3]),[500,Inf,-200]);
tmp = bsxfun(@plus,tmp,(lab(:,1)+16)/116);
idx = tmp>(6/29);
tmp = idx.*(tmp.^3) + ~idx.*(3*(6/29)^2*(tmp-4/29));
xyz = bsxfun(@times,tmp,wpt);
% Remember to include my license when copying my implementation.
% XYZ2RGB
rgb = max(0,min(1, bmGammaCor(xyz * M.')));
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cbLab2RGB
function bmPlotFig(raw)
% Creates a figure showing all of the ColorBrewer colorschemes.
%
persistent cbh axh
%
xmx = max([raw.num]);
ymx = numel(raw);
%
if ishghandle(cbh)
	figure(cbh);
	delete(axh);
else
	cbh = figure('HandleVisibility','callback', 'IntegerHandle','off',...
		'NumberTitle','off', 'Name',[mfilename,' Plot'],'Color','white',...
		'MenuBar','figure', 'Toolbar','none', 'Tag',mfilename);
	set(cbh,'Units','pixels')
	pos = get(cbh,'Position');
	pos(1:2) = pos(1:2) - 123;
	pos(3:4) = max(pos(3:4),[842,532]);
	set(cbh,'Position',pos)
end
%
axh = axes('Parent',cbh, 'Color','none',...
	'XTick',0:xmx, 'YTick',0.5:ymx, 'YTickLabel',{raw.str}, 'YDir','reverse');
title(axh,['ColorBrewer Color Schemes (',mfilename,'.m)'], 'Interpreter','none')
xlabel(axh,'Scheme Nodes')
ylabel(axh,'Scheme Name')
axf = get(axh,'FontName');
%
for y = 1:ymx
	num = raw(y).num;
	typ = raw(y).typ;
	map = raw(y).rgb(bmIndex(num,num,typ),:)/255; % downsample
	for x = 1:num
		patch([x-1,x-1,x,x],[y-1,y,y,y-1],1, 'FaceColor',map(x,:), 'Parent',axh)
	end
	text(xmx+0.1,y-0.5,typ, 'Parent',axh, 'FontName',axf)
end
%
drawnow()
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmPlotFig
function [idx,itp] = bmIndex(N,num,typ)
% Ensure exactly the same colors as the online ColorBrewer colorschemes.
%
itp = N>num;
switch typ
	case 'Qualitative'
		itp = false;
		idx = 1+mod(0:N-1,num);
	case 'Diverging'
		switch N
			case 1 % extrapolated
				idx = 8;
			case 2 % extrapolated
				idx = [4,12];
			case 3
				idx = [5,8,11];
			case 4
				idx = [3,6,10,13];
			case 5
				idx = [3,6,8,10,13];
			case 6
				idx = [2,5,7,9,11,14];
			case 7
				idx = [2,5,7,8,9,11,14];
			case 8
				idx = [2,4,6,7,9,10,12,14];
			case 9
				idx = [2,4,6,7,8,9,10,12,14];
			case 10
				idx = [1,2,4,6,7,9,10,12,14,15];
			otherwise
				idx = [1,2,4,6,7,8,9,10,12,14,15];
		end
	case 'Sequential'
		switch N
			case 1 % extrapolated
				idx = 6;
			case 2 % extrapolated
				idx = [4,8];
			case 3
				idx = [3,6,9];
			case 4
				idx = [2,5,7,10];
			case 5
				idx = [2,5,7,9,11];
			case 6
				idx = [2,4,6,7,9,11];
			case 7
				idx = [2,4,6,7,8,10,12];
			case 8
				idx = [1,3,4,6,7,8,10,12];
			otherwise
				idx = [1,3,4,6,7,8,10,11,13];
		end
	otherwise
		error('The colorscheme type "%s" is not recognized',typ)
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmIndex
function raw = bmColors()
% Return a structure of all colorschemes: name, scheme type, RGB values, number of nodes.
% Order: first sort by <typ>, then case-insensitive sort by <str>:
raw(35).str = 'YlOrRd';
raw(35).typ = 'Sequential';
raw(35).rgb = [255,255,204;255,255,178;255,237,160;254,217,118;254,204,92;254,178,76;253,141,60;252,78,42;240,59,32;227,26,28;189,0,38;177,0,38;128,0,38];
raw(34).str = 'YlOrBr';
raw(34).typ = 'Sequential';
raw(34).rgb = [255,255,229;255,255,212;255,247,188;254,227,145;254,217,142;254,196,79;254,153,41;236,112,20;217,95,14;204,76,2;153,52,4;140,45,4;102,37,6];
raw(33).str = 'YlGnBu';
raw(33).typ = 'Sequential';
raw(33).rgb = [255,255,217;255,255,204;237,248,177;199,233,180;161,218,180;127,205,187;65,182,196;29,145,192;44,127,184;34,94,168;37,52,148;12,44,132;8,29,88];
raw(32).str = 'YlGn';
raw(32).typ = 'Sequential';
raw(32).rgb = [255,255,229;255,255,204;247,252,185;217,240,163;194,230,153;173,221,142;120,198,121;65,171,93;49,163,84;35,132,67;0,104,55;0,90,50;0,69,41];
raw(31).str = 'Reds';
raw(31).typ = 'Sequential';
raw(31).rgb = [255,245,240;254,229,217;254,224,210;252,187,161;252,174,145;252,146,114;251,106,74;239,59,44;222,45,38;203,24,29;165,15,21;153,0,13;103,0,13];
raw(30).str = 'RdPu';
raw(30).typ = 'Sequential';
raw(30).rgb = [255,247,243;254,235,226;253,224,221;252,197,192;251,180,185;250,159,181;247,104,161;221,52,151;197,27,138;174,1,126;122,1,119;122,1,119;73,0,106];
raw(29).str = 'Purples';
raw(29).typ = 'Sequential';
raw(29).rgb = [252,251,253;242,240,247;239,237,245;218,218,235;203,201,226;188,189,220;158,154,200;128,125,186;117,107,177;106,81,163;84,39,143;74,20,134;63,0,125];
raw(28).str = 'PuRd';
raw(28).typ = 'Sequential';
raw(28).rgb = [247,244,249;241,238,246;231,225,239;212,185,218;215,181,216;201,148,199;223,101,176;231,41,138;221,28,119;206,18,86;152,0,67;145,0,63;103,0,31];
raw(27).str = 'PuBuGn';
raw(27).typ = 'Sequential';
raw(27).rgb = [255,247,251;246,239,247;236,226,240;208,209,230;189,201,225;166,189,219;103,169,207;54,144,192;28,144,153;2,129,138;1,108,89;1,100,80;1,70,54];
raw(26).str = 'PuBu';
raw(26).typ = 'Sequential';
raw(26).rgb = [255,247,251;241,238,246;236,231,242;208,209,230;189,201,225;166,189,219;116,169,207;54,144,192;43,140,190;5,112,176;4,90,141;3,78,123;2,56,88];
raw(25).str = 'Oranges';
raw(25).typ = 'Sequential';
raw(25).rgb = [255,245,235;254,237,222;254,230,206;253,208,162;253,190,133;253,174,107;253,141,60;241,105,19;230,85,13;217,72,1;166,54,3;140,45,4;127,39,4];
raw(24).str = 'OrRd';
raw(24).typ = 'Sequential';
raw(24).rgb = [255,247,236;254,240,217;254,232,200;253,212,158;253,204,138;253,187,132;252,141,89;239,101,72;227,74,51;215,48,31;179,0,0;153,0,0;127,0,0];
raw(23).str = 'Greys';
raw(23).typ = 'Sequential';
raw(23).rgb = [255,255,255;247,247,247;240,240,240;217,217,217;204,204,204;189,189,189;150,150,150;115,115,115;99,99,99;82,82,82;37,37,37;37,37,37;0,0,0];
raw(22).str = 'Greens';
raw(22).typ = 'Sequential';
raw(22).rgb = [247,252,245;237,248,233;229,245,224;199,233,192;186,228,179;161,217,155;116,196,118;65,171,93;49,163,84;35,139,69;0,109,44;0,90,50;0,68,27];
raw(21).str = 'GnBu';
raw(21).typ = 'Sequential';
raw(21).rgb = [247,252,240;240,249,232;224,243,219;204,235,197;186,228,188;168,221,181;123,204,196;78,179,211;67,162,202;43,140,190;8,104,172;8,88,158;8,64,129];
raw(20).str = 'BuPu';
raw(20).typ = 'Sequential';
raw(20).rgb = [247,252,253;237,248,251;224,236,244;191,211,230;179,205,227;158,188,218;140,150,198;140,107,177;136,86,167;136,65,157;129,15,124;110,1,107;77,0,75];
raw(19).str = 'BuGn';
raw(19).typ = 'Sequential';
raw(19).rgb = [247,252,253;237,248,251;229,245,249;204,236,230;178,226,226;153,216,201;102,194,164;65,174,118;44,162,95;35,139,69;0,109,44;0,88,36;0,68,27];
raw(18).str = 'Blues';
raw(18).typ = 'Sequential';
raw(18).rgb = [247,251,255;239,243,255;222,235,247;198,219,239;189,215,231;158,202,225;107,174,214;66,146,198;49,130,189;33,113,181;8,81,156;8,69,148;8,48,107];
raw(17).str = 'Set3';
raw(17).typ = 'Qualitative';
raw(17).rgb = [141,211,199;255,255,179;190,186,218;251,128,114;128,177,211;253,180,98;179,222,105;252,205,229;217,217,217;188,128,189;204,235,197;255,237,111];
raw(16).str = 'Set2';
raw(16).typ = 'Qualitative';
raw(16).rgb = [102,194,165;252,141,98;141,160,203;231,138,195;166,216,84;255,217,47;229,196,148;179,179,179];
raw(15).str = 'Set1';
raw(15).typ = 'Qualitative';
raw(15).rgb = [228,26,28;55,126,184;77,175,74;152,78,163;255,127,0;255,255,51;166,86,40;247,129,191;153,153,153];
raw(14).str = 'Pastel2';
raw(14).typ = 'Qualitative';
raw(14).rgb = [179,226,205;253,205,172;203,213,232;244,202,228;230,245,201;255,242,174;241,226,204;204,204,204];
raw(13).str = 'Pastel1';
raw(13).typ = 'Qualitative';
raw(13).rgb = [251,180,174;179,205,227;204,235,197;222,203,228;254,217,166;255,255,204;229,216,189;253,218,236;242,242,242];
raw(12).str = 'Paired';
raw(12).typ = 'Qualitative';
raw(12).rgb = [166,206,227;31,120,180;178,223,138;51,160,44;251,154,153;227,26,28;253,191,111;255,127,0;202,178,214;106,61,154;255,255,153;177,89,40];
raw(11).str = 'Dark2';
raw(11).typ = 'Qualitative';
raw(11).rgb = [27,158,119;217,95,2;117,112,179;231,41,138;102,166,30;230,171,2;166,118,29;102,102,102];
raw(10).str = 'Accent';
raw(10).typ = 'Qualitative';
raw(10).rgb = [127,201,127;190,174,212;253,192,134;255,255,153;56,108,176;240,2,127;191,91,23;102,102,102];
raw(09).str = 'Spectral';
raw(09).typ = 'Diverging';
raw(09).rgb = [158,1,66;213,62,79;215,25,28;244,109,67;252,141,89;253,174,97;254,224,139;255,255,191;230,245,152;171,221,164;153,213,148;102,194,165;43,131,186;50,136,189;94,79,162];
raw(08).str = 'RdYlGn';
raw(08).typ = 'Diverging';
raw(08).rgb = [165,0,38;215,48,39;215,25,28;244,109,67;252,141,89;253,174,97;254,224,139;255,255,191;217,239,139;166,217,106;145,207,96;102,189,99;26,150,65;26,152,80;0,104,55];
raw(07).str = 'RdYlBu';
raw(07).typ = 'Diverging';
raw(07).rgb = [165,0,38;215,48,39;215,25,28;244,109,67;252,141,89;253,174,97;254,224,144;255,255,191;224,243,248;171,217,233;145,191,219;116,173,209;44,123,182;69,117,180;49,54,149];
raw(06).str = 'RdGy';
raw(06).typ = 'Diverging';
raw(06).rgb = [103,0,31;178,24,43;202,0,32;214,96,77;239,138,98;244,165,130;253,219,199;255,255,255;224,224,224;186,186,186;153,153,153;135,135,135;64,64,64;77,77,77;26,26,26];
raw(05).str = 'RdBu';
raw(05).typ = 'Diverging';
raw(05).rgb = [103,0,31;178,24,43;202,0,32;214,96,77;239,138,98;244,165,130;253,219,199;247,247,247;209,229,240;146,197,222;103,169,207;67,147,195;5,113,176;33,102,172;5,48,97];
raw(04).str = 'PuOr';
raw(04).typ = 'Diverging';
raw(04).rgb = [127,59,8;179,88,6;230,97,1;224,130,20;241,163,64;253,184,99;254,224,182;247,247,247;216,218,235;178,171,210;153,142,195;128,115,172;94,60,153;84,39,136;45,0,75];
raw(03).str = 'PRGn';
raw(03).typ = 'Diverging';
raw(03).rgb = [64,0,75;118,42,131;123,50,148;153,112,171;175,141,195;194,165,207;231,212,232;247,247,247;217,240,211;166,219,160;127,191,123;90,174,97;0,136,55;27,120,55;0,68,27];
raw(02).str = 'PiYG';
raw(02).typ = 'Diverging';
raw(02).rgb = [142,1,82;197,27,125;208,28,139;222,119,174;233,163,201;241,182,218;253,224,239;247,247,247;230,245,208;184,225,134;161,215,106;127,188,65;77,172,38;77,146,33;39,100,25];
raw(01).str = 'BrBG';
raw(01).typ = 'Diverging';
raw(01).rgb = [84,48,5;140,81,10;166,97,26;191,129,45;216,179,101;223,194,125;246,232,195;245,245,245;199,234,229;128,205,193;90,180,172;53,151,143;1,133,113;1,102,94;0,60,48];
% number of nodes:
for k = 1:numel(raw)
	switch raw(k).typ
		case 'Diverging'
			raw(k).num = 11;
		case 'Qualitative'
			raw(k).num = size(raw(k).rgb,1);
		case 'Sequential'
			raw(k).num = 9;
	end
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmColors
% Code and Implementation:
% Copyright (c) 2014 Stephen Cobeldick
% Color Values Only:
% Copyright (c) 2002 Cynthia Brewer, Mark Harrower, and The Pennsylvania State University.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and limitations under the License.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions as source code must retain the above copyright notice, this
% list of conditions and the following disclaimer.
%
% 2. The end-user documentation included with the redistribution, if any, must
% include the following acknowledgment: "This product includes color
% specifications and designs developed by Cynthia Brewer
% (http://colorbrewer.org/)." Alternately, this acknowledgment may appear in the
% software itself, if and wherever such third-party acknowledgments normally appear.
%
% 4. The name "ColorBrewer" must not be used to endorse or promote products
% derived from this software without prior written permission. For written
% permission, please contact Cynthia Brewer at cbrewer@psu.edu.
%
% 5. Products derived from this software may not be called "ColorBrewer", nor
% may "ColorBrewer" appear in their name, without prior written permission of Cynthia Brewer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license