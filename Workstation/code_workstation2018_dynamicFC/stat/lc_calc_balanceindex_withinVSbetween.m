function balance_idx = lc_calc_balanceindex_withinVSbetween(fcmatrix, netid, mask)
% Used to calculate balance index between within-network FC and between-network FC (Equal to mean within-network FC divided by mean between-network FC)
% INPUT:
% 	fcmatrix: functional connectivity matrix
%   netid: network id
%   mask: have the same dimension with fcmatrix
% OUTPUT:
%   balance_idx: balance index between within-network FC and between-network FC
% net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';
% netid = importdata(net_index_path);
% within-network fc
nnode = size(fcmatrix,1);
mask_triu = triu(ones(nnode),1)==1;

nnet = length(unique(netid));
flatten_wn = cell(nnet,1);
for i = 1:nnet
    % intersect of current netid and mask
    masknet = zeros(114);
    masknet(netid==i,netid==i) = 1;
    masknet = masknet == 1;
    maskextract = masknet .* mask .* mask_triu;
    maskextract = maskextract ==1;
    
    % extract current subnet
    subnet = fcmatrix(maskextract);
    flatten_wn{i} = subnet;
end
flatten_wn = cell2mat(flatten_wn);
mean_intra = mean(flatten_wn);

% between-network fc
mask_bn = mask_triu .* mask == 1;
triu_net = fcmatrix(mask_bn);


bn_sum = sum(triu_net) - sum(flatten_wn);
bn_num = numel(triu_net) - numel(flatten_wn);
mean_inter = bn_sum/bn_num;

% balance index
balance_idx = exp(mean_intra)/exp(mean_inter);
% balance_idx = mean_intra;
end