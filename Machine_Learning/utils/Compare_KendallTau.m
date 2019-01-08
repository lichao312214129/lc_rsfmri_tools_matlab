function [ location_up_greater,location_up_equal,location_up_less, numb_greater,numb_equal,numb_less]...
          = Compare_KendallTau( data )
% 此函数是为了计算kendall tau 做准备。此函数比较一个1维张量中所有两两数据的大小，并返回位置逻辑矩阵和数目。
%输入：1维张量
%输出：两两数据的大小比较的结果，包括位置和数目。
%作者：黎超 email：lichao198706172gmail.com
%% 数据准备，转置换
data1=reshape(data,length(data),1);%转为列向量
data2=reshape(data,1,length(data));%转为行向量
%% 定位大于的对子位置，计算数目
location_all_greater=data1>data2;
location_up_greater=triu(location_all_greater,1);
numb_greater=sum(location_up_greater(:));
% %% 创建一个mask，用于提取上三角矩阵，不包括对角线
% mask=ones(size(Matrix_all_greater));
% mask=triu(mask,1);
% mask=mask==1;
% %% 提取mask内的Matrix_all
% Matrix_up_greater = Matrix_all_greater(mask);%上三角矩阵，不包括对角线,注意是按逐列从上往下的循序。
%% 定位等于的对子位置，计算数目
location_all_equal=data1==data2;
location_up_equal=triu(location_all_equal,1);
numb_equal=sum(location_up_equal(:));
%% 定位小于的对子位置，计算数目
location_up_less= location_up_equal+location_up_greater;
location_up_less=location_up_less==0;
location_up_less=triu(location_up_less,1);
numb_less=sum(location_up_less(:));
end

