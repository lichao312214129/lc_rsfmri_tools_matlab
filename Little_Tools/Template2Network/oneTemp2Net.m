function [prop,uni_network]=oneTemp2Net(oneBrain_parcellation,network_parcellation)
% 计算某个脑区位于不同网络的重叠比列
%     oneBrain_parcellation=zeros(3,3,2);
%     oneBrain_parcellation([1,2,3])=[1,1,1];
%     network_parcellation=rand(3,3,2);
%     network_parcellation([1,2,3])=[1 1 2];

cover_matrix=oneBrain_parcellation.*network_parcellation;
cover_matrix(cover_matrix==0)=[];
uni_network=unique(cover_matrix);
prop=zeros(1,numel(uni_network));
for i=1:numel(uni_network)
    prop(i)=sum(cover_matrix==uni_network(i))/numel(cover_matrix);
end
end