function lc_dfc_roiwise(all_subjects_files, result_dir, window_step, window_length, opt)
%  Used to calculate  roi-wise dynamic fc using sliding-window method for
%  on group of subjects
% input：
%   all_subjects_files: all subjects' files (wich abslute path) 
% result_dir:
%     directiory for saving results
% window_step: sliding-window step
% window_length: sliding-window length
% output
%   zDynamicFC： dynamic FC matrix with Fisher r-to-z transformed; size=N*N*W, N is the number of ROIs, W is the number of sliding-window
%   zStaticFC： static FC matrix with Fisher r-to-z transformed; size=N*N, N is the number of ROIs
%   varOfZDynamicFC: variance of dynamic FC
%% input
tic

if nargin < 5
    opt.if_calc_dynamic = 1;
    opt.if_calc_static = 1;
end

if nargin < 4
    window_length = 17;
end

if nargin < 3
    window_step = 1;
end

% results directory
if nargin < 2
    result_dir=uigetdir(pwd, 'select directory that saving results');
end

% get all subjects' file name
if nargin < 1
    all_subjects_files=uigetdir(pwd, 'select directory that containing all subjects'' data');
    all_subjects_files=dir(all_subjects_files);
    folder={all_subjects_files.folder};
    name={all_subjects_files.name};
    all_subjects_files=cell(length(name),1);
    for i =1:length(name)
        all_subjects_files{i}=fullfile(folder{i},name{i});
    end
     all_subjects_files= all_subjects_files(3:end);
end

result_dir_of_static = fullfile(result_dir,'zStaticFC');
result_dir_of_dynamic = fullfile(result_dir,'zDynamicFC');
if ~exist(result_dir_of_static, 'dir')
    mkdir(result_dir_of_static);
end
if ~exist(result_dir_of_dynamic, 'dir')
    mkdir(result_dir_of_dynamic);
end
%% calculate both the static and dynamic Inter-ROI FC
fprintf('==================================\n');
fprintf(' Calculating dynamic FC\n');
nSubj=length(all_subjects_files);
for s=1:nSubj
    fprintf('Calculating %d/%d subject...\n',s,nSubj);
    data_dir=all_subjects_files{s};
    time_series_of_all_node=importdata(data_dir);
    
    if opt.if_calc_dynamic==1 && opt.if_calc_static==1
        [zDynamicFC,zStaticFC]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_static,filesep,name,format],'zDynamicFC');
        save([result_dir_of_static,filesep,name,format],'zStaticFC');

    elseif opt.if_calc_dynamic==1 && opt.if_calc_static==0
        [zDynamicFC,~]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_static,filesep,name,format],'zDynamicFC');

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

function [zDynamicFC,zStaticFC]=DynamicFC_interROI_oneSubj(time_series_of_all_node,window_step,window_length)
%  Used to calculate  roi-wise dynamic fc using sliding-window method for
%  on subject
% input：
%   time_series_of_all_node: size=T-by-N, T is number of timepoints, N is
%   number of ROIs
% window_step: sliding-window step
% window_length: sliding-window length
% output
%   zDynamicFC： dynamic FC matrix with Fisher r-to-z transformed; size=N*N*W, N is the number of ROIs, W is the number of sliding-window
%   zStaticFC： static FC matrix with Fisher r-to-z transformed; size=N*N, N is the number of ROIs
%   varOfZDynamicFC: variance of dynamic FC
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
zStaticFC=atanh(staticR);  % Fisher R-to-Z
% dynamic FC
window_star=1;
window_end=window_length;  % re-innitiation
count=1;
zDynamicFC=zeros(nRegion,nRegion,nWindow);
while window_end <= volume
    windowedTimecourse=time_series_of_all_node(window_star:window_end,:);
    dynamicR=corrcoef(windowedTimecourse);
    zDynamicFC(:,:,count)=atanh(dynamicR);  % Fisher R-to-Z transformation
    window_star=window_star+window_step;
    window_end=window_end+window_step;
    count=count+1;
end
% varOfZDynamicFC=std(zDynamicFC,0,3);%求在滑动窗方向的标准差。
end