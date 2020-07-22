function pvalues = lc_permutation_test_for_number_of_edges_in_networks(real_network, net_index_of_nodes, num_perm)
% This function is used to test that testing whether significant edges tended to
% fall within specific networks than would be expected by chance.
% This function used function "gretna_gen_random_network1.m" which is part of GRETNA.
% Input: 
%       real_network: The real adjacency matrix of G (N*N, symmetric).
%       net_index_of_nodes: The network index of all nodes. 
%       interest_network_id: The interest network that should be calculated p values.
%       num_perm:  The number of permutations.
% Output:
%       pvalues: The p values of each interest network.
%% ==========================================================================
real_network = shared_1and2and3;
net_index_of_nodes = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';

%%
net_index_of_nodes = importdata(net_index_of_nodes);
num_perm = 5000;
num_networks = numel(unique(net_index_of_nodes));

%% Real radio
ratio_real_net = zeros(num_networks, num_networks);
for  i= 1:num_networks
    for j = 1:num_networks
        real_subnet = real_network(net_index_of_nodes ==i, net_index_of_nodes == j);
        ratio_real_net(i, j) = sum(real_subnet(:))/numel(real_subnet);
    end
end
%% Generate random networks
ratio_rand_net = zeros(num_perm, num_networks, num_networks);
for i = 1:num_perm
    rand_network = gretna_gen_random_network1(real_network);
    for  j= 1:num_networks
        for k = 1:num_networks
            rand_subnet = rand_network(net_index_of_nodes ==j, net_index_of_nodes == k);
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

% Show
p=1-pvalues;
% p(p<0.95) = 0;
matrixplot(x,'DisplayOpt','off','FigShap','d');
colormap(jet)
saveas(gcf,fullfile('permutation.pdf')); 

% colormap(mycmp);

function [Arand] = gretna_gen_random_network1(A)
%==========================================================================
% This function is used to generate a random network with the same number 
% of nodes, number of edges and degree distribution as a real binary network
% G using Maslovs wiring algorithm (Maslov et al. 2002). This function is
% slightly revised according to Maslov's wiring program
% (http://www.cmth.bnl.gov/~maslov/).
%
%
% Syntax: functiona [Arand] = gretna_gen_random_network1(A)
%
% Input: 
%      A:
%            The adjacency matrix of G (N*N, symmetric).
%
% Output:
%      Arand:
%            The generated random network.
%
% Yong HE, BIC, MNI, McGill 2007/05/01
%==========================================================================

Arand = A;
Arand = Arand - diag(diag(Arand));
nrew = 0;

[i1,j1] = find(Arand);
aux = find(i1>j1);
i1 = i1(aux);
j1 = j1(aux);
Ne = length(i1);

ntry = 2*Ne;

for i = 1:ntry
    e1 = 1+floor(Ne*rand);
    e2 = 1+floor(Ne*rand);
    v1 = i1(e1);
    v2 = j1(e1);
    v3 = i1(e2);
    v4 = j1(e2);
%     if Arand(v1,v2) < 1;
%         v1
%         v2
%         Arand(v1,v2)
%         pause;
%     end;
%     if Arand(v3,v4) < 1;
%         v3
%         v4
%         Arand(v3,v4)
%         pause;
%     end;

    if (v1~=v3)&&(v1~=v4)&&(v2~=v4)&&(v2~=v3);
        if rand > 0.5;
            if (Arand(v1,v3)==0)&&(Arand(v2,v4)==0);

                % the following line prevents appearance of isolated clusters of size 2
                %           if (k1(v1).*k1(v3)>1)&(k1(v2).*k1(v4)>1);

                Arand(v1,v2) = 0;
                Arand(v3,v4) = 0;
                Arand(v2,v1) = 0;
                Arand(v4,v3) = 0;

                Arand(v1,v3) = 1;
                Arand(v2,v4) = 1;
                Arand(v3,v1) = 1;
                Arand(v4,v2) = 1;

                nrew = nrew + 1;

                i1(e1) = v1;
                j1(e1) = v3;
                i1(e2) = v2;
                j1(e2) = v4;

                % the following line prevents appearance of isolated clusters of size 2
                %            end;

            end;
        else
            v5 = v3;
            v3 = v4;
            v4 = v5;
            clear v5;

            if (Arand(v1,v3)==0)&&(Arand(v2,v4)==0);

                % the following line prevents appearance of isolated clusters of size 2
                %           if (k1(v1).*k1(v3)>1)&(k1(v2).*k1(v4)>1);

                Arand(v1,v2) = 0;
                Arand(v4,v3) = 0;
                Arand(v2,v1) = 0;
                Arand(v3,v4) = 0;

                Arand(v1,v3) = 1;
                Arand(v2,v4) = 1;
                Arand(v3,v1) = 1;
                Arand(v4,v2) = 1;

                nrew = nrew + 1;

                i1(e1) = v1;
                j1(e1) = v3;
                i1(e2) = v2;
                j1(e2) = v4;

                % the following line prevents appearance of isolated clusters of size 2
                %           end;

            end;
        end;
    end;
end;

return