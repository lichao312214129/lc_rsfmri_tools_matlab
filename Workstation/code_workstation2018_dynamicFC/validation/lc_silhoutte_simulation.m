% This script is used to cluster the simulated data using silhouette criteria.
% PURPOSE: Validating that lower numbers of clusters not tend to be more similar.

%% Clustering using different K
krange = 2:1:10;
% 2
rng default  % For reproducibility
X = [randn(1000,2);randn(1000,2)-ones(1000,2)*5];
eva_silhoutte2 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values2 = eva_silhoutte2{1}.values;
k_optimal2 = eva_silhoutte2{1}.K;

% 3
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10];
eva_silhoutte3 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values3 = eva_silhoutte3{1}.values;
k_optimal3 = eva_silhoutte3{1}.K;


% 4
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15];
eva_silhoutte4 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values4 = eva_silhoutte4{1}.values;
k_optimal4 = eva_silhoutte4{1}.K;

% 5
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20];
eva_silhoutte5 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values5 = eva_silhoutte5{1}.values;
k_optimal5 = eva_silhoutte5{1}.K;

% 6
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25];
eva_silhoutte6 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values6 = eva_silhoutte6{1}.values;
k_optimal6 = eva_silhoutte6{1}.K;

% 7
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30];
eva_silhoutte7 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values7 = eva_silhoutte7{1}.values;
k_optimal7 = eva_silhoutte7{1}.K;

% 8
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35];
eva_silhoutte8 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values8 = eva_silhoutte8{1}.values;
k_optimal8 = eva_silhoutte8{1}.K;

% 9
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35;  randn(1000,2)-ones(1000,2)*40];
eva_silhoutte9 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values9 = eva_silhoutte9{1}.values;
k_optimal9 = eva_silhoutte9{1}.K;

% 10
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35;  randn(1000,2)-ones(1000,2)*40; randn(1000,2)-ones(1000,2)*45];
eva_silhoutte10 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
silhouette_values10 = eva_silhoutte10{1}.values;
k_optimal10 = eva_silhoutte10{1}.K;

%% Plot
ax = tight_subplot(3,3,[0.2 0.05],[0.1 0.1],[0.05 0.05]);
for i = 2:1:10
    axes(ax(i-1)) 
    eval(['values = silhouette_values', num2str(i),';']);
    plot(values,'-o', 'LineWidth',2);
  
    set(gca,'linewidth',2);
    set(gca,'fontsize',10);
    xticklabels(2:1:10);
    set(gca,'XTick',1:1:9);
    xTL=2:1:10;
    set(gca,'XTickLabels',xTL);
    xlim([-0.1,10])
    
    title(['Optimal numbers of clusters = ',num2str(i)],'fontsize',12,'FontWeight','bold');
    xlabel('Numbers of clusters');
    ylabel('Silhouette values');

    box off
end
% print(gcf,'-dtiff', '-r600','D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\schizophrenia bulletin\RevisedVersion\Figure\Real_clustering.tiff')
