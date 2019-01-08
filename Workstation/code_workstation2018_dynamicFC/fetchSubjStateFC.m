function fetchSubjStateFC(IDX,k,dFCPath,subjName,outPath)
% 根据kmeans后的IDX以及所有被试的动态连接矩阵（nNode*nNode*nWindow*nSubj）
% 来求得每个人的各个状态的连接矩阵（状态内所有窗的平均）
% 可能某些被试没有某个状态【DOI:10.1002/hbm.23430】
% input
    % IDX:kmeans后的index
    % k:类数
    % dFCPath:动态功能连接矩阵所在文件夹（nNode*nNode*nWindow*nSubj）
    % subjName:所有被试的名字，顺序要一致
    % outPath:结果保存路径
% output
    % 每个被试个体，每个状态的连接矩阵
%%
% dFCPath='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\DynamicFC_length17_step1_screened';
% k=2;
% outPath='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state\allState17_2';
%%
%%
[nRow,~]=size(IDX);
if fix(nRow/numOfSubj)~=nRow/numOfSubj
    fprintf('输入的窗口数目*被试数目与IDX不一致！\n');
    return
else
    numOfWindow=nRow/numOfSubj;
end
%% load dFC
dFCFile=dir(fullfile([dFCPath,'\*.mat']));
dFCName={dFCFile.name}';
dFCPath=dFCFile.folder;
dFCFile=fullfile(dFCPath,dFCName);
%%
numOfSubj=length(subjName);
for ithState=1:k
    outpath=fullfile(outPath,['state',num2str(ithState)]);
    mkdir(outpath);
    fprintf('%d/%d\n',ithState,k);
    %
    startInd=1;
    endInd=numOfWindow;
    for ithSubj=1:numOfSubj
        fprintf('%d/%d\n',ithSubj,numOfSubj);
        idx=IDX(startInd:endInd);
        if ithState<=max(idx)
            dFC=importdata(dFCFile{ithSubj});
            stateFC=mean(dFC(:,:,idx==ithState),3);%平均
            % save
            save(fullfile(outpath,subjName{ithSubj}),'stateFC')
        end
        startInd=startInd+numOfWindow;
        endInd=endInd+numOfWindow;
    end
end
end