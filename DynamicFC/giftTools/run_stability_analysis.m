function [W, A, icasig] = run_stability_analysis(ica_algorithm, data, num_ica_runs)
% Stability analysis
icasigR = cell(1, num_ica_runs);
fprintf('\n');
disp(['Number of times ICA will run is ', num2str(num_ica_runs)]);
for nRun = 1:length(icasigR)
    fprintf('\n');
    disp(['Run ', num2str(nRun), ' / ', num2str(num_ica_runs)]);
    fprintf('\n');
    [dd1, W, A, icasigR{nRun}]  = icatb_icaAlgorithm(ica_algorithm, data);
end
clear dd1 dd2 dd3;

if (num_ica_runs > 1)
    clear W A;
    [corrMetric, W, A, icasig, bestRun] = icatb_bestRunSelection(icasigR, data);
else
    icasig = icasigR{1};
end