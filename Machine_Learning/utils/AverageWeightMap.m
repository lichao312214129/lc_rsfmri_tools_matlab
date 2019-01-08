function meanBrainWeight=AverageWeightMap(brainWeight,percentage_consensus)
% 将经过K-fold CV后产生的weight进行平均，并将K-fold CV中低于某个出现频率的weight设为0。
% input:
%    brainWeight: 3D matrix. Dimension 1 is equal to the number of feature subsets
%    Dimension 2 is equal to the number of voxels
%    Dimension 3 is equal to the number of K(K-fold)
%    percentage_consensus：K-fold CV中出现的频率阈值。<percentage_consensus的会设为0
% output
%    meanBrainWeight：经过频率筛选的平均weight：2D matrix with dimension 1is equal to
%    the number of feature subsets， dimension 2 is equal to the number of voxels
%% 
[~,~,dim3]=size(brainWeight);
    binary_mask=brainWeight~=0;
    sum_binary_mask=sum(binary_mask,3);
    loc_consensus=sum_binary_mask>=percentage_consensus*dim3; 
%     num_consensus=sum(loc_consensus,2)';%location and number of consensus weight
    meanBrainWeight=mean(brainWeight,3);%取所有fold的 W_Brain的平均值
    meanBrainWeight(~loc_consensus)=0;%set weights located in the no consensus location to zero.
end