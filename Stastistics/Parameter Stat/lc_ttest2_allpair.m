function [H,P,T]=lc_ttest2_allpair(dependent_cell)
% 所有组之间两两对比

n_cmp = length(dependent_cell)*(length(dependent_cell)-1)/2;  % times of compare
n_groups = length(dependent_cell);

% preallocate
H=cell(n_cmp,1);
P=cell(n_cmp,1);
T=cell(n_cmp,1);
disp('post hoc ttest2...')
count = 1;
for i=1: n_groups-1
    for j = i+1: n_groups
        [h,p,~,s] = ttest2(dependent_cell{i}, dependent_cell{j});
        t=s.tstat;
        H{count}=h;
        P{count}=p;
        T{count}=t;
        count = count + 1;
    end
end
H = cell2mat(H);
P = cell2mat(P);
T = cell2mat(T);
disp('post hoc ttest2 done')
end