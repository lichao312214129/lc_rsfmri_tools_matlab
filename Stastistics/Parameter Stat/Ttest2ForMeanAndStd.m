function [t,p] = Ttest2ForMeanAndStd(mean1,std1,n1,mean2,std2,n2)
%根据均数和标准差求两独立样本t检验的t值,以及双尾的p值
%   input:均数mean,标准差std以及样本量n
%   outpu: 两独立样本t检验的t值及p值
df=n1+n2-2;
numerator=mean1-mean2;
denominator=sqrt(((((n1-1)*(std1^2))+((n2-1)*(std2^2)))/df)*(1/n1+1/n2));
t=numerator/denominator;
p = 1-tcdf(abs(t),df);%single tail:right
p=2*p;%two-tail
end

