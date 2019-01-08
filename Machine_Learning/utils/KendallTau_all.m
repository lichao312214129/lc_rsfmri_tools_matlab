function kendall_tau_all = KendallTau_all( data,label )
% 此函数用来计算Kendall tau,7000个特征需要2秒左右，6*10^4个特征大概需要16秒
%输入：data，2D张量；label，列向量
%输出：每一个特征的Kendall tau
%% 数据准备
f=@Compare2_KendallTau;
subtract_up_label= f( label );
data=data';%转置，便于后面将一列特征放到cell的一个小格里
[m,n]=size(data);
data=mat2cell(data,ones(1,m),n);%将data转为cell
%% 计算所有特征的Kendall tau
kendall_tau_all=arrayfun(@KendallTau,data);
%% 亚函数
function kendall_tau = KendallTau( data1)
%此函数用于两列数的kendall tau计算。
%输入：data为元胞数组，subtract_up_label为矩阵（进过Compare2_KendallTau函数计算）
%% 计算两组的差值
%  subtract_up_label= Compare2_KendallTau( label );
data1=cell2mat(data1);
 subtract_up_data= f( data1 );
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
%%
function  subtract_up= Compare2_KendallTau( data )
% 此函数是为了计算kendall tau 做准备。此函数比较一个1维张量中所有两两数据的大小，并返回差值（上三交矩阵，不包括对角线）。
%输入：1维张量
%输出：差值（上三交矩阵，不包括对角线）。
%作者：黎超 email：lichao198706172gmail.com
%% 数据准备，转置换
data1=reshape(data,length(data),1);%转为列向量
data2=reshape(data,1,length(data));%转为行向量
%% 两两对子间的差
subtract=data1-data2;
subtract_up=triu(subtract,1);
end
end


