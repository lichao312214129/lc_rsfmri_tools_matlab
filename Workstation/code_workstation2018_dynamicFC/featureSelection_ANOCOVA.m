function [F,P]=featureSelection_ANOCOVA(data,label, Covariates)
% usage: 利用ANOCOVA进行特征筛选（支持去除协变量）
% input：
%        data：2D matrix，with dimension 1 is number of subjects，dimension 2
%        is number of features
%        label：1D array
%        Covariates：2D matrix，with dimension 1 is number of subjects，dimension 2
%        is number of Covariates
% output：
%        F: F statistics,
%        P: P values;
%        *:如有必要，可以输出其他结果。比如beta 等
%% preallocate

%%
uniLabel=unique(label);
DependentFiles=cell(1,numel(uniLabel));
for i=1:numel(uniLabel)
    DependentFiles{1,i}=data(label==uniLabel(i),:);
end
% tic;[F, P] = My_gretna_ANCOVA1({a,b},[]);toc
% tic;[h,p]=ttest2(a,b);toc
[F, P] = My_gretna_ANCOVA1(DependentFiles, Covariates);% 使用GRETNA的代码，注意要引用。
end