function lc_check_headmotion()
% Getting headmotion parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regstr_FD = 'FD_Power';
regstr_rigid_body = 'rp_a';
FD_mov_thresh = 0.2;
proportion_thresh = 0.3;
rigidbody_thresh = 3;
savepath = 'F:\Data\Doctor';

% Getting headmotion files' path 
[FD_path, rigidbody_path, all_name]  = select_files(regstr_FD, regstr_rigid_body);

% Calculating headmotion and saving to savepath
calc_headmotion(FD_path, rigidbody_path, all_name, ...
    FD_mov_thresh, proportion_thresh, rigidbody_thresh, savepath);

fprintf('Done\n');
end

function [FD_path, rigidbody_path, all_name]  = select_files(regstr_FD, regstr_rigid_body)
% Goal:Extracting FD and rigid body movement files' path using regular expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read all subj path
rootpath = 'F:\Data\Doctor\RealignParameter';
all_path = dir(rootpath);
all_name = {all_path.name}';
all_name = all_name(3:end);
all_subpath = fullfile(rootpath, all_name);

% Selecting file path
n_sub = length(all_subpath);
FDname = cell(n_sub,1);
rigidbod_name= cell(n_sub,1);
myf_ifmatch_FD = @(x) regexp(x, regstr_FD);
myf_ifmatch_rigid_body = @(x) regexp(x, regstr_rigid_body);
myf_identymatch = @(x) ~isempty(x);
for i = 1:n_sub
    file_cont = dir(all_subpath{i});
    file_cont = {file_cont.name}';
    % FD power
    match_cont_FD = cellfun(myf_ifmatch_FD, file_cont, 'UniformOutput',false);
    match_loc_FD = cellfun(myf_identymatch, match_cont_FD, 'UniformOutput',false);
    match_loc_FD = cell2mat(match_loc_FD);
    if sum(match_loc_FD) > 1
        fprintf('Subject %s have more matched files!\n',all_subpath{i});
        fprintf('Only choose the first one\n')
        loc = find(match_loc_FD);
        FDname{i} = file_cont(loc(1));
    else
        FDname{i} = file_cont(match_loc_FD);
    end
    % rigid body
    match_cont_rigidbody = cellfun(myf_ifmatch_rigid_body, file_cont, 'UniformOutput',false);
    match_loc_rigidbody = cellfun(myf_identymatch, match_cont_rigidbody, 'UniformOutput',false);
    match_loc_rigidbody = cell2mat(match_loc_rigidbody);
    if sum(match_loc_rigidbody) > 1
        fprintf('Subject %s have more matched files!\n',all_subpath{i});
        fprintf('Only choose the first one\n')
        loc = find(match_loc_rigidbody);
        rigidbod_name{i} = file_cont(loc(1));
    else
        rigidbod_name{i} = file_cont(match_loc_rigidbody);
    end
end
myf_fullfile = @(p1,p2) fullfile(p1, p2);
FD_path = cellfun(myf_fullfile, all_subpath, FDname);
rigidbody_path = cellfun(myf_fullfile, all_subpath, rigidbod_name);
end

function calc_headmotion(FD_path, rigidbody_path, all_name, FD_mov_thresh, proportion_thresh, rigidbody_thresh, savepath)
% Goal:
%   1:Calculate mean FD
%   2:Calculate proportion of 'bad' time point with large FD
%   3: Calculate max rigidbody movtion
% parameters:
%   all_target_path: E.g., all FD files' path
%   FD_mov_thresh: bad head movement threshold, e.g., 0.2mm
%   proportion_thresh: When the proportion_thresh, the subjects were
%   rigidbody_thresh: rigidbody_threshold, e.g., 3mm and 3 degree
%   excluded; e.g., 0.3 (30%)
%   savepath: path to save results
% example:
%    mov_thresh = 0.2;
%    proportion_thresh = 0.3;
%    rigidbody_thresh = 3 (3mm or 3 degree);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_sub = length(FD_path);
% FD power
meanFD = zeros(n_sub,1);
proportion_of_bad_timepoints = zeros(n_sub,1);
ex_sub_FD = {};
for i = 1:n_sub
    fprintf('%d\n',i);
    FD = load(FD_path{i});
    proportion_of_bad_timepoints(i) = sum(FD > FD_mov_thresh)/length(FD);
    meanFD(i) = mean(FD);
    if (meanFD(i) > FD_mov_thresh) || (proportion_of_bad_timepoints(i) > proportion_thresh)
        ex_sub_FD = [ex_sub_FD; all_name{i}];
    end
end

% rigid body
max_rigidbody_mov = zeros(n_sub,6);
ex_sub_rigidbody = {};
for i = 1:n_sub
    fprintf('%d\n',i);
    rigidbody_mov = load(rigidbody_path{i});
    max_rigidbody_mov (i,:) = max(rigidbody_mov);
    if any(max_rigidbody_mov(i,:) > rigidbody_thresh) 
        ex_sub_rigidbody = [ex_sub_rigidbody; all_name{i}];
    end
end

%% save to excel
fprintf('Saving results\n');
% excluded subjects
xlswrite(fullfile(savepath, 'excluded_subjects.xlsx'),{'FD','rigidbody'},1, 'A1');
xlswrite(fullfile(savepath, 'excluded_subjects.xlsx'),ex_sub_FD,1, 'A2');
xlswrite(fullfile(savepath, 'excluded_subjects.xlsx'),ex_sub_rigidbody,1, 'B2');

% move informations
mov_info = [meanFD, proportion_of_bad_timepoints,max_rigidbody_mov];
xlswrite(fullfile(savepath, 'headmovement.xlsx'),...
    {'subjects','meanFD','proportion_of_bad_timepoints',...
    'translation_x','translation_y','translation_z'...
    'rotation_x','rotation_y','rotation_z'},1, 'A1');
xlswrite(fullfile(savepath, 'headmovement.xlsx'),all_name,1, 'A2');
xlswrite(fullfile(savepath, 'headmovement.xlsx'),mov_info,1, 'B2');
end