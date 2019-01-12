function average_edge = lc_calc_average(in_path,if_save,out_name)
% 用途：计算一组被试网络边的平均值
% input:
%   in_path:一组被试的文件夹
%   if_save：是否保存结果
%   out_name：保存结果的名字（带路径）
% output:
%    average_edge: 一组被试平均后的网络边
%%
% 读取所有文件的路径
% path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state1\state1_HC';
subj=dir(fullfile(in_path,'*.mat'));
subj_name={subj.name}';
subj_path=fullfile(in_path,subj_name);

%加载并同时计算所有被试边的和（节约计算空间）
n_subj=length(subj_name);
for i=1:n_subj
    subj_edge=importdata(subj_path{i});
    % inf---1,nan---0
    subj_edge(isinf(subj_edge))=1;
    subj_edge(isnan(subj_edge))=0;
    % 如果一个矩阵全部为inf或者nan，则有理由认为数据有问题
    if sum(subj_edge(:))==1 || sum(subj_edge(:))==0
        fprintf('被试:%s的数据可能存在异常，请检查\n',subj_path{i});
    end
    % 初始化sum_edge
    if i==1
        sum_edge=subj_edge;
    else
        sum_edge=sum_edge+subj_edge;
    end
end

% 除以总人数，得到均值
average_edge=sum_edge/n_subj;

% inf---1,nan---0
% average_edge(isinf(average_edge))=1;
% average_edge(isnan(average_edge))=0;

% save
if if_save
    save(out_name,'average_edge');
end

disp('Done!')
end

