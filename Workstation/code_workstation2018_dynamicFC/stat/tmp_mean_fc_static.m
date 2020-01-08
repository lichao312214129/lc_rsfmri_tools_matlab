sfc_dir = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\sfc';
sfc = dir(sfc_dir);
sfc_name = {sfc.name}';
sfc_name = sfc_name(3:end);
sfc_subjpath = fullfile(sfc_dir, sfc_name);
n_subj = length(sfc_subjpath);
mat = zeros(n_subj, 114,114);
for i = 1:n_subj
    i
    mat(i, :, :) = importdata(sfc_subjpath{i});
end
median_mat = squeeze(median(mat));
median_mat(isnan(median_mat)) = 0;
median_mat(isinf(median_mat)) = 0;
save('median_static_fc.mat','median_mat');

mean_mat = squeeze(sum(mat))/n_subj;
mean_mat(isnan(mean_mat)) = 0;
mean_mat(isinf(mean_mat)) = 0;
save('mean_static_fc.mat','mean_mat');