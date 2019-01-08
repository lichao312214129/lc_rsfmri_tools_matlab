%% please refer to: [Erratum: Resting-state connectivity biomarkers define neurophysiological subtypes of depression]
X = [1 2;2.5 4.5;2 2;4 1.5;...
    4 2.5];
% distance pairs
Y = pdist(X)
squareform(Y)

% group into clusers
% The first two columns identify the objects that have been linked.
% The third column contains the distance between these objects.
Z= linkage(Y)

% plot cluster tree
dendrogram(Z)

c = cophenet(Z,Y)

I = inconsistent(Z)

% 聚类的类别
T = cluster(Z,'cutoff',0.1)

T = cluster(Z,'maxclust',3)

%% =======================================================================
X = [1 2;2.5 4.5;2 2;4 1.5;...
    4 2.5];
% Create a hierarchical cluster tree using Ward's linkage.
Z = linkage(X,'ward','euclidean','savememory','on');
Y=pdist(X);
%
% If you set |savememory| to |'off'| , you can get an out-of-memory error
% if your machine doesn't have enough memory to hold the distance matrix.
%
% Cluster data into four groups and plot the result.
c = cluster(Z,'maxclust',4);
 cophenetic_correlation_coefficient = cophenet(Z,Y)

%% Cluster Data and Plot the Result
%
% Randomly generate the sample data with 20000 observations.

% Copyright 2015 The MathWorks, Inc.

rng default; % For reproducibility
X = rand(20000,3);
%
% Create a hierarchical cluster tree using Ward's linkage.
Z = linkage(X,'ward','euclidean','savememory','on');
%
% If you set |savememory| to |'off'| , you can get an out-of-memory error
% if your machine doesn't have enough memory to hold the distance matrix.
%
% Cluster data into four groups and plot the result.
c = cluster(Z,'maxclust',4);
scatter3(X(:,1),X(:,2),X(:,3),10,c)