function [ Signal] = Extract_ROI_Signal4D(numOfVolume)
% This function waa used to extract multiple signals from 3D or 4D data. 
% If 4D data, the dimension 4 is the volume/time point
% input:
%     data:5D data, dimension 4 is volume/time point,dimension 5 is the number of subjects;
%     mask:3D logic matrix, equal to a volume.
%     numOfVolume= number of volume
% output:
%     signals (for each subject): N*M, N=number of ROI, M=number of volume/time points.
% Examples data
% all_subj = {'D:\WorkStation_2018\Workstation_Old\WorkStation_2018_07_DynamicFC_insomnia\FunImgARWS\Csub1\swra20130103_095407FEEPIHRSENSE25sCLEARfuweihes501a1000.nii',...
% 'D:\WorkStation_2018\Workstation_Old\WorkStation_2018_07_DynamicFC_insomnia\FunImgARWS\Csub1\swra20130323_161137FEEPIHRSENSE25sCLEARlixias401a1000.nii'};
% outdir = 'F:\Data\Doctor';
% mask_file = 'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\lc_rsfmri_tools_matlab\Workstation\Decoding the transdiagnostic psychiatric diseases at the dimension level\VoxelLabelMatchingBetweenTwoBrainAtalas\sorted_brainnetome_atalas_3mm.nii';
%% ===============================================================================================================
%% Inputs
% path to save results
if nargin < 3
	outdir=uigetdir({},'Select folder to save results');
	outdir=fullfile(outdir,'Signals');
	if ~(exist(outdir,'dir') == 7)
		mkdir(outdir);
	end
end

% mask
if nargin < 2
	[nameOfMask,pathOfMaks,~] = uigetfile({'*.nii;*.img;','All Image Files';...
	    '*.*','All Files'},'MultiSelect','off','Select mask');
	mask_file=fullfile(pathOfMaks,nameOfMask);
end

% Source data
if nargin < 1
	dirContainAllSubj=uigetdir({},'Select directory containing subjects');
	dirOfAllSubj=dir(dirContainAllSubj);
	nameOfAllSubj={dirOfAllSubj.name};
	nameOfAllSubj=nameOfAllSubj(3:end)';
	all_subj=fullfile(dirContainAllSubj,nameOfAllSubj);
end

%%
% prepare data
mask=y_Read(mask_file);
% preallocate
numOfSubj=length(all_subj);
% Signal=zeros(numOfSubj,numOfVolume);
% extract signal according subject's order
for i=1:numOfSubj
    if mod(i,10)==0
        fprintf('%.0f%%\n',i*100/numOfSubj);
    else
        fprintf('%.0f%%\t',i*100/numOfSubj);
    end
    data=y_Read(all_subj{i});
    signal = extract_ROI_signal(data,mask);
    % save
    [~,name]=fileparts(nameOfAllSubj{i});
    save([outdir,filesep,name,'.mat'],'signal');
end
%% save all signal
% save([outdir,filesep,'signalAllSubj_From_',nameOfMask,'.mat'],'Signal');
% fprintf('\n===============Completed!===================\n');
end

function signal = extract_ROI_signal(data,mask)
unique_roi = setdiff(unique(mask),0);  % exclude zero.
num_unique_roi = numel(unique_roi);
num_timepoints = size(data,4);
signal = zeros(num_timepoints,num_unique_roi);
for i = 1:num_unique_roi
    fprintf('%d\n',i)
    mask_ith = mask == unique_roi(i);
    signal_oneroi = zeros(num_timepoints,1);
    for j = 1:num_timepoints
        data_onetimepoint = data(:,:,:,j);
        signal_oneroi(j) = mean(data_onetimepoint(mask_ith));
    end
    signal(:,i) = signal_oneroi;
end
end

