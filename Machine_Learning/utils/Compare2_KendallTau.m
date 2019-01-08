function  subtract_up= Compare2_KendallTau( data )
% 此函数是为了计算kendall tau 做准备。此函数比较一个1维张量中所有两两数据的大小，并返回差值（上三交矩阵，不包括对角线）。
%输入：1维张量
%输出：差值（上三交矩阵，不包括对角线）。
%作者：黎超 email：lichao19870617@gmail.com
%% 数据准备，转置换
data1=reshape(data,length(data),1);%转为列向量
data2=reshape(data,1,length(data));%转为行向量
%% 两两对子间的差
subtract=data1-data2;
subtract_up=triu(subtract,1);
end

