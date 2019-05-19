function [H,P,T]=lc_ttest2_allvsone(dependent_cell,contrast)
% 仅仅将病人组与正常对照两两对比
% 假设总共有4组，正常人组在第四组，则：
% contrast=[1 1 1 0]
n_g = sum(contrast);
patients_groups_ind = find(contrast==1);

% preallocate
fc=(dependent_cell{1});
n_features=size(fc,2);
H=zeros(n_g,n_features);
P=ones(n_g,n_features);
T=zeros(n_g,n_features);
disp('ttest2...')
for i=1:n_g
    ind=patients_groups_ind(i);
    [h,p,~,s] = ttest2(dependent_cell{ind}, dependent_cell{contrast==0});
    t=s.tstat;
    H(i,:)=h;
    P(i,:)=p;
    T(i,:)=t;
end
disp('ttest2 done')
end