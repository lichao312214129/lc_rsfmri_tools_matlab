function [h_fdr] = post_hoc_fdr(pvalues,correction_threshold, correction_method)
[n_g,n_f]=size(pvalues);
h_fdr=zeros(n_g,n_f);
for i=1:n_f
    if strcmp(correction_method,'fdr')
        results=multcomp_fdr_bh(pvalues(:,i),'alpha', correction_threshold);
    elseif strcmp(correction_method,'fwe')
        results=multcomp_bonferroni(pvalues(:,i),'alpha', correction_threshold);
    else
        fprintf('Please indicate the correct correction method!\n');
    end
    h_fdr(:,i)=results.corrected_h;
end
end