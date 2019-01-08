function [indiceCell]=LoadIndices()
% 载入已有的交叉验证方式
[file_name_indices,path_source_indices,~] = uigetfile({'*.mat;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','请选择 *MVPA.mat');
indices_structure=load([path_source_indices,char(file_name_indices)]);
indiceCell=indices_structure.indiceCell;
end