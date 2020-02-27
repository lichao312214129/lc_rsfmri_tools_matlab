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