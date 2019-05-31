function lc_dfc_roiwise(result_dir, all_subj_dir, window_step, window_length, opt)
% 计算一组被试的ROI wise的动态功能连接和了静态功能连接
% input：
%   time_series_of_all_node：一组被试的时间序列矩阵，每一个被试的数据size为：T*N，T为时间点个数，N为ROI的个数
%   window_step,window_length：步长和宽
%   opt:options
% output
%   ZFC_dynamic 文件夹下为每个被试的动态功能连接（Fisher R to Z
% 变换过），size=N*N*W，N为ROI个数，W为slide window 个数
%   ZFC_static 文件夹下为每个被试的静态功能连接（Fisher R to Z 变换过）
tic
%% 

if nargin < 5
    opt.if_calc_dynamic = 0;
    opt.if_calc_static = 1;
end

if nargin < 4
    window_length = 17;
end

if nargin < 3
    window_step = 1;
end

% 获得所有被试mat的路径
if nargin<2
    all_subj_dir=uigetdir(pwd, 'select directory that containing all subjects'' data');
    all_subj_dir=dir(all_subj_dir);
    folder={all_subj_dir.folder};
    name={all_subj_dir.name};
    all_subj_dir=cell(length(name),1);
    for i =1:length(name)
        all_subj_dir{i}=fullfile(folder{i},name{i});
    end
     all_subj_dir= all_subj_dir(3:end);
end

% 结果目录
if nargin<1
    result_dir=uigetdir(pwd, 'select directory that saving results');
end

mkdir(fullfile(result_dir,'zStaticFC'));
mkdir(fullfile(result_dir,'zDynamicFC'));
result_dir_of_dynamic=fullfile(result_dir,'zDynamicFC');
result_dir_of_static=fullfile(result_dir,'zStaticFC');

%% calculate both the static and dynamic Inter-ROI FC
fprintf('==================================\n');
fprintf(' Calculating dynamic FC\n');
nSubj=length(all_subj_dir);
for s=1:nSubj
    fprintf('正在计算第%d/%d个被试...\n',s,nSubj);
    data_dir=all_subj_dir{s};
    time_series_of_all_node=importdata(data_dir);
    
    if opt.if_calc_dynamic==1 && opt.if_calc_static==1
        [zDynamicFC,zStaticFC]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_dynamic,filesep,name,format],'zDynamicFC');
        save([result_dir_of_static,filesep,name,format],'zStaticFC');

    elseif opt.if_calc_dynamic==1 && opt.if_calc_static==0
        [zDynamicFC,~]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_dynamic,filesep,name,format],'zDynamicFC');

    elseif opt.if_calc_dynamic==0 && opt.if_calc_static==1
        [~,zStaticFC]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_static,filesep,name,format],'zStaticFC');

    else
        fprintf('do nothing!\n')
        return
    end
end
fprintf('==================================\n');
fprintf('Dynamic FC calculating completed!\n');
toc
end

function [zDynamicFC,zStaticFC]=...
            DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length)
% 计算一个被试ROI wise的动态功能连接和静态功能连接
% input：
%   一个被试的时间序列矩阵time_series_of_all_node，size为：T*N，T为时间点个数，N为ROI的个数
% output
%   zDynamicFC： 文件夹下为的动态功能连接（Fisher R to Z
%   变换过），size=N*N*W，N为ROI个数，W为slide window 个数
%   zStaticFC： 文件夹下为静态功能连接（Fisher R to Z 变换过）
%   stdOfZDynamicFC: 动态FC的标准差
%%
%计算dynamic FC窗口个数
% window_end=window_length;
volume=size(time_series_of_all_node,1);% dynamic FC parameters
nWindow=ceil((volume - window_length + 1) / window_step);
% nWindow=1;
% while window_end <volume
%     window_end=window_end+window_step;
%     nWindow=nWindow+1;  % 计算多少个窗，即多少个动态矩阵,用来分配空间给ZFC_dynamic,从而加快速度
% end

% allocate space
nRegion=size(time_series_of_all_node,2);
% static FC
staticR=corrcoef(time_series_of_all_node);
zStaticFC=0.5*log((1+staticR)./(1-staticR));%Fisher R-to-Z transformation
% dynamic FC
window_star=1;
window_end=window_length;  % 重置,初始化
count=1;
zDynamicFC=zeros(nRegion,nRegion,nWindow);
while window_end <= volume
    windowedTimecourse=time_series_of_all_node(window_star:window_end,:);
    dynamicR=corrcoef(windowedTimecourse);
    zDynamicFC(:,:,count)=0.5*log((1+dynamicR)./(1-dynamicR));  % Fisher R-to-Z transformation
    window_star=window_star+window_step;
    window_end=window_end+window_step;
    count=count+1;
end
% stdOfZDynamicFC=std(zDynamicFC,0,3);%求在滑动窗方向的标准差。
end