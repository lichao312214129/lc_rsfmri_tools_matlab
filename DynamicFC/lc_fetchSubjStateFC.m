function lc_fetchSubjStateFC(IDX,k,dFCPath,subj_name,out_path)
% 根据kmeans后的IDX以及所有被试的动态连接矩阵（nNode*nNode*nWindow*nSubj）
% 来求得每个人的各个状态的连接矩阵（状态内所有窗的中位数median/平均数mean,默认中位数）
% 可能某些被试没有某个状态【DOI:10.1002/hbm.23430】
% input
% IDX:kmeans后的index
% k:类数
% dFCPath:动态功能连接矩阵所在文件夹（nNode*nNode*nWindow*nSubj）
% subjName:所有被试的名字，顺序要一致
% outPath:结果保存路径
% output
% 每个被试个体，每个状态的连接矩阵
%%
if nargin<1
    IDX_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\IDX.mat';
    k=4;
    dFCPath='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\DynamicFC_length17_step1_screened';
    subj_name='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\covariances\subjName.mat';
    out_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all';
    
    IDX=importdata(IDX_path);
    subj_name=importdata(subj_name);
end
%%
% 新建保存结果的文件夹
for i=1:k
    if ~exist(fullfile(out_path,['state',num2str(i)]),'dir')
        mkdir(fullfile(out_path,['state',num2str(i)]));
    end
end

% 按照顺序加载被试的名字
% subj_name=importdata(subj_name);
numOfSubj=length(subj_name);

% 判断输入IDX\subj_name是否正确，并自动计算窗口数目
[nRow,~]=size(IDX);
if fix(nRow/numOfSubj)~=nRow/numOfSubj
    fprintf('输入的窗口数目*被试数目不等于IDX！\n');
    return
else
    num_window=nRow/numOfSubj;
end

% 加载被试的动态功能连接矩阵
dFCFile=dir(fullfile([dFCPath,'\*.mat']));
dFCName={dFCFile.name}';
dFCFile=fullfile(dFCPath,dFCName);

% 逐个被试，求各个状态的平均连接
numOfSubj=length(subj_name);
ind_start=1:num_window:nRow;
ind_end=num_window:num_window:nRow;

% try
% p = parpool('local',1);
% catch
%     disp('已开启多CPU')
% end

tic;
for ithSubj=1:numOfSubj
    fprintf('%d/%d\n',ithSubj,numOfSubj);
    calc_median_or_mean(IDX,ithSubj,ind_start,ind_end,dFCFile,subj_name,out_path);
end
toc;
fprintf('============Done!============\n');
end

function state_fc=calc_median_or_mean(IDX,ithSubj,ind_start,ind_end,dFCFile,subj_name,out_path)

idx_current_subj=IDX(ind_start(ithSubj):ind_end(ithSubj));
unique_idx=unique(idx_current_subj);
% 当前被试的所有状态
dFC=importdata(dFCFile{ithSubj});%  载入当前被试
for i=1:length(unique_idx)
    % 求匹配当前状态的窗口的功能连接的平均值
    ith_state=unique_idx(i);
    state_fc=median(dFC(:,:,idx_current_subj==ith_state),3);
%     state_fc=mean(dFC(:,:,idx_current_subj==ith_state),3);
    % 将当前结果保存到当前被试的当前状态文件夹下面
    outpath=fullfile(out_path,['state',num2str(ith_state)],subj_name{ithSubj});
    my_save(outpath,state_fc)
end
end

function my_save(outpath,state_fc)
save(outpath,'state_fc');
end