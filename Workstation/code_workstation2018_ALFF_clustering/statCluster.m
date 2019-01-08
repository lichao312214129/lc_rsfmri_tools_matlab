% 分类后统计类之间的量表差异
scalePath='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\testsScale_plus_predictLabel.xlsx';

[scale,header]=xlsread(scalePath);
hamd=scale(:,8);
hama=scale(:,9);
label=scale(:,end);

id=isnan(hamd)==1;
labelHamd=label(~id);
hamd=hamd(~id);

[h,p]=ttest2(hamd(labelHamd==1),hamd(labelHamd==0));

id=isnan(hama)==1;
labelHama=label(~id);
hama=hama(~id);

[h_hama,p_hama]=ttest2(hama(labelHama==1),hama(labelHama==0));
