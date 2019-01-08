function [ P_value] = CalculatePvalue_PermutationTest( statistic, Null_hypothesis )
%根据置换检验得到的零假设计算统计量的单尾P值
%   input：statistic =统计量；
%   input：Null_hypothesis =零假设。
P_value=(sum(Null_hypothesis>=statistic)+1)/(numel(Null_hypothesis)+1);
end

