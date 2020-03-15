%% Plot mean tvalues within or between networks
load  G:\BranAtalas\Template_Yeo2011\netIndex.mat;
mycolormap = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\colorbar_avargT.mat';
net = {'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\dfc_posthoc_szvshc_results_original_fdr',...
    'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\dfc_posthoc_szvshc_results_original_fdr',...
    'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\V1\results_of_individual\dfc_posthoc_szvshc_results_original_fdr'};
name = {'avargT_sz','avargT_bd','avargT_mdd'};
filter = 0;  %  filter fc without differences: set meanFC that without differences in any FC within or between networks.
group = 1;
load (net{group});

uniid = unique(netIndex);
meanFC = zeros(numel(uniid));
for i = uniid
    id = find(netIndex==i);
    if filter
        if i == 1;unjid = [1 5 6 7];end
        if i == 2;unjid = [2 3 4];end
        if i == 3;unjid = [2 4];end
        if i == 4;unjid = [2 3 4 6 7];end
        if i == 5;unjid = [1];end
        if i == 6;unjid = [1 4 6 7];end
        if i == 7;unjid = [1 4 6];end
    else
        unjid = uniid;
    end
    
    for j =  unjid
        fc = Tvalues(id,netIndex==j);
        % if within fc, extract upper triangle matrix
        if all(diag(fc)) == 0
            fc = fc(triu(ones(length(fc)),1)==1);
        end
        meanFC(i,j) = mean(fc(:));
    end
end
mycmp = importdata(mycolormap);
imagesc(meanFC);colormap(mycmp);hold on;
data = meanFC;
% data = rand(50,50);
imagesc(data);hold on;
[m,n] = size(data);
[x,y] = meshgrid(0:n,0:m);
sx = x(1:end,1:end)+0.;
sy = y(1:end,1:end)+0.;
z = zeros(size(x));
mesh(sx,sy,z,...
    'EdgeColor',[0,0,0],...
    'FaceAlpha',0,...
    'LineWidth',2);
view(2);
axis square;
% caxis([-2 2]);
colorbar
axis off
% print(gcf,'-dtiff', '-r1200',[name,'.tiff'])