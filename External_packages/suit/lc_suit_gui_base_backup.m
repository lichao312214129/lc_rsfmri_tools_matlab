function lc_suit_gui_base_background(file)
% This function is used to call suit software for one .nii file
% Inputs:
%  file: .nii file that needs to process.

%% Pre-processing
% file = 'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\External_packages\suit\T1Img\sub002\01987_3D.nii';
[path, name] = fileparts(file);

%% Segmentation
disp('segmentation...');
suit_isolate_seg({file});

%% Gen mask for normalation
[gray_matter, header] = y_Read(fullfile(path,[name,'_seg1.nii']));
white_matter = y_Read(fullfile(path,[name,'_seg2.nii']));
mask = gray_matter + white_matter;
y_Write(mask, header, fullfile(path,[name,'_mask.nii']))

%% Normalization
disp('normalation...');
job.subjND.gray = {fullfile(path,[name,'_seg1.nii'])};
job.subjND.white = {fullfile(path,[name,'_seg2.nii'])};
job.subjND.isolation = {fullfile(path,[name,'_mask.nii'])};
suit_normalize_dartel(job);

%% Reslice
disp('reslice...');
job.subj(1).affineTr={fullfile(path,['Affine_',name,'_seg1.mat'])};
job.subj(1).flowfield={fullfile(path,['u_a_',name,'_seg1.nii'])};
job.subj(1).resample={fullfile(path,[name,'_seg1.nii'])};
job.subj(1).mask={fullfile(path,[name,'_mask.nii'])};
job.jactransf = 1;  % use for VBM
suit_reslice_dartel(job);

%% Summray
% FIX ME: This part removed after the suit_reslice_dartel_inv
% disp('summary...')
% spm_dir = fileparts(which('spm'));
% atlas=[spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii'];
% D = suit_ROI_summarize(fullfile(path,['wd',name,'_seg1.nii']),...
%     'atlas', atlas,...
%     'outfilename',fullfile(path,'summary.txt'));
% % region name
% regionname = importdata([spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii.lut']);
% splitrn = cellfun(@strsplit,regionname,'UniformOutput',false);
% myfun = @(s) {str2double(s{1})};
% region_atalas = cell2mat(cellfun(myfun,splitrn));
% myfun = @(s) {s{end}};
% region_name = cellfun(myfun,splitrn);
% % Matching region id
% region_sum = D.region;
% size = D.size;
% [~,idx]=ismember(region_sum,region_atalas);
% size = size(idx);
% % Save
% xlswrite(fullfile(path,'size_summary.xlsx'),region_name,'sheet1','A1');
% xlswrite(fullfile(path,'size_summary.xlsx'),size,'sheet1','B1');

%% Reslice back from SUIT space to native space.
disp('reslice back to native space...')
job.Affine={fullfile(path,['Affine_',name,'_seg1.mat'])};
job.flowfield={fullfile(path,['u_a_',name,'_seg1.nii'])};
job.resample={fullfile(path,[name,'_seg1.nii'])};
job.ref={fullfile(path,[name,'.nii'])};  %  original T1
suit_reslice_dartel_inv(job);

%% Get volume size in  native space
disp('Getting volume size in native space...')
spm_dir = fileparts(which('spm'));
atlas=[spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii'];
D = suit_ROI_summarize(fullfile(path,['iw_',name,'_seg1_u_a_',name, '_seg1.nii']),...
    'atlas', atlas,...
    'outfilename',fullfile(path,'summary.txt'));

% region name
regionname = importdata([spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii.lut']);
splitrn = cellfun(@strsplit,regionname,'UniformOutput',false);
myfun = @(s) {str2double(s{1})};
region_atalas = cell2mat(cellfun(myfun,splitrn));
myfun = @(s) {s{end}};
region_name = cellfun(myfun,splitrn);
% Matching region id
region_sum = D.region;
size = D.size;
[~,idx]=ismember(region_sum,region_atalas);
size = size(idx);
% Save
xlswrite(fullfile(path,'size_summary.xlsx'),region_name,'sheet1','A1');
xlswrite(fullfile(path,'size_summary.xlsx'),size,'sheet1','B1');
%% =======================================================================
end