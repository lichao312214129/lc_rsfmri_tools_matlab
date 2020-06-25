% This script is used to perform correlation analysis between results of silhoutte method and davies-bouldin
figure;
for i = 1:3
load(['group_centroids_',num2str(i),'.mat']);
coef = corr(c1(:), square_median_mat(:));
subplot(1,3,i)
imagesc(square_median_mat)
colormap(jet)
colorbar;
caxis([-0.5,1])
axis square
title(num2str(coef));
end