function [H,P,T]=my_ttest2(DependentFiles,contrast)
% 仅仅将病人组与正常对照两两对比
% 假设总共有4组，正常人组在第四组，则：
% contrast=[1 1 1 0]
n_g=sum(contrast);
patients_groups_ind=find(contrast==1);

% 预分配
fc=(DependentFiles{1});
n_features=size(fc,2);
H=zeros(n_g,n_features);
P=zeros(n_g,n_features);

for i=1:n_g
    [H(i,:),P(i,:),~,S(i,:)] = ttest2(DependentFiles{patients_groups_ind(i)}, DependentFiles{contrast==0});
end
T={S.tstat}';
T=cell2mat(T);
end