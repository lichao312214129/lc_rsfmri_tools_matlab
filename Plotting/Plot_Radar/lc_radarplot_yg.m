[data,header]=xlsread('D:\others\彦鸽姐\final_data.xlsx');
if_save_figure=0;
%% 增加与减弱的分开
% decreased and increased
decreased_header=header(:,6:13);
decreased_data=data(:,6:13);

increased_header=header(:,14:17);
increased_data=data(:,14:17);
%% 按诊断分组
[is,id]=ismember('诊断',header);
diagnosis=data(:,id);

hc_decreased_data=decreased_data(diagnosis==1,:);
mdd_decreased_data=decreased_data(diagnosis==2,:);
bd_decreased_data=decreased_data(diagnosis==4,:);
sz_decreased_data=decreased_data(diagnosis==3,:);

hc_increased_data=increased_data(diagnosis==1,:);
mdd_increased_data=increased_data(diagnosis==2,:);
bd_increased_data=increased_data(diagnosis==4,:);
sz_increased_data=increased_data(diagnosis==3,:);


%% mean value
hc_mean_decreased_data=10.^(mean(hc_decreased_data)*2);
mdd_mean_decreased_data=10.^(mean(mdd_decreased_data)*2);
bd_mean_decreased_data=10.^(mean(bd_decreased_data)*2);
sz_mean_decreased_data=10.^(mean(sz_decreased_data)*2);

orig_hc_mean_decreased_data=mean(hc_decreased_data);
orig_mdd_mean_decreased_data=mean(mdd_decreased_data);
orig_bd_mean_decreased_data=mean(bd_decreased_data);
orig_sz_mean_decreased_data=mean(sz_decreased_data);

hc_mean_increased_data=100.^(mean(hc_increased_data));
mdd_mean_increased_data=100.^(mean(mdd_increased_data));
bd_mean_increased_data=100.^(mean(bd_increased_data));
sz_mean_increased_data=100.^(mean(sz_increased_data));

orig_hc_mean_increased_data=mean(hc_increased_data);
orig_mdd_mean_increased_data=mean(mdd_increased_data);
orig_bd_mean_increased_data=mean(bd_increased_data);
orig_sz_mean_increased_data=mean(sz_increased_data);

%% decreased

% radar plot
figure
opt.linewidth=1;
%
opt.color=[.4 .4 .4];
opt.TickLabel=decreased_header;
xlswrite('decreased_header.xlsx',decreased_header)
LC_RadarPlot(hc_mean_decreased_data,opt);

hold on;

opt.color='b';
% opt.TickLabel=decreased_header;
LC_RadarPlot(mdd_mean_decreased_data,opt);

hold on;

opt.color='g';
% opt.TickLabel=decreased_header;
LC_RadarPlot(bd_mean_decreased_data,opt);

hold on;

opt.color='r';
% opt.TickLabel=decreased_header;
LC_RadarPlot(sz_mean_decreased_data,opt);

hold off;

legend({'HC','MDD','BPD','SCZ'},'Location','Best','FontSize',10);

if if_save_figure
    set(gcf,'outerposition',get(0,'screensize'));
    print('radarplot_decr1.tif','-dtiff','-r300bpi')%save
end
%% increased
figure
opt.linewidth=1;
%
opt.color=[.4 .4 .4];
opt.TickLabel=increased_header;
LC_RadarPlot(hc_mean_increased_data,opt);

hold on;

opt.color='b';
% opt.TickLabel=increased_header;
LC_RadarPlot(mdd_mean_increased_data,opt);

hold on;

opt.color='g';
% opt.TickLabel=increased_header;
LC_RadarPlot(bd_mean_increased_data,opt);

hold on;

opt.color='r';
% opt.TickLabel=increased_header;
LC_RadarPlot(sz_mean_increased_data,opt);

hold off;

legend({'HC','MDD','BPD','SCZ'},'Location','Best','FontSize',10);

% save
if if_save_figure
    set(gcf,'outerposition',get(0,'screensize'));
    print('radarplot_incr.tif','-dtiff','-r300bpi')
end

% %%
% figure
% opt.linewidth=1;
% %
% opt.color='b';
% opt.TickLabel={'SCZ','HC','MDD','BPD'};
% LC_RadarPlot(X,opt);