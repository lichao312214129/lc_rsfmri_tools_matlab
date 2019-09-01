function input_params = lc_dfc_roiwise_v1(input_params)
% Modified from GIFT. Uses must cite the GIFT software.
% Used to calculate roi-wise dynamic fc using sliding-window method.
% input:
%   all_subjects_files: all subjects' files (wich abslute path)
% 	result_dir: directiory for saving results
% 	TR = 2;
% 	volume = 190;
% 	numroi = 114;
%   window_step: sliding-window step
%   window_length: sliding-window length
%   window_type: e.g., Gaussian window
%   window_alpha: Gaussian window alpha, e.g., 3TRs
% 	% Default and other parameters
% 	numOfSess = 1;
% 	doDespike = 'no';
% 	tc_filter = 0;
% 	method = 'L1';
% 	num_repetitions = 10;
% 	prefix = '';
% output
%   zDynamicFC: dynamic FC matrix with Fisher r-to-z transformed; size=N*N*W, 
% 	N is the number of ROIs, W is the number of sliding-window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% input
% Interactive
if nargin < 1
    input_params.ini = 1;
end

if ~isfield(input_params, 'all_subjects_files')
    all_subjects_files =uigetdir(pwd, 'select directory that containing all subjects'' data');
    all_subjects_files =dir(all_subjects_files);
    folder={all_subjects_files.folder};
    name={all_subjects_files.name}';
    name = name(3:end);
    all_subjects_files =cell(length(name),1);
    for i =1:length(name)
        all_subjects_files {i}=fullfile(folder{i},name{i});
    end
else
    all_subjects_files = input_params.all_subjects_files;
end

if ~ isfield(input_params, 'result_dir')
    result_dir = uigetdir(pwd, 'select directory that saving results');
else
    result_dir = input_params.result_dir;
end

% Case-sensitive. Only for my paper currently.
% TODO: Interactive
TR = 2;
volume = 190;
numroi = 114;
window_alpha = 3;
window_length = 17;
window_step = 1;

% Default and other parameters
numOfSess = 1;
doDespike = 'no';
tc_filter = 0;
method = 'L1';
num_repetitions = 10;
prefix = '';

% make result directory
result_dir_of_dynamic = fullfile(result_dir, strcat('zDynamicFC_WindowLength',num2str(window_length),'_WindowStep',num2str(window_step)));
if ~exist(result_dir_of_dynamic, 'dir')
    mkdir(result_dir_of_dynamic);
end

%% ---------------------------Run-----------------------------------
% Load timeseries
tic;
numOfSub = length(all_subjects_files);
tc = zeros(numOfSub, numOfSess, volume, numroi);
for i = 1:numOfSub
   tc(i, 1,:,:) = importdata(all_subjects_files{i});
end

% Make sliding window
c = icatb_compute_sliding_window(volume, window_alpha, window_length);
A = repmat(c, 1, numroi);
Nwin = volume - window_length;

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
        
        results_file = [prefix, name{nSub}];
        
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
            Ashift = circshift(A, round(-volume/2) + round(window_length/2) + ii);
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
                % InvC = -thetaList;
                % r = (InvC ./ repmat(sqrt(abs(diag(InvC))), 1, numroi)) ./ repmat(sqrt(abs(diag(InvC)))', numroi, 1);
                % r = r + eye(numroi);
                % Pdyn(ii, :) = lc_mat2vec(r);
            end
            
            FNCdyn = atanh(FNCdyn);
            FNCdyn = lc_vec2mat(FNCdyn,numroi);
            disp(['.... saving file ', results_file]);
            % icatb_save(fullfile(result_dir_of_dynamic, results_file), 'Pdyn', 'Lambdas', 'FNCdyn');
            icatb_save(fullfile(result_dir_of_dynamic, results_file), 'FNCdyn');  % Discard saving Pdyn and Lambdas
            
        elseif strcmpi(method, 'none')
            % No L1
            for ii = 1:Nwin
                a = icatb_corr(squeeze(tcwin(ii, :, :)));
                [FNCdyn(ii, :), ind] = lc_mat2vec(a);
            end
            FNCdyn = atanh(FNCdyn);
            FNCdyn = lc_vec2mat(FNCdyn,numroi);
            
            disp(['.... saving file ', results_file]);
            save(fullfile(result_dir_of_dynamic, results_file), 'FNCdyn');
        end
        
        outFiles{dataSetCount} = results_file;
        disp('Done');
        fprintf('\n');
        
    end
    % End of loop over sessions
end
% End of loop over subjects

dfc_info.best_lambda = best_lambda;
dfc_info.outputFiles = outFiles;
fileN = fullfile(result_dir_of_dynamic, [prefix,'dfc_info', '.mat']);
disp(['Saving parameter file ', fileN, ' ...']);
save(fileN,'dfc_info')
totalTime = toc;

fprintf('\n');
disp('Analysis Complete');
disp(['Total time taken to complete the analysis is ', num2str(totalTime/60), ' minutes']);
diary('off');
fprintf('\n');



%% plot test
load Mycolormap_state;
if_save=0;
if_add_mask=0;
mask_path=ones(114)==1;
net_path='ROISignals_00558_resting_Covremoved.mat';
how_disp='all';% or 'only_neg'
if_binary=0; %二值化处理，正值为1，负值为-1
which_group=1;
net_index_path='D:\My_Codes\Github_Related\Github_Code\Template_Yeo2011\netIndex.mat';
lc_netplot(net_path,1,mask_path,how_disp,if_binary,which_group, net_index_path);

ct = 1;
for i = 1: 5: 160
    subplot(6,6,ct)
    lc_netplot(FNCdyn(:,:,i),1,mask_path,how_disp,if_binary,which_group, net_index_path);
%     imagesc(FNCdyn(:,:,i));
    colormap(mymap_state)
    caxis([-0.8 0.8]);
    ct = ct +1;
end









