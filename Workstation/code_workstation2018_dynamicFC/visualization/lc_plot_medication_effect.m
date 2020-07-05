%% This script is used to visualize statistical results of transdiagnostic dynamic functional connectivity (including group mean functional connectivitync).

%% INPUTS
results_root = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610';
cmap_fc = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_posthoc_tvalues';
cmap_fvalues = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_fvalues';
cmap_posthoc_tvalues = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_posthoc_tvalues';
cmap_posthoc_effectsize = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmap_posthoc_effectsize';
mask_path = '';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};

%% Load
load (cmap_fc)
load(cmap_fvalues)
load(cmap_posthoc_tvalues)
load(cmap_posthoc_effectsize)

medication_effect_state1 = importdata(fullfile(results_root, 'results_state1', 'ttest_Ttest2_FDR_Corrected_0.05.mat'));
medication_effect_state2 = importdata(fullfile(results_root, 'results_state2', 'ttest_Ttest2_FDR_Corrected_0.05.mat'));
medication_effect_state3 = importdata(fullfile(results_root, 'results_state3', 'ttest_Ttest2_FDR_Corrected_0.05.mat'));

%% Plot medication effect
figure('Position',[50 50 500 400]);
ax = tight_subplot(1,3,[0.05 0.1],[0.01 0.05],[0.01 0.01]);

axes(ax(1)) 
lc_netplot('-n', medication_effect_state1.Tvalues, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_posthoc_tvalues)
%     colorbar;
caxis([-4 4])
title('State 1');
axis square

axes(ax(2)) 
lc_netplot('-n', medication_effect_state2.Tvalues, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_posthoc_tvalues)
%     colorbar;
caxis([-4 4])
title('State 2');
axis square

axes(ax(3)) 
lc_netplot('-n', medication_effect_state3.Tvalues, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 6);
colormap(cmp_posthoc_tvalues)
%     colorbar;
caxis([-4 4])
title('State 3');
axis square

cb = colorbar('horiz','position',[0.35 0.15 0.3 0.02]); % œ‘ æcolorbar
ylabel(cb,'T-values', 'FontSize', 8);  % …Ë÷√colorbarµƒtitle
saveas(gcf,fullfile(results_root, 'medication_effect.pdf'))
