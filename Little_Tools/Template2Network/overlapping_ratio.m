function [prop,uni_network]=overlapping_ratio(one_area, all_area)
% This function is used to calculate the overlapping ratio of voxels between 
% one brain area and different brain area.
% one_area=zeros(3,3,2);
% one_area([1,2,3])=[1,1,1];
% all_area=rand(3,3,2);
% all_area([1,2,3])=[1 1 2];

cover_matrix=one_area.*all_area;
cover_matrix(cover_matrix==0)=[];
uni_network=unique(cover_matrix);
prop=zeros(1,numel(uni_network));
for i=1:numel(uni_network)
    prop(i)=sum(cover_matrix==uni_network(i))/numel(cover_matrix);
end
end
