function indiceCell=generateIndiceForKfoldCV(label,K)
% 为交叉验证产生indices
% input:
%      label:所有被试的标签
%      K：number of K in K-fold cross-validation
% output:
%      indiceCell：1*numOfGroup cell matrix with each cell is a indices array of
%      each group. numOfGroup= the number of group
% Note that crossvalind此处不受随机种子点控制，因此每次结果还是不一样。
%%
numOfGroup=numel(unique(label));
indiceCell=cell(1,numOfGroup);
uniLabel=unique(label);

for ith_group=1:numOfGroup
    LogicIndexOfTempLabel=label==uniLabel(ith_group);
    numOfSubjInOneGroup=sum(LogicIndexOfTempLabel);
    indices = crossvalind('Kfold', numOfSubjInOneGroup, K);
    indiceCell{1,ith_group}=indices ;
end

end