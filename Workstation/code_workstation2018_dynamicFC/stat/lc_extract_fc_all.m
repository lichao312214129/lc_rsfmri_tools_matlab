% input
dir_fc = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\individual_state2';
mask = importdata('D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\shared_1and2and3_fdr.mat');
% mask = H;
dir_saveresults = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\results_dfc\results_of_individual\extractedfc';

fc = dir(fullfile(dir_fc,'*.mat'));
allsubname = {fc.name}';
allfc_path = fullfile(dir_fc, allsubname);

n_sub = length(allfc_path);
extractedfc = cell(n_sub,1);
for i = 1:n_sub
    fprintf('Calculating %d\n',i)
    net = importdata(allfc_path{i});
    ef = lc_extract_fc(net, mask);
    extractedfc {i} = ef';
    save(fullfile(dir_saveresults,allsubname{i}), 'ef');
end
extractedfc = cell2mat(extractedfc);
xlswrite(fullfile(dir_saveresults,'extractedfc.xlsx'), allsubname,'sheet1','A1');
xlswrite(fullfile(dir_saveresults,'extractedfc.xlsx'), extractedfc,'sheet1','B1');
disp('All Done!');