function [label]=generateLabel(dataCell,numOfFeatureType,loadOrderOfData)
% 根据data来产生label，并计算每个group的被试个数
% input：
%      dataCell: cell矩阵，每个cell是一个4D matrix，代表一组被试的全部data，其中dimension 4 is
%      number of subjects
%      NumOfFeatureType: 有多少个特征种类
%      LoadOrderOfFeature：特征的上载方式，比如先把第一组被试的所有特征种类上载，
%      然后...;还是先把所有组的某个特征种类全部上载（LoadOrderOfFeature='groupFirst' OR 'featureTypeFirst'）
% output:
%      label:所有被试的label，N_all*1 array, N_all=number of all
%      subjects；值得注意：当只有两组时，首先load的group的label最大，比如共有2组，则第一个load的group
%      label为2
%      numOfSub: 每组被试的个数, N_group*1，N_group=number of group
%
%
%%
if nargin<3
    loadOrderOfData= 'groupFirst';
end
if nargin <2
    numOfFeatureType=1;
end
%%
numOfImgGroup=numel(dataCell);
label=[];
% 当data只有两个元胞时，说明只有两个组，一个特征种类
if numOfImgGroup==2
    label=[ones(size(dataCell{1},4),1);ones(size(dataCell{2},4),1)+1];
end
%
if numOfImgGroup>2
    % 逐个组上载
    if strcmp(loadOrderOfData,'groupFirst')
        count=0;
        for i=1:numOfFeatureType:numOfImgGroup
            label=cat(1,label,ones(size(dataCell{i},4),1)+count);
            count=count+1;
        end
    end
    % 逐个特征上载
    if strcmp(loadOrderOfData,'featureTypeFirst')
        numOfGroup=numOfImgGroup/numOfFeatureType;
        count=0;
        for i=1:numOfGroup
            label=cat(1,label,ones(size(dataCell{i},4),1)+count);
            count=count+1;
        end
    end
end
end