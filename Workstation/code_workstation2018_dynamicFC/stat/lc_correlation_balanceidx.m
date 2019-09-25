%% Used to performe correction analysis between dfc parameters and clinical scales

% input
covpath = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\all_covariates.xlsx';
scale_hc_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_hc.xlsx';
scale_sz_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_sz.xlsx';
scale_mdd_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_mdd.xlsx';
scale_bd_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_bd.xlsx';
balanceidpath = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\balance_index_nomask\balanceidx.xlsx';
isplot = 0;

% load
cov = xlsread(covpath);
[scale_hc,header_hc] = xlsread(scale_hc_path);
[scale_sz,header_sz] = xlsread(scale_sz_path);
[scale_mdd,header_mdd] = xlsread(scale_mdd_path);
[scale_bd,header_bd] = xlsread(scale_bd_path);
[balanceidx,header_bi] = xlsread(balanceidpath);
ms = regexp( header_bi, '(?<=\w+)[1-9][0-9]*', 'match' );
nms = length(ms);
subjid = zeros(nms,1);
for j = 1:nms
    tmp = ms{j}{1};
    subjid(j) = str2double(tmp);
end
% subjid = balanceidx(:,1);

r = zeros(1,5);
p = ones(1,5);
for i = 1:5
    % extract and matching order
    targetscalename = header_hc(i+8);
    targetscale_loc = ismember(header_hc,[targetscalename,'Õï¶Ï']);
    targetscale_hc = scale_hc(:,targetscale_loc);
    targetscale_sz = scale_sz(:,targetscale_loc);
    targetscale_mdd = scale_mdd(:,targetscale_loc);
    targetscale_bd = scale_bd(:,targetscale_loc);
    targetscale_all = cat(1,targetscale_hc,targetscale_sz,targetscale_mdd,targetscale_bd);
    idall = cat(1,scale_hc(:,1), scale_sz(:,1), scale_mdd(:,1),scale_bd(:,1));
    targetscale_all = cat(2,idall,targetscale_all);
    
    %  match
    sectid = intersect(intersect(cov(:,1),subjid), idall);
    [loc1,locb1] = ismember(sectid, subjid);
    [loc2,locb2] = ismember(sectid, cov(:,1));
    [loc3,locb3] = ismember(sectid, idall);
    
    balanceidx_sel = balanceidx(locb1,:);
    cov_sel = cov(locb2,:);
    targetscale_all = targetscale_all(locb3, :);
    
    % denan
    locnan = isnan(targetscale_all(:,3));
    targetscale_all = targetscale_all(~locnan,:);
    balanceidx_sel = balanceidx_sel(~locnan,:);
    cov_sel = cov_sel(~locnan,:);
    
    % corr
    logloc = targetscale_all(:,2) ~= 5;
    seleid = targetscale_all(:,2);
    seleid = seleid(logloc);
    x = targetscale_all(:,3); x = x(logloc,:);
    y = balanceidx_sel; y = y(logloc,:);
    z = cov_sel(:,[2,3,4,6]); z = z(logloc,:);
    [r(i),p(i)] = partialcorr(x, y, z,'type','Spearman');
    
    % plot
    if isplot
        xp = y;
        yp = x;
        f = plot(xp,yp,'.','MarkerSize',10);hold on;
        xlim([min(xp)-mean(xp)/20,max(xp)+mean(xp)/20]);
        ylim([min(yp)-mean(yp)/5,max(yp)+mean(yp)/5])
        line = lsline;
        set(line,'LineWidth',2,'LineStyle','--');
        
%         logloc = find(seleid == 1);
%         plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(seleid == 2);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(seleid == 3);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(seleid == 4);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);
%         legend({'HC','MDD','SZ','BD'});
        legend('all','line','MDD','SZ','BD');
        print(gcf,'-dtiff', '-r1200',['D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\corr_scale',num2str(i),'_balanceidx_onlypatients.tif'])
    end
    
end

% %% ttest2
% bi = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\balance_index\bi.xlsx';
% bi = xlsread(bi);
% [h, p] = ttest2(bi(bi(:,3)==1,2),bi(bi(:,3)==4,2));
% results=multcomp_fdr_bh(p(:),'alpha', 0.05);