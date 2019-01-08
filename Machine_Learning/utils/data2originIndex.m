function dataOrigin=data2originIndex(indexSet,data,length_dataOrigin)
% usage：将indexSet元胞矩阵最后的index对应的data投射到原始dataOrigin中
% indexSet中每一个cell中的index都是上一个index经过筛选后得到的index
% 比如：indexSet共2层（2个cell），第1层index为[3 4 5 6],第2层index为[1 4]，且第2层的data为[12 13],
% 则对应到原始数据dataOrigin后，dataOrigin的第3和第6个数据点=data，其他数据点为0
% 此代码初试目的是：在进行MVPA时，会得到各个筛选出特征的weight，为了形成.nii图像，
% 需要把此weight投射都与原始data相同的size空间中。
% input：
%      indexSet: 1*N cell，每个cell代表一层运算后的index
%      length_dataOrigin:原始数据的长度1*length_dataOrigin，代码会自动生产一个1：length_dataOrigin的0矩阵
% output:
%     dataOrigin:最底层data对应到原始数据后的数据，注意：没有对应的index的数据设为0
%% ===============================================================
ind1=indexSet{end};
for i=numel(indexSet)-1:-1:1
    ind3=ind1;
    ind2=indexSet{i};
    ind1=ind2(ind3);
end
dataOrigin=zeros(1,length_dataOrigin);
dataOrigin(ind1)=data;
end