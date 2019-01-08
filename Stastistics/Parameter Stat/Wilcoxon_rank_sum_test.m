function [ p,h,stats] = Wilcoxon_rank_sum_test( x,y )
% usage: 两独立样本的非参数检验.
% The Wilcoxon rank sum test is equivalent to the Mann-Whitney U-test.
% The Mann-Whitney U-test is a nonparametric test for equality of population medians of two independent samples X and Y.
% [p,h,stats] = ranksum(x,y,'alpha',0.01,'tail','left','method','exact');if
% the N were small, use ('method','exact')
[p,h,stats] = ranksum(x,y,'alpha',0.05,'tail','both');
end

