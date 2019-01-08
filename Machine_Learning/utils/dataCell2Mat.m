function [dataMatCell,nameFirstModality]=dataCell2Mat(dataCell,fileName,numOfFeatureType,loadOrderOfData)
% 把data的cell形式转换为data的.mat形式，并根据被试的名字顺序调整data的顺序，以方便后续的处理
% input：
%      dataCell: cell矩阵，每个cell是一个4D matrix，代表一组被试的全部data，其中dimension 4 is the number of subjects
%      NumOfFeatureType: how many type of feature (such as 2 modality: fmri and structure)
%      LoadOrderOfData：data的上载方式，比如先把第一组被试的所有特征种类上载，
%      然后...;还是先把所有组的某个特征种类全部上载（LoadOrderOfFeature='groupFirst' OR 'featureTypeFirst'）
%      fileName:所有被试的名字。A 1* N_group cell, according which the potential different order of individual data
%      were changed into the same order
% output:
%      dataMatCell:cell matrix with dimension 1*NumOfFeatureType. 每一个cell是一个特征的所有数据，维度=dim1*dim2*dim3*N_allSub
%      nameFirstFeature:all subjects' name of the first modality, Note.
%      data order of other modalities were re-ranked according the first
%      one
%%
if nargin<4
    loadOrderOfData= 'groupFirst';
end
if nargin <3
    numOfFeatureType=1;
end
%%
numOfImgGroup=numel(dataCell);
numOfGroup=numOfImgGroup/numOfFeatureType;
dataMatCell=cell(1,numOfFeatureType);
Name=cell(1,numOfFeatureType);
% 当data只有两个元胞时，说明只有两个组，一个特征种类
% if numOfImgGroup==2
%     dataMatCell{1}=cat(4,dataCell{1},dataCell{2});
%     Name=cat(1,fileName{1},fileName{2});
% end
%
if numOfImgGroup>=2
    % 逐个组上载
    if strcmp(loadOrderOfData,'groupFirst')
        % 不考虑名字顺序，先组合数据
        for i=1:numOfFeatureType
            dataMat=[];
            name=[];
            countF=1;
            for j=i:numOfFeatureType:numOfImgGroup
                dataMat=cat(4,dataMat,dataCell{j});
                f=@(x) strcat(['G',num2str(countF),'_'],x);
                name_temp=cellfun(f,fileName{j},'UniformOutput',false);
                name=cat(1,name,name_temp);
                countF=countF+1;
            end
            dataMatCell{i}=dataMat;%某个特征的多组数据
            Name{i}=name;
        end
        % 考虑到名字的顺序(全部根据第一个特征的所有被试的名字顺序)，调整顺序
        for i=2:numOfFeatureType
            [~,index]=ismember(Name{i},Name{1});
            data_temp=dataMatCell{i};
            dataMatCell{i}=data_temp(:,:,:,index);
        end
    end
    % 逐个特征上载
    if strcmp(loadOrderOfData,'featureTypeFirst')
        countF=1;
        for i=1:numOfGroup:numOfImgGroup
            dataMat=[];
            name=[];
            countG=1;
            for j=i:1:i+numOfGroup-1
                dataMat=cat(4,dataMat,dataCell{j});
                f=@(x) strcat(['G',num2str(countG),'_'],x);
                name_temp=cellfun(f,fileName{j},'UniformOutput',false);
                name=cat(1,name,name_temp);
                countG=countG+1;
            end
            dataMatCell{countF}=dataMat;%某个特征的多组数据
            Name{countF}=name;
            countF=countF+1;
        end
        % 考虑到名字的顺序(全部根据第一个特征的所有被试的名字顺序)，调整顺序
        for i=2:numOfFeatureType
            [~,index]=ismember(Name{i},Name{1});
            data_temp=dataMatCell{i};
            dataMatCell{i}=data_temp(:,:,:,index);
        end
    end
end
nameFirstModality=Name{1};
end