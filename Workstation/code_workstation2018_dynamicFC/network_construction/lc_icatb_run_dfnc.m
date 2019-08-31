function input_params = lc_icatb_run_dfnc(input_params)
% Run dfnc
% Modified from GIFT
% Cite GIFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% input
if nargin < 1
    input_params.ini = 1;
end

if ~isfield(input_params, 'all_subjects_files')
    input_params.all_subjects_files =uigetdir(pwd, 'select directory that containing all subjects'' data');
    input_params.all_subjects_files =dir(input_params.all_subjects_files);
    folder={input_params.all_subjects_files.folder};
    name={input_params.all_subjects_files.name};
    input_params.all_subjects_files =cell(length(name),1);
    for i =1:length(name)
        input_params.all_subjects_files {i}=fullfile(folder{i},name{i});
    end
    input_params.all_subjects_files = input_params.all_subjects_files (3:end);
end

if ~ isfield(input_params, 'result_dir')
    input_params.result_dir = uigetdir(pwd, 'select directory that saving results');
end

% Default and other parameters
TR = 2;
numOfSess = 1;
volume = 190;
numroi = 114;
doDespike = 'no';
tc_filter = 0;
method = 'none';
num_repetitions = 10;
input_params.window_type = 'gaussian';
input_params.window_alpha = 3;
input_params.window_length = 17;
input_params.window_step = 1;
input_params.prefix = '';
input_params.num_repetitions = num_repetitions;
input_params.calc_dynamic = 1;
input_params.calc_static = 1;

% make result directory
result_dir_of_static = fullfile(input_params.result_dir, strcat('zStaticFC_WindowLength',num2str(input_params.window_length),'_WindowStep',num2str(input_params.window_step)));
result_dir_of_dynamic = fullfile(input_params.result_dir, strcat('zDynamicFC_WindowLength',num2str(input_params.window_length),'_WindowStep',num2str(input_params.window_step)));
if ~exist(result_dir_of_static, 'dir')
    mkdir(result_dir_of_static);
end
if ~exist(result_dir_of_dynamic, 'dir')
    mkdir(result_dir_of_dynamic);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load timeseries
tic;
numOfSub = length(input_params.all_subjects_files);
tc = zeros(numOfSub, numOfSess, volume, numroi);
for i = 1:numOfSub
   tc(i, 1,:,:) = importdata(input_params.all_subjects_files{i});
end

% Make sliding window
c = icatb_compute_sliding_window(volume, input_params.window_alpha, input_params.window_length);
A = repmat(c, 1, numroi);
Nwin = volume - input_params.window_length;

%initial_lambdas = (0.1:.03:1);
initial_lambdas = (0.1:.03:.40);
best_lambda = zeros(1, numOfSub);
outFiles = cell(1, numOfSub);
dataSetCount = 0;

% Loop over subjects
for nSub = 1:numOfSub
    % Loop over sessions
    for nSess = 1:numOfSess
        
        dataSetCount = dataSetCount + 1;
        
        results_file = [input_params.prefix, '_sub_', icatb_returnFileIndex(nSub), '_sess_', icatb_returnFileIndex(nSess), '_results.mat'];
        
        FNCdyn = zeros(Nwin, numroi*(numroi - 1)/2);
        Lambdas = zeros(num_repetitions, length(initial_lambdas));
        disp(['Computing dynamic FNC on subject ', num2str(nSub), ' session ', num2str(nSess)]);
        
        if (strcmpi(doDespike, 'yes') && (tc_filter > 0))
            disp('Despiking and filtering timecourses ...');
        elseif (strcmpi(doDespike, 'yes') && (tc_filter == 0))
            disp('Despiking timecourses ...');
        elseif (strcmpi(doDespike, 'no') && (tc_filter > 0))
            disp('Filtering timecourses ...');
        end
        
        % Preprocess timecourses
        for nComp = 1:numroi
            current_tc = squeeze(tc(nSub, nSess, :, nComp));
            
            % Despiking timecourses
            if (strcmpi(doDespike, 'yes'))
                current_tc = icatb_despike_tc(current_tc, TR);
            end
            
            % Filter timecourses
            if (tc_filter > 0)
                current_tc = icatb_filt_data(current_tc, TR, tc_filter);
            end
            tc(nSub, nSess, :, nComp) = current_tc;
        end
        
        % Apply circular shift to timecourses
        tcwin = zeros(Nwin, volume, numroi);
        for ii = 1:Nwin
            Ashift = circshift(A, round(-volume/2) + round(input_params.window_length/2) + ii);
            tcwin(ii, :, :) = squeeze(tc(nSub, nSess, :, :)).*Ashift;
        end
        
        if strcmpi(method, 'L1')
            useMEX = 0;
            try
                GraphicalLassoPath([1, 0; 0, 1], 0.1);
                useMEX = 1;
            catch
            end
            
            disp('Using L1 regularisation ...');
            
            % L1 regularisation
            Pdyn = zeros(Nwin, numroi*(numroi - 1)/2);
            
            fprintf('\t rep ')
            % Loop over no of repetitions
            for r = 1:num_repetitions
                fprintf('%d, ', r)
                [traivolumeC, testTC] = split_timewindows(tcwin, 1);
                traivolumeC = icatb_zscore(traivolumeC);
                testTC = icatb_zscore(testTC);
                [wList, thetaList] = computeGlasso(traivolumeC, initial_lambdas, useMEX);
                obs_cov = icatb_cov(testTC);
                L = cov_likelihood(obs_cov, thetaList);
                Lambdas(r, :) = L;
            end
            
            fprintf('\n')
            [mv, minIND] =min(Lambdas, [], 2);
            blambda = mean(initial_lambdas(minIND));
            fprintf('\tBest Lambda: %0.3f\n', blambda)
            best_lambda(dataSetCount) = blambda;
            
            % now actually compute the covariance matrix
            fprintf('\tWorking on estimating covariance matrix for each time window...\n')
            for ii = 1:Nwin
                %fprintf('\tWorking on window %d of %d\n', ii, Nwin)
                [wList, thetaList] = computeGlasso(icatb_zscore(squeeze(tcwin(ii, :, :))), blambda, useMEX);
                a = icatb_corrcov(wList);
                a = a - eye(numroi);
                FNCdyn(ii, :) = lc_mat2vec(a);
                InvC = -thetaList;
                r = (InvC ./ repmat(sqrt(abs(diag(InvC))), 1, numroi)) ./ repmat(sqrt(abs(diag(InvC)))', numroi, 1);
                r = r + eye(numroi);
                Pdyn(ii, :) = mat2vec(r);
            end
            
            FNCdyn = atanh(FNCdyn);
            FNCdyn = lc_vec2mat(FNCdyn,numroi);
            disp(['.... saving file ', results_file]);
            icatb_save(fullfile(input_params.result_dir, results_file), 'Pdyn', 'Lambdas', 'FNCdyn');
            
        elseif strcmpi(method, 'none')
            % No L1
            for ii = 1:Nwin
                a = icatb_corr(squeeze(tcwin(ii, :, :)));
                [FNCdyn(ii, :), ind] = lc_mat2vec(a);
            end
            FNCdyn = atanh(FNCdyn);
            FNCdyn = lc_vec2mat(FNCdyn,numroi);
            
            disp(['.... saving file ', results_file]);
            save(fullfile(input_params.result_dir, results_file), 'FNCdyn');
        end
        
        outFiles{dataSetCount} = results_file;
        disp('Done');
        fprintf('\n');
        
    end
    % End of loop over sessions
end
% End of loop over subjects

input_params.best_lambda = best_lambda;
input_params.outputFiles = outFiles;
fileN = fullfile(input_params.result_dir, [input_params.prefix, '.mat']);
disp(['Saving parameter file ', fileN, ' ...']);
totalTime = toc;

fprintf('\n');
disp('Analysis Complete');
disp(['Total time taken to complete the analysis is ', num2str(totalTime/60), ' minutes']);
diary('off');
fprintf('\n');










