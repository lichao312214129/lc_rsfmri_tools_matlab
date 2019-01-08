function dynamic_std=lc_calc_metrics_for_dynamic_FC(path,suffix,save_path)
% 计算动态功能连接的相应metrics(std)
% input:
%   path:某一组被试所在文件夹
%   suffix：所选择文件后缀
%   n_node：功能网络的节点数目
%   save_path:结果保存文件夹
% output:
%   dynamic_std:所有被试的metrics(保存到相应文件夹下)
%%
% input
if nargin<1
    path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\DynamicFC_length18_step1_screened\MDD';
    suffix='*.mat';
    save_path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\DynamicFC_length18_step1_screened\MDD_std';
end

if ~exist(save_path,'dir')
    mkdir(save_path);
end
%
subj=dir(fullfile(path,suffix));
subj={subj.name}';
subj_path=fullfile(path,subj);

n_subj=length(subj);
for i =1:n_subj
    fprintf('%d/%d\n',i,n_subj);
    dynamic_fc=importdata(subj_path{i});
    dynamic_std=var(dynamic_fc,0,3);
    % save
    target=fullfile(save_path,subj{i});
    save(target,'dynamic_std');
end
fprintf('Done!\n');
end