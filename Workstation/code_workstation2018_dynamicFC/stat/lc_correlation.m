%% Used to performe correction analysis between dfc parameters and clinical scales

% input
covpath = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\all_covariates.xlsx';
scale_hc_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_hc.xlsx';
scale_sz_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_sz.xlsx';
scale_mdd_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_mdd.xlsx';
scale_bd_path = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\scale_bd.xlsx';
dfcparapath = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\temploral_properties.xlsx';
isplot = 0;

% load
cov = xlsread(covpath);
[scale_hc,header_hc] = xlsread(scale_hc_path);
[scale_sz,header_sz] = xlsread(scale_sz_path);
[scale_mdd,header_mdd] = xlsread(scale_mdd_path);
[scale_bd,header_bd] = xlsread(scale_bd_path);
dfcpara = xlsread(dfcparapath);

for i = 1:5
    % extract and matching order
    targetscalename = header_hc(i+8);
    targetscale_loc = ismember(header_hc,targetscalename);
    targetscale_hc = scale_hc(:,targetscale_loc);
    targetscale_sz = scale_sz(:,targetscale_loc);
    targetscale_mdd = scale_mdd(:,targetscale_loc);
    targetscale_bd = scale_bd(:,targetscale_loc);
    targetscale_all = cat(1,targetscale_hc,targetscale_sz,targetscale_mdd,targetscale_bd);
    idall = cat(1,scale_hc(:,1), scale_sz(:,1), scale_mdd(:,1),scale_bd(:,1));
    targetscale_all = cat(2,idall,targetscale_all);
    
    %  match
    [loc1,locb1] = ismember(idall, dfcpara(:,1));
    [loc2,locb2] = ismember(idall, cov(:,1));
    dfcpara_sel = dfcpara(locb1, :);
    cov_sel = cov(locb2,:);
    
    % denan
    locnan = isnan(targetscale_all(:,2));
    targetscale_all = targetscale_all(~locnan,:);
    dfcpara_sel = dfcpara_sel(~locnan,:);
    cov_sel = cov_sel(~locnan,:);
    
    % corr
    % logloc = find(dfcpara(:,2) == 4);
    % logloc = [100:200];
    % targetscale_all = targetscale_all(logloc,:);
    % dfcpara = dfcpara(logloc,:);
    % cov = cov(logloc,:);
    logloc = cov_sel(:,2) ~= 1;
    x = targetscale_all(:,2);  x = x(logloc,:);
    y = dfcpara_sel(:,[3,4,6,7]); y = y(logloc,:);
    z = cov_sel(:,[3,4,6]);  z = z(logloc,:);
    [r(i,:),p(i,:)] = partialcorr(x, y, z,'type','Spearman');
    
    % plot
    if isplot
        xp = y(:,3);
        yp = x;
        f = plot(xp,yp,'.','MarkerSize',1);hold on;
        xlim([-median(xp)/2,max(xp)+median(xp)/2]);
        ylim([-median(yp),max(yp)+median(yp)/2])
        line = lsline;
        set(line,'LineWidth',2,'LineStyle','--');
        
        
        logloc = find(dfcpara_sel(:,2) == 1);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(dfcpara_sel(:,2) == 2);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(dfcpara_sel(:,2) == 3);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);hold on;
        logloc = find(dfcpara_sel(:,2) == 4);
        plot(xp(logloc),yp(logloc),'.','MarkerSize',25);
        legend('all','line','HC','MDD','SZ','BD');
        print(gcf,'-dtiff', '-r1200','D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\figure\corr_scale2_FTstate2.tif')
    end
    
end
results=multcomp_fdr_bh(p(:),'alpha', 0.05);