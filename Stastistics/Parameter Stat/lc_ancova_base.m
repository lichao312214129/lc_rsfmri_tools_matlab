function [F, P] = lc_ancova_base(dependent_cell, covariates)
% Multiple Predictive Variables

disp('performing ancova for all dependent variables...\n')
n_y = size(dependent_cell{1}, 2);  % how many dependent variables
n_group = length(dependent_cell);  % how many groups

% pre-allocation
fc = (dependent_cell{1});
n_features = size(fc,2);
F = zeros(1,n_features);
P = zeros(1,n_features);

for ith_dependent_var = 1 : n_y
    dependent_var = {};
    for group = 1 : n_group
        dependent_var = cat(2,dependent_var,dependent_cell{group}(:,ith_dependent_var));
    end
    [F(ith_dependent_var),P(ith_dependent_var)] = lc_gretna_ANCOVA1(dependent_var, covariates);
end
end