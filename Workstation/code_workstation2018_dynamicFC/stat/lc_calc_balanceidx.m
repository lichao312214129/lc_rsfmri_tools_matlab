% input
net_index_path='D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\plot\netIndex.mat';
netid = importdata(net_index_path);
dir_fc = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\individual_state2';
% mask = importdata('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\shared_1and2and3_fdr.mat');
% mask = ones(114) == 1;
mask = H;
dir_saveresults = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\balance_index_nomask';

fc = dir(fullfile(dir_fc,'*.mat'));
allsubname = {fc.name}';
allfc_path = fullfile(dir_fc, allsubname);

n_sub = length(allfc_path);
BalanceIdx = zeros(n_sub,1);
for i = 1:n_sub
    fprintf('Calculating %d\n',i)
    net = importdata(allfc_path{i});
    balance_idx = lc_calc_balanceindex_withinVSbetween(net, netid, mask);
    BalanceIdx (i) = balance_idx;
    save(fullfile(dir_saveresults,allsubname{i}), 'balance_idx');
end
xlswrite(fullfile(dir_saveresults,'balanceidx.xlsx'), allsubname,'sheet1','A1');
xlswrite(fullfile(dir_saveresults,'balanceidx.xlsx'), BalanceIdx,'sheet1','B1');
disp('All Done!');