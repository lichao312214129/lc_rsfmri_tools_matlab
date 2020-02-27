function [zvalues_full, pvalues_full, coef_full] = compute_structural_covariance(data_dir, mask_seed, mask_whole_brain, out_path)
% Input
group1_pre = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV_1';
group1_post = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV_2';
group2_pre = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV_3';
group2_post = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\GMV_4';

mask_seed = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_Reslice3_TPM_greaterThan0.2_1.nii';
mask_whole_brain = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\Reslice_Reslice3_TPM_greaterThan0.2_1.nii';

out_path = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan';

[zvalues_group1_pre, pvalues_group1_pre, coef_group1_pre, n_sub_group1_pre] =compute_structural_covariance_one_group(group1_pre, mask_seed, mask_whole_brain, ...
                                        fullfile(out_path, 'results_group1_pre'));
[zvalues_group1_post, pvalues_group1_post, coef_group1_post, n_sub_group1_post]= compute_structural_covariance_one_group(group1_post, mask_seed, mask_whole_brain, ...
                                        fullfile(out_path, 'results_group1_post'));
[zvalues_group2_pre, pvalues_group2_pre, coef_group2_pre, n_sub_group2_pre]= compute_structural_covariance_one_group(group2_pre, mask_seed, mask_whole_brain, ...
                                        fullfile(out_path, 'results_group2_pre'));
[zvalues_group2_post, zvalues_group2_post, coef_group2_post, n_sub_group2_post]= compute_structural_covariance_one_group(group2_post, mask_seed, mask_whole_brain, ...
                                        fullfile(out_path, 'results_group2_post'));

%% Diff  
% post-pre
[zvalue_diff_post_pre_group1,pvalue_diff_post_pre_group1, ~, ~] = ztest2(coef_group1_post, coef_group1_pre, n_sub_group1_post, n_sub_group1_pre);
[zvalue_diff_post_pre_group2,pvalue_diff_post_pre_group2, ~, ~] = ztest2(coef_group2_post, coef_group2_pre, n_sub_group2_post, n_sub_group2_pre);

% single effect
[zvalue_diff_pre,pvalue_diff_pre, CI95_pre_low, CI95_pre_up] = ztest2(coef_group1_pre, coef_group2_pre, n_sub_group1_pre, n_sub_group2_pre);
[zvalue_diff_post, pvalue_diff_post, CI95_post_low, CI95_post_up] = ztest2(coef_group1_post, coef_group2_post, n_sub_group1_post, n_sub_group2_post);

% intersecting effect
% if the 95CI do not cover, then we make sure p < 0.05
% if the 95CI do cover, then we can not make sure p < 0.05, so we only
% select those uncovered x
% h_inter = (CI95_pre_low >= CI95_post_up) | (CI95_post_low >= CI95_pre_up);
[zvalue_diff_inter, pvalue_diff_inter, CI95_post_inter, CI95_post_inter] = ztest2((coef_group1_pre - coef_group2_pre), (coef_group1_post - coef_group2_post), (n_sub_group1_pre + n_sub_group2_pre), (n_sub_group1_post + n_sub_group2_post));

% Save
end


function [zvalue,pvalue] = ztest1(coef, n_sub)
z = atanh(coef);
ddiff = z-0;
SEddiff = 1/sqrt(n_sub-3);
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end

function [zvalue,pvalue, CI95_low, CI95_up] = ztest2(coef1, coef2, n1, n2)
z1 = atanh(coef1);
z2 = atanh(coef2);
ddiff = z1-z2;
SEddiff = sqrt((1/(n1-3)) + (1/(n2-3)));
CI95_low = ddiff-(1.96)*SEddiff;
CI95_up = ddiff+(1.96)*SEddiff;
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end