%% Plot mean tvalues within or between networks
load  G:\BranAtalas\Template_Yeo2011\netIndex.mat;
mycolormap = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmap_mean_t.mat';
net = {'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_3vs1_FDR0.05.mat',...
    'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_4vs1_FDR0.05.mat',...
    'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_2vs1_FDR0.05.mat'};
name = {'avargT_sz','avargT_bd','avargT_mdd'};
filter = 0;  %  filter fc without differences: set meanFC that without differences in any FC within or between networks.

Tvalues_sz = importdata (net{1});
Tvalues_sz = Tvalues_sz.Tvalues;

Tvalues_bd = importdata(net{2});
Tvalues_bd = Tvalues_bd.Tvalues;

Tvalues_mdd = importdata (net{3});
Tvalues_mdd = Tvalues_mdd.Tvalues;
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};
mycmp = importdata(mycolormap);

meanFC_sz = get_meanfc(Tvalues_sz, netIndex, filter);
meanFC_bd = get_meanfc(Tvalues_bd, netIndex, filter);
meanFC_mdd = get_meanfc(Tvalues_mdd, netIndex, filter);
meanFC = {meanFC_sz, meanFC_bd, meanFC_mdd};
titles = {'SZ - HC', 'BD - HC', 'MDD - HC'};

figure('Position',[50 50 500 300]);
ax = tight_subplot(1,3,[0.05 0.1],[0.01 0.05],[0.01 0.01]);
for i = 1:3
axes(ax(i)) 
imagesc(meanFC{i});
colormap(mycmp);
hold on;
[m,n] = size(meanFC{i});
[x,y] = meshgrid(0:n,0:m);
sx = x(1:end,1:end)+0.5;
sy = y(1:end,1:end)+0.5;
z = zeros(size(x));
mesh(sx,sy,z,...
    'EdgeColor',[0,0,0],...
    'FaceAlpha',0,...
    'LineWidth',0.5);
view(2);
axis square;
caxis([-4 4]);
title(titles{i})
axis off
end
cb = colorbar('horiz','position',[0.35 0.15 0.3 0.04]); % œ‘ æcolorbar
ylabel(cb,'T-values', 'FontSize', 8);  % …Ë÷√colorbarµƒtitle
saveas(gcf,'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\mean_tvalues.pdf')

function meanFC = get_meanfc(Tvalues, netIndex, filter)
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
        if (all(diag(fc)) == 0) && (size(fc,1)==size(fc,2))
            fc = fc(triu(ones(length(fc)),1)==1);
        end
        fc(fc==0) = [];
        meanFC(i,j) = mean(fc(:));
    end
end
meanFC(isnan(meanFC)) = 0;
end
