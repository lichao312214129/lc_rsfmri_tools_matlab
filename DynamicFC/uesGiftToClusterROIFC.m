%% 使用gift的代码，为ROI wise的dynamic FC聚类
%% input
allInfo='D:\WorkStation_2018\WorkStation_2018_07_DynamicFC_insomnia\Results_ICAComponent\lc_ica_parameter_info.mat';
dfncInfoPath='D:\WorkStation_2018\WorkStation_2018_07_DynamicFC_insomnia\Results20181026\lc_dfnc.mat';
% load
load(allInfo);
load(dfncInfoPath)
%
sourceNii={sesInfo.inputFiles.name};
% ROI
dfncInfo.userInput.compFiles

