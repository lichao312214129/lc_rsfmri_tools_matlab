function [ Signal] = Extract_ROI_Signal3D(numOfVolume)
% usage: extract multiple signals from 3D or 4D data. If 4D data, the dimension 4 is the volume/time point
% input:
%     data:5D data, dimension 4 is volume/time point,dimension 5 is the number of subjects;
%     mask:3D logic matrix, equal to a volume.
%     numOfVolume= number of volume
% output:
%     signals: N*M, N=number of subjects, M=number of volume/time points.
%% path to save results
pathOfResult=uigetdir({},'选择结果保持路径');
mkdir(pathOfResult,'Signals');
%% mask
[nameOfMask,pathOfMaks,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','选择mask');
fullNameOfMask=fullfile(pathOfMaks,nameOfMask);
try
    mask=load_nii(fullNameOfMask);
    mask=mask.img;
catch
    mask=y_Read(fullNameOfMask);
end
mask=mask~=0;
%% extract signal
dirContainAllSubj=uigetdir({},'选择所有被试的4D .img/.nii 文件所在文件夹');
dirOfAllSubj=dir(dirContainAllSubj);
nameOfAllSubj={dirOfAllSubj.name};
nameOfAllSubj=nameOfAllSubj(3:end)';
pathOfAllSubj=fullfile(dirContainAllSubj,nameOfAllSubj);
numOfSubj=length(pathOfAllSubj);
% preallocate
Signal=zeros(numOfSubj,numOfVolume);
% extract signal according subject's order
for i=1:numOfSubj
    if mod(i,10)==0
        fprintf('%.0f%%\n',i*100/numOfSubj);
    else
        fprintf('%.0f%%\t',i*100/numOfSubj);
    end
    pathOfImgName=pathOfAllSubj{i};
    try
        [data,header]=y_Read(char(pathOfImgName));
    catch
        dataStrut=load_nii(char(pathOfImgName));
        data=dataStrut.img;
    end
    dataInMask=data.*mask;
    % save
    y_Write( dataInMask,header,[pathOfResult,filesep,nameOfAllSubj{i}]);
end
% %% save all signal
% save([pathOfSignal,filesep,'signalAllSubj_From_',nameOfMask,'.mat'],'Signal');
% fprintf('\n===============Completed!===================\n');
end

