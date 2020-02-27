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