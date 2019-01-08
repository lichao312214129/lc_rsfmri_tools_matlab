% input
imgPath='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\validation_wholeBrain_all';
labelFile='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\predictLabel_testData.xlsx';
toFolder='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\validation_wholeBrain_a';

%
prdLabel=xlsread(labelFile);

%
subStrut=dir(fullfile(imgPath,'*.nii.gz'));
subj={subStrut.name}';
subj=subj(1:282);
subj_a=subj(prdLabel==1);

% copy subject alff
n=numel(subj_a);
for i=1:n
    fprintf('%d/%d\n',i,n)
    beCopyFile=fullfile(imgPath,subj_a{i});
    movefile(beCopyFile,toFolder);
end