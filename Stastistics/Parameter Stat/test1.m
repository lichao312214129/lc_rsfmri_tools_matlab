[s, df] = xlsread('allVenousROI_mergeddcminfo.xlsx');
label = s(:,5);
age = s(:,4);
[a,b]=ttest2(age(label==0), age(label==1));
