%% Plot mean tvalues within or between networks
load  G:\BranAtalas\Template_Yeo2011\netIndex.mat;

net = {'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\dfc_posthoc_szvshc_results_original_fdr',...
'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\dfc_posthoc_szvshc_results_original_fdr',...
'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\dfc_posthoc_szvshc_results_original_fdr'};
name = {'avargT_sz','avargT_bd','avargT_mdd'};
load (net{1});

uniid = unique(netIndex);
betweenfc = zeros(numel(uniid));
for i = uniid
    id = find(netIndex==i);
    if i == 1;unjid = [1 5 6 7];end
    if i == 2;unjid = [2 3 4];end
    if i == 3;unjid = [2 4];end
    if i == 4;unjid = [2 3 4 6 7];end
    if i == 5;unjid = [1];end
    if i == 6;unjid = [1 4 6 7];end
    if i == 7;unjid = [1 4 6];end
    
    for j =  unjid
        fc = Tvalues(id,netIndex==j);
        if all(diag(fc)) == 0
            fc = fc(triu(ones(length(fc)),1)==1);
        end
        betweenfc(i,j) = mean(fc(:));
    end
end
mycmp = importdata('colorbar_avargT.mat');
imagesc(betweenfc);colormap(mycmp);hold on;
data = betweenfc;
[m,n] = size(data);
[x,y] = meshgrid(0:n,0:m);
sx = x(1:end,1:end)+0.5;
sy = y(1:end,1:end)+0.5;
data = data(:);
z = zeros(size(x));
mesh(sx,sy,z,...
    'EdgeColor',[0,0,0],...
    'FaceAlpha',0,...
    'LineWidth',1); 
view(2);
axis square;
caxis([-2 2]);
colorbar
axis off
print(gcf,'-dtiff', '-r1200',[name,'.tiff'])