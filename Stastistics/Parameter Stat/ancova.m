function [F,P]=ancova(DependentFiles, Covariates)
% 多个预测变量
n_x=size(DependentFiles{1},2);
n_g=length(DependentFiles);
for i=1:n_x
    dependentFiles={};
    for j=1:n_g
        dependentFiles=cat(2,dependentFiles,DependentFiles{j}(:,i));
    end
    [F(i),P(i)] = My_gretna_ANCOVA1(dependentFiles, Covariates);
end
end