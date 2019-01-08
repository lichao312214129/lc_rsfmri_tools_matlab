function [fileName,folderPath,data] =lc_Img2Data_MultiGroup(ifMultiple,NumOfGroup)
% 将一组或多组.img/.nii转化为.mat数据
% input:
%      NumOfGroup:how many group image
%      ifMultiple='on' OR 'off',是否为多个文件
% output:
%      data{i}:4D matrix,the 4th dimension is equal to NumOfGroup
%      fileNmae{i}: all image's name
%      folderPath{i}: one group image's path
%
%%
if nargin<1
ifMultiple='on';
end
%%
fileName=cell(1,NumOfGroup);
folderPath=cell(1,NumOfGroup);
data=cell(1,NumOfGroup);
for i=1:NumOfGroup
    [fileName{i},folderPath{i},data{i} ] =...
        lc_Img2Data(ifMultiple,['select image in group ',num2str(i)]);
end
end