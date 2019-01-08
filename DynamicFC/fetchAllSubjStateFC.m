%% 根据所有人所有窗的IDX，得到个体水平的状态的连接矩阵（状态内窗的评价）
%% length=17
subjName='H:\dynamicFC\state\subjName.mat';
dFCPath='H:\dynamicFC\DynamicFC_length17_step1_screened';
outPath='H:\dynamicFC\state';
indRootPath='H:\dynamicFC\state';
%
subjName=importdata(subjName);
for i=[4,5,8]   
    IDX=importdata( fullfile(indRootPath,['allState17_',num2str(i),'\IDX.mat']));
    outpath=fullfile(outPath,['allState17_',num2str(i)]);
    k=i;
    lc_fetchSubjStateFC(IDX,k,dFCPath,subjName,outpath)
end

%% length=20
subjName='H:\dynamicFC\state\subjName.mat';
dFCPath='H:\dynamicFC\DynamicFC_length20_step1_screened';
outPath='H:\dynamicFC\state';
indRootPath='H:\dynamicFC\state';
%
subjName=importdata(subjName);
for i=[2,4,5,8]   
    IDX=importdata( fullfile(indRootPath,['allState20_',num2str(i),'\IDX.mat']));
    outpath=fullfile(outPath,['allState20_',num2str(i)]);
    k=i;
    lc_fetchSubjStateFC(IDX,k,dFCPath,subjName,outpath)
end