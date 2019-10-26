function excelfile = lc_suit_gui(subjpath,outdir)
% This function is used to call suit software for one .nii file.
% Inputs:
%   rootdir: directory that contains all subject directory.
% Author: Li Chao.

%% Suggestions
word = sprintf(['1. Put SUIT software under the ''toolbox'' folder in SPM software directory.\n'...
    '2. Make sure that the data structure is T1Img-->sub00n-->T1.nii.\n'...
    '3. Select the ''T1Img'' folder in the folder selection dialog box.\n']);
h = questdlg(word,'Note.','continue','exit','continue');
switch h
    case 'exit'
        disp('Buy Now...');
        return
    case 'continue'
        disp('Continue...');
    otherwise
        quit cancel;
end

%% Inputs
if nargin < 2
    outdir = uigetdir(pwd, 'Select directory to save results');
end

if nargin < 1
    rootdir = uigetdir(pwd, 'Select folder containing all subjects'' T1');
    subjdirs = dir(rootdir);
    subjdirs = subjdirs(3:end);
    subname = {subjdirs.name}';
    subjpath = fullfile(rootdir, subname);
end

%% Add path
spm_dir = fileparts(which('spm'));
toolbox = [spm_dir '/toolbox/suit'];
addpath(genpath(toolbox));

%% Start SPM
spm fmri

%% Loop for all subjects
ns = numel(subjpath);
excelfile = cell(ns,1);
for i = 1:ns
    fprintf('%d/%d subject\n',i,ns);
    isubjpath = subjpath{i};
    filesrtuct = dir(fullfile(isubjpath, '*.nii'));
    file = fullfile(isubjpath,filesrtuct.name);
    %  if the sub have more files
    if numel({filesrtuct.name}) >1 
        error([isubjpath,' have more files']);
    end
    
    % -*- Exe main function
    lc_suit_gui_base(file);
    
    % Extract excel file name
    [~, filename] = fileparts(file);
    [path, ~,suffix] = fileparts(file);
    [~,name] = fileparts(path);
    excelfile{i} = fullfile(outdir,name,'size_summary.xlsx');    
    % Group produced file to another outdir
    producedfiles = dir(path);
    producedfiles = {producedfiles.name}';
    producedfiles = producedfiles(3:end);
    moveloc = ~ismember(producedfiles, [filename,suffix]);
    file_to_move = fullfile(path, producedfiles(moveloc));
    groupfile(isubjpath,file_to_move, outdir);
end

%% Summary all excel files of all subjects to one file
disp('Summarize all size info to one file...');
allsubname = cell(1,ns);
for i = 1:ns
    [data, rn] = xlsread(excelfile{i});
    if i == 1
        Data = rand(numel(data),ns);
    end
    Data(:,i) = data;
    allsubname(i) = subname(i);
end
outexcelname = fullfile(outdir, 'all_sub_size_info.xlsx');
xlswrite(outexcelname,{'Regions'},'sheet1','A1');
xlswrite(outexcelname,allsubname,'sheet1','B1');
xlswrite(outexcelname,rn,'sheet1','A2');
xlswrite(outexcelname,Data,'sheet1','B2');

disp('All Done!');
end

function groupfile(isubjpath,file_to_move, outdir)
% Group produced file to another outdir
[~, foldername] = fileparts(isubjpath);
outsubdir = fullfile(outdir,foldername);
if ~(exist(outsubdir,'dir') == 7)
    mkdir(outsubdir);
end
nf = numel(file_to_move);
for j = 1:nf
    try
        [~,outfile,suffix] = fileparts(file_to_move{j});
        movefile(file_to_move{j}, outsubdir);
    catch
        disp('No such file');
    end
end
end

function [graymatterfile, whitematterfile, maskfile, affineTrfile,...
    flowfieldfile, reslicegraymatterfile, summaryfile,...
    excelfile,iwfile,cfile,pcerebfile] =  lc_suit_gui_base(file)
% This function is used to call suit software for one .nii file
% Inputs:
%  file: .nii file that needs to process.
% Returns:
%    Produced files that may need to be moved to another directory.
%% Pre-processing
[path, name] = fileparts(file);
% All produced file names, which was needed to move to other folder
graymatterfile = fullfile(path,[name,'_seg1.nii']);
whitematterfile = fullfile(path,[name,'_seg2.nii']);
maskfile = fullfile(path,[name,'_mask.nii']);

affineTrfile = fullfile(path,['Affine_',name,'_seg1.mat']);
flowfieldfile = fullfile(path,['u_a_',name,'_seg1.nii']);

reslicegraymatterfile = fullfile(path,['wd',name,'_seg1.nii']);

summaryfile = fullfile(path,'summary.txt');

excelfile = fullfile(path,'size_summary.xlsx');

iwfile = fullfile(path,['iw_',name,'_seg1_u_a_',name,'_seg1.nii']);
cfile = fullfile(path,['c_',name,'.nii']);
pcerebfile = fullfile(path,['c_',name,'_pcereb.nii']);

%% Segmentation
disp('segmentation...');
suit_isolate_seg({file});

%% Gen mask for normalation
[gray_matter, header] = y_Read(graymatterfile);
white_matter = y_Read(whitematterfile);
mask = gray_matter + white_matter;
y_Write(mask, header,maskfile);

%% Normalization
disp('normalation...');
job.subjND.gray = {graymatterfile};
job.subjND.white = {whitematterfile};
job.subjND.isolation = {maskfile};
suit_normalize_dartel(job);

%% Reslice
disp('reslice...');
job.subj(1).affineTr={affineTrfile};
job.subj(1).flowfield={flowfieldfile};
job.subj(1).resample={graymatterfile};
job.subj(1).mask={maskfile};
job.jactransf = 1;  % use for VBM
suit_reslice_dartel(job);

%% Summray
disp('summary...')
spm_dir = fileparts(which('spm'));
atlas=[spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii'];

D = suit_ROI_summarize(reslicegraymatterfile,...
    'atlas', atlas,...
    'outfilename',summaryfile);
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
xlswrite(excelfile,region_name,'sheet1','A1');
xlswrite(excelfile,size,'sheet1','B1');

%% Reslice back from SUIT space to native space.
disp('reslice back to native space...')
job.Affine={affineTrfile};
job.flowfield={flowfieldfile};
job.resample={graymatterfile};
job.ref={fullfile(path,[name,'.nii'])};  %  initial T1
suit_reslice_dartel_inv(job);
end
