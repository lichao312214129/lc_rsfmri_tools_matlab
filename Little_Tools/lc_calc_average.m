function average_edge = lc_calc_average(in_path, is_save, suffix, out_name)
% 用途：计算一组被试网络边的平均值
% input:
%   in_path:一组被试的文件夹
%   if_save：是否保存结果
%   out_name：保存结果的名字（带路径）
% output:
%    average_edge: 一组被试平均后的网络边
%% input
if nargin < 4
    out_name = 'average_edge';
end

if nargin < 3
    suffix = '*.mat';
end

if nargin < 2
    is_save = 1;
end

if nargin < 1
    in_path = uigetdir(pwd, 'select folder that containing group mat files');
end

%% read all files' directory
subj = dir(fullfile(in_path,suffix));
subj_name = {subj.name}';
subj_dir = fullfile(in_path,subj_name);

%加载并同时计算所有被试边的和（节约计算空间）
n_subj = length(subj_name);
sum_edge = 0;  % 初始化sum_edge
for i=1:n_subj
    subj_edge = importdata(subj_dir{i});
	subj_edge = load(subj_dir{i});
    % inf---1,nan---0
    subj_edge(isinf(subj_edge))=1;
    subj_edge(isnan(subj_edge))=0;
    % 如果一个矩阵全部为inf或者nan，则有理由认为数据有问题
    if sum(subj_edge(:))==numel(subj_edge) || sum(subj_edge(:))==0
        fprintf('被试:%s的数据可能存在异常，请检查\n',subj_dir{i});
    end
    sum_edge = sum_edge+subj_edge;
end

average_edge=sum_edge/n_subj;

% save
if is_save
    save(out_name,'average_edge');
end

disp('Done!')
end

