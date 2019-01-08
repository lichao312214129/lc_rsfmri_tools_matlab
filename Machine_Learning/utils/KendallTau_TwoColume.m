function kendall_tau = KendallTau_TwoColume( data,subtract_up_label )
%此函数用于两列数的kendall tau计算。
%输入：data为元胞数组，subtract_up_label为矩阵（进过Compare2_KendallTau函数计算）
%% 计算两组的差值
%  subtract_up_label= Compare2_KendallTau( label );
data=cell2mat(data);
 subtract_up_data= Compare2_KendallTau( data );
 %% 计算一致和不一致对子数
 % 乘积
 multi_all=subtract_up_label.*subtract_up_data;
 %计算非零的
 Nc_nozero=sum(multi_all(:)>0);%不为零的一致对
%  Nd_nozero=sum(multi_all(:)<0);%不为零的不一致对
 %计算零的
  loc_zero_label=subtract_up_label==0;
  loc_zero_data=subtract_up_data==0;
  multi_zero=loc_zero_label.*loc_zero_data;
   %创建一个mask，用于提取上三角矩阵，不包括对角线
  mask=ones(size(multi_zero));
  mask=triu(mask,1);
  mask=mask==1;
 Nc_zero=sum(multi_zero(mask));%为零的一致对子数
%  Nd_zero=sum(multi_zero(mask));%为零的不一致对子数
  total=sum(mask(:));
  Nd=total-Nc_nozero-Nc_zero;%不一致数
  %% 计算Kendall Tau
  kendall_tau=(Nc_nozero+Nc_zero-Nd)/total;
end

