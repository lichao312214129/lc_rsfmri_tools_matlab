function [shared_1and2and3,shared_1and2,shared_1and3,shared_2and3,...
          distinct_1,distinct_2,distinct_3]=...
                lc_calc_shared_and_distinct_for_FCmatrix(h_mat)
% 经过post-hoc之后，找到病人组（对于正常组来说）共同以及特异的异常连接
% SZ & BD & MDD、SZ & BD not MDD、SZ & MDD not BD、BD & MDD not SZ、SZ、BD、MDD
% input
%   H_mat: 经过post-hoc 双样本t检验+FDR校正后的H矩阵（H==1,表示无统计学意义）
%%
if nargin<1
    % input
    path='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\state\allState17_4\state4_all';
    state=4;
    correction_method='fdr';
    
    %
    h_posthoc_corrected=fullfile(path,['state',num2str(state),'\result','\h_posthoc_',correction_method,'.mat']);
    h_mat=importdata(h_posthoc_corrected);
    if_save=1;
    save_path=fullfile(path,['state',num2str(state),'\result']);
end
% 求共同及特异的异常连接（本研究有3种疾病，因此共同包括3个以及2个疾病的共同）
sum_h_mat=squeeze(sum(h_mat));
shared_1and2and3=sum_h_mat==3; %3者共同
[shared_1and2,shared_1and3,shared_2and3]=calc_com2(sum_h_mat,h_mat); %2者共同
[distinct_1,distinct_2,distinct_3]=calc_special(sum_h_mat,h_mat); %每种疾病特异

% save
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

function [com_1and2,com_1and3,com_2and3]=calc_com2(sum_h_mat,h_mat)
% 当有3种疾病时，计算其中任意2个疾病的共同差异（当且仅当2种共同）
% input
%   sum_h_mat: 在组的维度对H矩阵求和的结果矩阵

com_2disorder=sum_h_mat==2;

com_1and2=com_2disorder.*squeeze(h_mat(1,:,:)).*squeeze(h_mat(2,:,:));
com_1and3=com_2disorder.*squeeze(h_mat(1,:,:)).*squeeze(h_mat(3,:,:));
com_2and3=com_2disorder.*squeeze(h_mat(2,:,:)).*squeeze(h_mat(3,:,:));
end

function [distinct_1,distinct_2,distinct_3]=calc_special(sum_h_mat,h_mat)
% 当有3种疾病时，计算每一种疾病特异的异常连接
% input
%   sum_h_mat: 在组的维度对H矩阵求和的结果矩阵

distinct=sum_h_mat==1;

distinct_1=distinct.*squeeze(h_mat(1,:,:));
distinct_2=distinct.*squeeze(h_mat(2,:,:));
distinct_3=distinct.*squeeze(h_mat(3,:,:));
end