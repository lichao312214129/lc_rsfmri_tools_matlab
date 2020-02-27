function [tvalues_full, pvalues_full, coef_full] = compute_structural_covariance(data_dir, mask_seed, mask_whole_brain_data, out_path)
debug = 1;
if debug
    data_dir = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV';
    mask_seed = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_HarvardOxford-cort-maxprob-thr25-2mm.nii';
    mask_whole_brain = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_HarvardOxford-cort-maxprob-thr25-2mm.nii';
    out_path = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan';
end

% All structure data
data_strut = dir(data_dir);
data_path = fullfile(data_dir, {data_strut.name});
data_path = data_path(3:end)';
n_sub = length(data_path);
datafile_path = cell(n_sub,1);
for i = 1: n_sub
    fprintf('%d/%d\n', i, n_sub);
    one_data_strut = dir(data_path{i});
    one_data_path = fullfile(data_path{i}, {one_data_strut.name});
    one_data_path = one_data_path(3:end);
    datafile_path(i) = one_data_path(1);
end
data_all = y_ReadAll(datafile_path);
data_all = reshape(data_all, [],n_sub)';

% Seed mask
[mask_seed, header] = y_Read(mask_seed);
mask_seed = reshape(mask_seed, 1,[]);
mask_seed = mask_seed ~= 0;

% Whole brain mask
mask_whole_brain_data = y_Read(mask_whole_brain);
mask_whole_brain_data = reshape(mask_whole_brain_data, 1,[]);
mask_whole_brain_data = mask_whole_brain_data ~= 0;

% Run
[tvalues_full, pvalues_full, coef_full] = compute_structural_covariance_base(data_all, mask_seed, mask_whole_brain_data);

% Back to orginal dimension
tvalues_full = reshape(tvalues_full, header.dim);
pvalues_full = reshape(pvalues_full, header.dim);
coef_full = reshape(coef_full, header.dim);

% Save
y_Write(tvalues_full, header, fullfile(out_path, 'tvalues.nii'));
y_Write(pvalues_full, header, fullfile(out_path, 'pvalues.nii'));
y_Write(coef_full, header, fullfile(out_path, 'SC.nii'));
end
