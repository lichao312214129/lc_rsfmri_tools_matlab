function [pvalues_full_fwe, coef_real_full, coef_rand_full, n_sub] = compute_structural_covariance_one_group(data_dir, mask_seed, mask_whole_brain, n_perm, out_path)
% debug = 0;
% if debug
%     data_dir = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV';
%     mask_seed = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_HarvardOxford-cort-maxprob-thr25-2mm.nii';
%     mask_whole_brain = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_HarvardOxford-cort-maxprob-thr25-2mm.nii';
%     n_boot: int
%       how many times of bootstrapping
%     out_path = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan';
% end

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
[pvalues_full_fwe, coef_real_full, coef_rand_full] = compute_structural_covariance_base(data_all, mask_seed, mask_whole_brain_data, n_perm);

% Back to orginal dimension
pvalues_full_fwe = reshape(pvalues_full_fwe, header.dim);
coef_real_full = reshape(coef_real_full, header.dim);
% coef_rand_full = reshape(coef_rand_full, [n_perm, header.dim]);
% Save
if ~exist(out_path)
    mkdir(out_path);
end
y_Write(pvalues_full_fwe, header, fullfile(out_path, 'pvalues_fwe.nii'));
y_Write(coef_real_full, header, fullfile(out_path, 'SC.nii'));
end

function [pvalues_fwe, coef_real_full, coef_rand_full] = compute_structural_covariance_base(data_all, mask_seed, mask_whole_brain_data, n_perm)
% GOAL: This function is used to compute structural covariance (structural
% connectivity) based on seed region's structure.
% Connectivity is constructed according to inter-individual structure covariance between region pair.
% Inputs:
% -------
%   data_all: .mat  matrix
%       whole brain intensity, dimension: n_samples * n_voxel

%   mask_seed:  .mat row vector
%       seed region's intensity, dimension: dimension, 1 * n_voxel

%   whole_brain_intensity_mask:  .mat  matrix
%       mask of whole brain intensity, dimension, 1 * n_voxel
%   n_boot: int
%       how many times of bootstrapping
%% --------------------------------------------------
% Filter the whole_brain_intensity using mask
intensity_in_whole_brain_intensity_mask = data_all(:,mask_whole_brain_data);

% Get intensity in seed_mask
intensity_in_seed_mask = data_all(:,mask_seed);
intensity_in_seed_mean = mean(intensity_in_seed_mask, 2);
% Corr
[coef] = corr(intensity_in_seed_mean, intensity_in_whole_brain_intensity_mask);
coef(isnan(coef)) = 0;
coef_real_full =zeros(size(mask_whole_brain_data));
coef_real_full(mask_whole_brain_data) = coef;

% Bootstrap test for correlation analysis.
% n_boot = 1000;
coef_rand_all = zeros(n_perm, sum(mask_whole_brain_data));
n_greater = 0;
for i = 1 : n_perm
    rand_idx = randperm(size(data_all,1));
    [coef_rand] = corr(intensity_in_seed_mean(rand_idx,:), intensity_in_whole_brain_intensity_mask);
    coef_rand_all(i, :) = coef_rand;
    n_greater =  n_greater + (coef < max(abs(coef_rand)));  % FWE correction
end
pvalues_ttest1_fwe = (n_greater + 1) / (n_perm + 1);
coef_rand_all(isnan(coef_rand_all)) = 0;
coef_rand_full =zeros(n_perm, size(mask_whole_brain_data, 2));
coef_rand_full(:, mask_whole_brain_data) = coef_rand_all;

% Get Stat
n_sub = length(intensity_in_seed_mean);
if n_sub <=2
    disp('Sample size less than 2!');
    return;
end
% [zvalues, pvalues] = ztest1(coef, n_sub);  % two-tail

% tvalues_full = zeros(size(mask_whole_brain_data));
% tvalues_full(mask_whole_brain_data) = zvalues;

pvalues_fwe = zeros(size(mask_whole_brain_data));
pvalues_fwe(mask_whole_brain_data) = pvalues_ttest1_fwe;
end

function [t, p] = compute_pval_for_pearson(rho, n, tail)
% Revised from matlab.
% compute p values for pearson's correlation
t = rho.*sqrt((n-2)./(1-rho.^2)); % +/- Inf where rho == 1
switch tail
    case 'b' % both
        p = 2*tcdf(-abs(t),n-2);
    case 'r' % 'right'
        p = tcdf(-t,n-2);
    case 'l' % 'left'
        p = tcdf(t,n-2);
end
end

function [zvalue,pvalue] = ztest1(coef, n_sub)
z = atanh(coef);
ddiff = z-0;
SEddiff = 1/sqrt(n_sub-3);
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end

