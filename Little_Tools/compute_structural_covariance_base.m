function [tvalues_full, pvalues_full, coef_full] = compute_structural_covariance_base(data_all, mask_seed, mask_whole_brain_data)
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
%% --------------------------------------------------
% Filter the whole_brain_intensity using mask
intensity_in_whole_brain_intensity_mask = data_all(:,mask_whole_brain_data);

% Get intensity in seed_mask
intensity_in_seed_mask = data_all(:,mask_seed);
intensity_in_seed_mean = mean(intensity_in_seed_mask, 2);

% Corr
[coef] = corr(intensity_in_seed_mean, intensity_in_whole_brain_intensity_mask);
coef_full =zeros(size(mask_whole_brain_data));
coef_full(mask_whole_brain_data) = coef;

% Get Stat
n_sub = length(intensity_in_seed_mean);
if n_sub <=2
    disp('Sample size less than 2!');
    return;
end
[zvalues, pvalues] = ztest1(coef, n_sub);  % two-tail

tvalues_full = zeros(size(mask_whole_brain_data));
tvalues_full(mask_whole_brain_data) = zvalues;

pvalues_full = zeros(size(mask_whole_brain_data));
pvalues_full(mask_whole_brain_data) = pvalues;
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

function [zvalue,pvalue] = ztest1(rho, n)
z = 0.5*log((1+rho)/(1-rho));
ddiff = z-0;
SEddiff = 1/sqrt(n-3);
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end

function [zvalue,pvalue] = ztest2(rho1, rho2, n1, n2)
z1 = 0.5*log((1+rho1)/(1-rho1));
z2 = 0.5*log((1+rho2)/(1-rho2));
ddiff = z1-z2;
SEddiff = sqrt(1/(n1-3)+1/(n2-3));
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end
