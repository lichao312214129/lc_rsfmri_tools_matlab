function groupSecdLev=consensusBasedFuzzyClustering(data,numOfCluster,numOfIt)
% usage: consensus-Based Fuzzy Clustering
% please reference 'Brain Subtyping Enhances The Neuroanatomical Discrimination of Schizophrenia'
% /doi/10.1093/schbul/sby008/4911426
% input:
%    data: 2D matrix with the first dimention is number of subjects, the
%    sencond dimension is the number of feature
%    numOfCluster: number of cluster that you want to clustering
%    numOfIt: number of iteration
% output:
%    groupSecdLev: the result of the second level of clustering, with each element is
%    the group of corresponding subject.
%% ===============================================================
% ≤Œ ˝…Ë÷√
options = [2.0 1000 NaN 0];
%% preallocate
% load fcmdata.dat
numOfSubj=size(data,1);
indexLoc=zeros(numOfCluster,numOfSubj);
coClassificationMatrix=ones(numOfSubj,numOfSubj,numOfIt)+1;
%%
% tic;
for i=1:numOfIt
    [~,U] = fcm(data,numOfCluster,options);
    maxU = max(U);
    logLoc=U==maxU;
    indexLocFirstLev=indexLoc;
    for j=1:numOfCluster
        indexLocFirstLev(j,:)=j;
    end
    group=sum(logLoc.*indexLocFirstLev,1);
    groupTransport=group';
    coClassificationMatrix(:,:,i)=groupTransport-group;
    coClassificationMatrix(:,:,i)=coClassificationMatrix(:,:,i)==0;
end
consistencyMatrix=sum(coClassificationMatrix,3);
% toc;
[~,U_SecdLev] = fcm(consistencyMatrix,numOfCluster,options);
    maxU = max(U_SecdLev);
    logLoc=U_SecdLev==maxU;
    indexLocSecdLev=indexLoc;
    for j=1:numOfCluster
        indexLocSecdLev(j,:)=j;
    end
    groupSecdLev=sum(logLoc.*indexLocSecdLev,1);
    groupSecdLev=groupSecdLev';
end