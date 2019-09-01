function lc_dfc_roiwise_base_roiwise_v0(input_params)
%  Used to calculate  roi-wise dynamic fc using sliding-window method for one group of subjects
%  This is similar to DPABI software, but not GIFT software.
% input:
%   all_subjects_files: all subjects' files (wich abslute path)
%   result_dir:
%   directiory for saving results
%   input_params.window_step: sliding-window step
%   input_params.window_length: sliding-window length
%   input_params.window_type: e.g., Gaussian window
%   input_params.window_alpha: Gaussian window alpha, e.g., 3TRs
% output
%   zDynamicFC: dynamic FC matrix with Fisher r-to-z transformed; size=N*N*W, N is the number of ROIs, W is the number of sliding-window
%   zStaticFC: static FC matrix with Fisher r-to-z transformed; size=N*N, N is the number of ROIs
%   varOfZDynamicFC: variance of dynamic FC
%% input
tic
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

if ~ isfield(input_params, 'window_type')
    input_params.window_type = 'Gaussian';
end

if ~ isfield(input_params, 'window_alpha')
    input_params.window_alpha = 3;
end

if ~ isfield(input_params, 'window_length')
    input_params.window_length = 17;
end

if ~ isfield(input_params, 'window_step')
    input_params.window_step = 1;
end

if ~ isfield(input_params, 'calc_dynamic')
    % TODO: Revise lc_dfc_roiwise_base.m
    input_params.calc_dynamic = 1;
    input_params.calc_static = 1;
end

% make dir
result_dir_of_static = fullfile(input_params.result_dir, strcat('zStaticFC_WindowLength',num2str(input_params.window_length),'_WindowStep',num2str(input_params.window_step)));
result_dir_of_dynamic = fullfile(input_params.result_dir, strcat('zDynamicFC_WindowLength',num2str(input_params.window_length),'_WindowStep',num2str(input_params.window_step)));
if ~exist(result_dir_of_static, 'dir')
    mkdir(result_dir_of_static);
end
if ~exist(result_dir_of_dynamic, 'dir')
    mkdir(result_dir_of_dynamic);
end
%% calculate both the static and dynamic Inter-ROI FC
fprintf('==================================\n');
fprintf(' Calculating dynamic FC\n');
nSubj=length(input_params.all_subjects_files);
for s=1:nSubj
    fprintf('Calculating %d/%d subject...\n',s,nSubj);
    data_dir=input_params.all_subjects_files{s};
    time_series_of_all_node=importdata(data_dir);
    
    if input_params.calc_dynamic==1 && input_params.calc_static==1
        [zDynamicFC,zStaticFC]=lc_dfc_roiwise_base(time_series_of_all_node,input_params.window_step,input_params.window_length, input_params.window_type, input_params.window_alpha);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_dynamic,filesep,name,format],'zDynamicFC');
        save([result_dir_of_static,filesep,name,format],'zStaticFC');
        
    elseif input_params.calc_dynamic==1 && input_params.calc_static==0
        [zDynamicFC,~]=lc_dfc_roiwise_base(time_series_of_all_node,input_params.window_step,input_params.window_length, input_params.window_type, input_params.window_alpha);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_static,filesep,name,format],'zDynamicFC');
        
    elseif input_params.calc_dynamic==0 && input_params.calc_static==1
        [~,zStaticFC]=lc_dfc_roiwise_base(time_series_of_all_node,input_params.window_step,input_params.window_length, input_params.window_type, input_params.window_alpha);
        % save
        [~,name,format]=fileparts(data_dir);
        save([result_dir_of_static,filesep,name,format],'zStaticFC');
        
    else
        fprintf('do nothing!\n')
        return
    end
end
fprintf('==================================\n');
fprintf('Dynamic FC calculating completed!\n');
toc
end