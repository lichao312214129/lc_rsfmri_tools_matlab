function [zvalue,pvalue] = ztest1(coef, n_sub)
z = atanh(coef);
ddiff = z-0;
SEddiff = 1/sqrt(n_sub-3);
zvalue = ddiff/SEddiff;
pvalue = 2 *(1- normcdf(abs(zvalue)));
end
