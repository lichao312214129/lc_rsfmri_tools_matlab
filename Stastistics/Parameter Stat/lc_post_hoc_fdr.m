function [h_fdr] = lc_post_hoc_fdr(P,correction_threshold, correction_method)
% P的维度=n_group*n_features
% 对象：所有组的某个特征，迭代直到所有特征校正结束
[n_g,n_f]=size(P);
h_fdr=zeros(n_g,n_f);
for i=1:n_f
    if strcmp(correction_method,'fdr')
        results=multcomp_fdr_bh(P(:,i),'alpha', correction_threshold);
    elseif strcmp(correction_method,'fwd')
        results=multcomp_bonferroni(P(:,i),'alpha', correction_threshold);
    else
        fprintf('Please indicate the correct correction method!\n');
    end
    h_fdr(:,i)=results.corrected_h;
end
end