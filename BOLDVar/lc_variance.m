% 计算全脑的变异性(信号的方差)
% 此代码改编自韩少强师兄的代码（Variance_han）
%% ==============================================================
% input
FourDDataPath=('H:\FunImgARWDFCB'); % 4D 数据目录:[../subjxxx/*.nii]*nSubj
keyword='*nii'; % 当一个被试文件夹下有几个file时，选择的正则式(只能选择第一个).
maskPath='H:\dynamicALFF\Results\DALFF\50_0.9\Statistical_Results\GrayMask_Reslice3_greaterThan0.2.nii';
threshold=0.2;
outPath=('H:\Var');
%% ==============================================================
% load mask
mask=load_nii(maskPath);
mask=mask.img>threshold;
% fetch all path of all subject 4D data file
allFolderName=dir(FourDDataPath);
allFolderName=allFolderName(3:end);
allFolderName={allFolderName.name}';
%
 if iscell(allFolderName)
    nSubj=length(allFolderName);
 else
     warning('被试名称有误?');
 end
%% ==============================================================
parpool(6);
parfor i=1:nSubj
    fprintf('%d/%d\n',i,nSubj);
    oneFolderName=fullfile(FourDDataPath,allFolderName{i});
    oneFolderName=dir(fullfile(oneFolderName,keyword));
    oneFolderName=oneFolderName.name; % 有多个时，只选择第一个
    [oneFourDData,header] =y_Read(fullfile(FourDDataPath,allFolderName{i},oneFolderName));
%     oneFourDData(~mask,:)=0;
    BOLDVar=var(oneFourDData,0,4);
    BOLDVar(~mask)=0; % apply mask
    % 去极值（均值加3个标准差）
    myMean=mean(BOLDVar(:));
    myStd=std(BOLDVar(:));
    BOLDVar(BOLDVar>myMean+3*myStd|BOLDVar<myMean-3*myStd)=0;
    % save to nii
    saveSubFolder=fullfile(outPath,allFolderName{i});
    mkdir(saveSubFolder);
    y_Write(BOLDVar,header,fullfile(saveSubFolder,['BOLDVar_',allFolderName{i},'.nii']));
end
    