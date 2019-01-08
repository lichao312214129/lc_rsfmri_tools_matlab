function [label_net] = template2Network(brain_parcellation,network)
% 将某个脑分区模板的各个脑区映射到相应的脑网络模板上（根据体素重叠比例）。
% 具体方法请参考{Chronnectome fingerprinting: Identifying individuals and
% predicting higher cognitive functions using dynamic brain connectivity patterns}
%   input:
%       brain_parcellation:脑分区矩阵
%       network_parcellation:网络分区矩阵
%   output:
%       network_label:各个脑区对应的网络label
%%
uni_region=unique(brain_parcellation);
%     sparse(brain_parcellation)
n_region=numel(uni_region);
prop=cell(n_region,1);
uni_net=cell(n_region,1);
label_net=zeros(n_region,1);
for i =1:n_region
    fprintf('%d/%d\n',i,n_region)
    oneBrain_parcellation=brain_parcellation==uni_region(i);
    [prop{i,1},uni_net{i,1}]=oneTemp2Net(oneBrain_parcellation,network);
    loc_max_prop=find(prop{i,1}==max(prop{i,1}));
    if ~isempty(loc_max_prop)
        loc_max_prop=loc_max_prop(1);
        label_net(i)=uni_net{i,1}(loc_max_prop);
    else
        label_net(i)=0;
    end
end
end





