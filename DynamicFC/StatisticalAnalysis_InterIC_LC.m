function  [p_static, p_dynamic]=StatisticalAnalysis_InterIC_LC(ZFC,id)
% 计算出网络间的连接矩阵（静态与动态）后的统计分析代码
%注意：但网络特别多时不适用，因为内存会溢出，此时换另一个代码：StatisticalAnalysis_InterROI_LC(
%input：
    % ZFC：网络间的静态和动态功能连接矩阵
    % id：感兴趣网络的id
% output：  
    % h_static/dynamic:静态及动态功能连接统计分析的显著情况
    % p_static/dynamic：静态及动态功能连接统计分析的p值
% id=[9,19,20,22,24,26,28];%感兴趣网络
% idp=[33 34 36 37 38 39 41 43 46  50 57];
%% 静态功能连接统计
dp_static=ZFC_static(:,:,1:36);
dc_static=ZFC_static(:,:,37:end);
dp_static(isinf(dp_static))=1;
dc_static(isinf(dc_static))=1;
%
num_fc=size(dp_static,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=dp_static(i,j,:);stat_c=dc_static(i,j,:);
        [h_static(i,j),p_static(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
%上三角（不包括对角线）的数据提取
mask_triu=ones(size(p_static));
mask_triu(tril(mask_triu)==1)=0;
p_static_triu=p_static(mask_triu==1);
%fdr correction
[p_fdr,h_fdr]=BAT_fdr(p_static_triu,0.05);
%let h_fdr back to matrix
h_back=zeros(size(p_static));
h_back(mask_triu==1)=h_fdr;
clear h_fdr;h_fdr=h_back;
% 感兴趣网络间的结果
% h_static=h_static(id,id);
% p_static=p_static(id,id);

%% 动态功能连接统计
%标准差
std_dynamic=std(ZFC_dynamic,0,4);
dp_dynamic=std_dynamic(:,:,1:36);
dc_dynamic=std_dynamic(:,:,37:end);
dp_dynamic(isnan(dp_dynamic))=0;
dc_dynamic(isnan(dc_dynamic))=0;
%
num_fc=size(dp_dynamic,1);
for i=1:num_fc
    for j=1:num_fc
        stat_p=dp_dynamic(i,j,:);stat_c=dc_dynamic(i,j,:);
        [h_dynamic(i,j),p_dynamic(i,j)]=ttest2(stat_p(:),stat_c(:));
    end
end
% 感兴趣网络间的结果
% h_dynamic=h_dynamic(id,id);
p_dynamic=p_dynamic(id,id);
end