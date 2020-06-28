function cohen_d = lc_calc_cohen_d_effective_size(group1, group2)
% Calculate Cohen' d 
% INPUTs:
%     group1:   dimension is n_samples * n_features
%     group2:   dimension is n_samples * n_features

% OUTPUTS: float
%     Cohen' d 
    
diff = mean(group1) - mean(group2);

n1 = length(group1);
n2 =  length(group2);
var1 = var(group1);
var2 = var(group2);

pooled_var = ((n1 -1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2);
cohen_d = diff ./ sqrt(pooled_var);