function [shared_1and2and3,shared_1and2,shared_1and3,shared_2and3,...
          distinct_1,distinct_2,distinct_3]=...
                lc_calc_shared_and_distinct_for_FCmatrix(h_mat,t_mat)
% 经过post-hoc之后，找到病人组（对于正常组来说）共同（且异常方向一致）以及每种疾病特有的（不包括异常方向特有）异常连接
% SZ & BD & MDD、SZ & BD not MDD、SZ & MDD not BD、BD & MDD not SZ、SZ、BD、MDD
% input
%   h_mat: 经过post-hoc 双样本t检验+FDR校正后的H矩阵（H==1,表示无统计学意义）
%   t_mat: 经过post-hoc 双样本t检验的t值
%%
if nargin<1
    % input
    path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all';
    state=4;
    correction_method='fdr';

    h_posthoc_corrected=fullfile(path,['state',num2str(state),'\result','\h_posthoc_',correction_method,'.mat']);
    t_posthoc_corrected=fullfile(path,['state',num2str(state),'\result','\tvalue_posthoc_',correction_method,'.mat']);
    h_mat=importdata(h_posthoc_corrected);
    t_mat=importdata(t_posthoc_corrected);
    if_save=1;
    save_path=fullfile(path,['state',num2str(state),'\result1']);
end

% 新建结果文件夹
mkdir(save_path)
%% 求共同及特有的异常连接（本研究有3种疾病，因此共同包括3个以及2个疾病的共同）

% 3者共同，且只选择异常方向一致的连接(mask与mask_sign的交集)
sum_h_mat=squeeze(sum(h_mat));
shared_1and2and3_ahad=sum_h_mat==3; 
tvalue_sign_for_1and2and3=sign(t_mat);
tvalue_sum=abs(squeeze(sum(tvalue_sign_for_1and2and3,1)));
tvalue_sign_comparisonor=ones(size(tvalue_sum))*size(tvalue_sign_for_1and2and3,1);
mask_net=tvalue_sum==tvalue_sign_comparisonor;
shared_1and2and3=shared_1and2and3_ahad.*mask_net~=0;

% 2者共同，且只选择异常方向一致的连接(mask与mask_sign的交集)
[shared_1and2,shared_1and3,shared_2and3]=calc_shared2(sum_h_mat,h_mat,t_mat); 

% 每种疾病特有，且只选择异常方向一致的连接(mask与mask_sign的交集)
[distinct_1,distinct_2,distinct_3]=calc_distinct(sum_h_mat,h_mat); 

%% save
if if_save
    save(fullfile(save_path,['shared_1and2and3_',correction_method,'.mat']),'shared_1and2and3');
    save(fullfile(save_path,['shared_1and2_',correction_method,'.mat']),'shared_1and2');
    save(fullfile(save_path,['shared_1and3_',correction_method,'.mat']),'shared_1and3');
    save(fullfile(save_path,['shared_2and3_',correction_method,'.mat']),'shared_2and3');
    
    save(fullfile(save_path,['distinct_1_',correction_method,'.mat']),'distinct_1');
    save(fullfile(save_path,['distinct_2_',correction_method,'.mat']),'distinct_2');
    save(fullfile(save_path,['distinct_3_',correction_method,'.mat']),'distinct_3');
end
end

function [shared_1and2,shared_1and3,shared_2and3]=calc_shared2(sum_h_mat,h_mat,t_mat)
% 当有3种疾病时，计算其中任意2个疾病的共同差异（当且仅当2种共同）
% input
%   sum_h_mat: 在组的维度对H矩阵求和的结果矩阵
%%
% 1and2
shared_2disorder=sum_h_mat==2;
shared_1and2_ahad=shared_2disorder.*squeeze(h_mat(1,:,:)).*squeeze(h_mat(2,:,:));

t_mat_for_1and2=t_mat(1:2,:,:);
tvalue_sign=sign(t_mat_for_1and2);
tvalue_sum=abs(squeeze(sum(tvalue_sign,1)));
tvalue_sign_comparisonor=ones(size(tvalue_sum))*size(tvalue_sign,1);
mask=tvalue_sum==tvalue_sign_comparisonor;
shared_1and2=shared_1and2_ahad.*mask~=0;

% 1and3
shared_1and3_ahad=shared_2disorder.*squeeze(h_mat(1,:,:)).*squeeze(h_mat(3,:,:));
t_mat_for_1and3=t_mat([1,3],:,:);
tvalue_sign=sign(t_mat_for_1and3);
tvalue_sum=abs(squeeze(sum(tvalue_sign,1)));
tvalue_sign_comparisonor=ones(size(tvalue_sum))*size(tvalue_sign,1);
mask=tvalue_sum==tvalue_sign_comparisonor;
shared_1and3=shared_1and3_ahad.*mask~=0;

% 2and3
shared_2and3_ahad=shared_2disorder.*squeeze(h_mat(2,:,:)).*squeeze(h_mat(3,:,:));
t_mat_for_2and3=t_mat([2,3],:,:);
tvalue_sign=sign(t_mat_for_2and3);
tvalue_sum=abs(squeeze(sum(tvalue_sign,1)));
tvalue_sign_comparisonor=ones(size(tvalue_sum))*size(tvalue_sign,1);
mask=tvalue_sum==tvalue_sign_comparisonor;
shared_2and3=shared_2and3_ahad.*mask~=0;
end

function [distinct_1,distinct_2,distinct_3]=calc_distinct(sum_h_mat,h_mat)
% 当有3种疾病时，计算每一种疾病特异的异常连接(不考虑方向不一致的特有差异)
% input
%   sum_h_mat: 在组的维度对H矩阵求和的结果矩阵
%   h_mat：H矩阵

distinct=sum_h_mat==1;

distinct_1=distinct.*squeeze(h_mat(1,:,:));
distinct_2=distinct.*squeeze(h_mat(2,:,:));
distinct_3=distinct.*squeeze(h_mat(3,:,:));
end