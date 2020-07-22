% This script is used to cluster the simulated data using silhouette criteria.
% PURPOSE: Validating that lower numbers of clusters not tend to be more similar.

%% Clustering using different K
krange = 2:1:10;
% 2
rng default  % For reproducibility
X = [randn(1000,2);randn(1000,2)-ones(1000,2)*5];
eva_silhoutte2 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow2 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values2 = eva_silhoutte2{1}.values;
k_optimal2 = eva_silhoutte2{1}.K;
elbow_values2 = eva_elbow2{1}.values;
% 3
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10];
eva_silhoutte3 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow3 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values3 = eva_silhoutte3{1}.values;
k_optimal3 = eva_silhoutte3{1}.K;
elbow_values3 = eva_elbow3{1}.values;

% 4
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15];
eva_silhoutte4 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow4 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values4 = eva_silhoutte4{1}.values;
k_optimal4 = eva_silhoutte4{1}.K;
elbow_values4 = eva_elbow4{1}.values;

% 5
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20];
eva_silhoutte5 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow5 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values5 = eva_silhoutte5{1}.values;
k_optimal5 = eva_silhoutte5{1}.K;
elbow_values5 = eva_elbow5{1}.values;

% 6
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25];
eva_silhoutte6 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow6 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values6 = eva_silhoutte6{1}.values;
k_optimal6 = eva_silhoutte6{1}.K;
elbow_values6 = eva_elbow6{1}.values;

% 7
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30];
eva_silhoutte7 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow7 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values7 = eva_silhoutte7{1}.values;
k_optimal7 = eva_silhoutte7{1}.K;
elbow_values7 = eva_elbow7{1}.values;

% 8
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35];
eva_silhoutte8 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow8 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values8 = eva_silhoutte8{1}.values;
k_optimal8 = eva_silhoutte8{1}.K;
elbow_values8 = eva_elbow8{1}.values;

% 9
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35;  randn(1000,2)-ones(1000,2)*40];
eva_silhoutte9 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow9 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values9 = eva_silhoutte9{1}.values;
k_optimal9 = eva_silhoutte9{1}.K;
elbow_values9 = eva_elbow9{1}.values;

% 10
rng default  % For reproducibility
X = [randn(1000,2); randn(1000,2)-ones(1000,2)*5; randn(1000,2)-ones(1000,2)*10; randn(1000,2)-ones(1000,2)*15; randn(1000,2)-ones(1000,2)*20;...
randn(1000,2)-ones(1000,2)*25; randn(1000,2)-ones(1000,2)*30; randn(1000,2)-ones(1000,2)*35;  randn(1000,2)-ones(1000,2)*40; randn(1000,2)-ones(1000,2)*45];
eva_silhoutte10 = icatb_optimal_clusters(X, krange, 'method' , 'silhoutte');  % For main results
eva_elbow10 = icatb_optimal_clusters(X, krange, 'method' , 'elbow');  % For validation
silhouette_values10 = eva_silhoutte10{1}.values;
k_optimal10 = eva_silhoutte10{1}.K;
elbow_values10 = eva_elbow10{1}.values;

%% Plot
% Silhouette
figure
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
    
    title(['Real number of clusters = ',num2str(i)],'fontsize',12,'FontWeight','bold');
    xlabel('Numbers of clusters');
    ylabel('Silhouette values');

    box off
end
% print(gcf,'-dtiff', '-r600','D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\schizophrenia bulletin\RevisedVersion\Figure\Silhouette_simu.tiff')

% elbow
figure
ax = tight_subplot(3,3,[0.2 0.05],[0.1 0.1],[0.05 0.05]);
for i = 2:1:10
    axes(ax(i-1)) 
    eval(['values = elbow_values', num2str(i),';']);
    plot(values,'-o', 'LineWidth',2);
  
    set(gca,'linewidth',2);
    set(gca,'fontsize',10);
    xticklabels(2:1:10);
    set(gca,'XTick',1:1:9);
    xTL=2:1:10;
    set(gca,'XTickLabels',xTL);
    xlim([-0.1,10])
    
    title(['Real number of clusters = ',num2str(i)],'fontsize',12,'FontWeight','bold');
    xlabel('Numbers of clusters');
    ylabel('Elbow values');

    box off
end
print(gcf,'-dtiff', '-r600','D:\WorkStation_2018\WorkStation_dynamicFC_V3\M.S\schizophrenia bulletin\RevisedVersion\Figure\Si_simu.tiff')


