%%
% 功能：把所有状态的metrics计算出来
%% input
numOfSubj=680;
subjName=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\subjName.mat');
%
IDX_17_2=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_2\IDX.mat');
IDX_17_4=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_4\IDX.mat');
IDX_17_5=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_5\IDX.mat');
IDX_17_8=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_8\IDX.mat');
%
IDX_20_2=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_2\IDX.mat');
IDX_20_4=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_4\IDX.mat');
IDX_20_5=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_5\IDX.mat');
IDX_20_8=importdata('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_8\IDX.mat');
%
k_17_2=2;
k_17_4=4;
k_17_5=5;
k_17_8=8;

k_20_2=2;
k_20_4=4;
k_20_5=5;
k_20_8=8;
%
outPath_17_2='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_2';
outPath_17_4='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_4';
outPath_17_5='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_5';
outPath_17_8='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_8';

outPath_20_2='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_2';
outPath_20_4='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_4';
outPath_20_5='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_5';
outPath_20_8='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState20_8';
%%
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_17_2,k_17_2,subjName,numOfSubj,outPath_17_2);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_17_4,k_17_4,subjName,numOfSubj,outPath_17_4);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_17_5,k_17_5,subjName,numOfSubj,outPath_17_5);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_17_8,k_17_8,subjName,numOfSubj,outPath_17_8);

stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_20_2,k_20_2,subjName,numOfSubj,outPath_20_2);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_20_4,k_20_4,subjName,numOfSubj,outPath_20_4);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_20_5,k_20_5,subjName,numOfSubj,outPath_20_5);
stateVectorStats=lc_dynamicFC_stateVectorStats(IDX_20_8,k_20_8,subjName,numOfSubj,outPath_20_8);