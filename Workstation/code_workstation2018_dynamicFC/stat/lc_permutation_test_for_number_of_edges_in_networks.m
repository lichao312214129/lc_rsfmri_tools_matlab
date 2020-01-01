function pvalues = lc_permutation_test_for_number_of_edges_in_networks(real_network, net_index_of_nodes, num_perm)
% This function is used to test that testing whether significant edges tended to
% fall within specific networks than would be expected by chance.
% Input: 
%       real_network: The real adjacency matrix of G (N*N, symmetric).
%       net_index_of_nodes: The network index of all nodes. 
%       interest_network_id: The interest network that should be calculated p values.
%       num_perm:  The number of permutations.
% Output:
%       pvalues: The p values of each interest network.
%==========================================================================
real_network = shared_1and2and3;
net_index = 'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
%%
net_index = importdata(net_index);
num_perm = 5000;
num_networks = numel(unique(net_index));
%% Real radio
ratio_real_net = zeros(num_networks, num_networks);
for  i= 1:num_networks
    for j = 1:num_networks
        real_subnet = real_network(net_index ==i, net_index == j);
        ratio_real_net(i, j) = sum(real_subnet(:))/numel(real_subnet);
    end
end
%% Generate random networks
ratio_rand_net = zeros(num_perm, num_networks, num_networks);
for i = 1:num_perm
    rand_network = gretna_gen_random_network1(real_network);
    for  j= 1:num_networks
        for k = 1:num_networks
            rand_subnet = rand_network(net_index ==j, net_index == k);
            ratio_rand_net(i, j, k) = sum(rand_subnet(:))/numel(rand_subnet);
        end
    end
end

% Calc p values
pvalues = ones(num_networks,num_networks);
for i =  1:num_networks
    for j = 1:num_networks
        pvalues(i,j) = (sum(ratio_real_net(i,j) <= ratio_rand_net(:,i,j))) / num_perm;
    end
end
