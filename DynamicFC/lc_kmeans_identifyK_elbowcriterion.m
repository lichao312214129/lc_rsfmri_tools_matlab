function [ratio, centroid] = lc_kmeans_identifyK_elbowcriterion(data,kRange, distance_measure, nReplicates, isshow)
% The optimal number of centroid states was estimated using the elbow criterion, 
% defined as the ratio of within cluster to between cluster distances.
% About how to identify K, please refer to "The human cortex possesses a reconfigurable
% dynamic network architecture that is disrupted in psychosis"
% inputs:
%   data: N_subs * P features
%   distance_measur: such as cityblock (L1 distance)
%   kRange: The search window of k, such as  2:1:20;
% output:
%   ratio:ratio of within cluster to between cluster distances of each k
%   centroid: centroid of each k. type is cell
% Author: Li Chao
% Email:lichao19870617@gmail.com OR lichao19870617@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs
rng(1); % For reproducibility
if nargin<2
    kRange=2:1:20;
end

%
[~,n_features]=size(data);

% normalizating data(option)

% kmeans loop(kmeans++ algorithm)
% elbow criterion ratio
try
    pool = parpool; 
catch
    fprintf('Already opened parpool\n');
end
stream = RandStream('mlfg6331_64');  % Random number stream
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);

ratio=zeros(numel(kRange)-1,2);
centroid = cell(numel(kRange),1);
T=0;
% parpool(3);
for k=kRange
    fprintf('Clustering to %d cluster...\n',k)
    T = T+1;
    tic;
    [idx, C, sumD, ~] = kmeans(data,k,'Distance',distance_measure,...
                                        'Distance', distance_measure,...
                                        'Replicates', nReplicates, 'Options', options,...
                                        'Start', 'plus','Display','final');
    toc;
    centroid{T} = C;

    % number of each index
    num_of_each_idx=zeros(k,1);
    for i=1:k
        num_of_each_idx(i) = sum(idx == i);
    end
    % avarage intra-distance
    sort_ind=sumD./num_of_each_idx;
    sort_ind_ave=mean(sort_ind);
    % avarage intre-distance
    h=nchoosek(k,2);
    A=zeros(h,2);
    t=0;
    sort_outd=zeros(h,1);
    for i=1:k-1
        for j=i+1:k
            t=t+1;
            A(t,1)=i;
            A(t,2)=j;
        end
    end
    for i=1:h
        for j=1:n_features
            sort_outd(i,1)=sort_outd(i,1)+(C(A(i,1),j)-C(A(i,2),j))^2;
        end
    end
    sort_outd_ave=mean(sort_outd);
    
    ratio(T,1)=k;
    ratio(T,2)=sort_ind_ave/sort_outd_ave;
end

% plot elbow criterion ratio
if isshow
    figure
    plot(ratio(:,1),ratio(:,2));
    box off;
end