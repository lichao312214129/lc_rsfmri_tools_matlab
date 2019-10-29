function lc_suit(subjpath,outdir)
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

%% Prepare data
ns = length(subjpath);
subname = cell(ns,1);
for i = 1:ns
	[~,subname{i}] = fileparts(subjpath{i});
end

%% Add path
spm_dir = fileparts(which('spm'));
toolbox = [spm_dir '/toolbox/suit'];
addpath(genpath(toolbox));

%% Start SPM
spm fmri
tic;
%% Loop for all subjects
ns = numel(subjpath);
sumarrymat = cell(ns,1);
for i = 1:ns
    % Find the subject .nii file
    fprintf([repmat('=',1,30),'%d/%d subject',repmat('=',1,30),'\n'],i,ns);
    isubjpath = subjpath{i};
    filesrtuct = dir(fullfile(isubjpath, '*.nii*'));
    file = fullfile(isubjpath,filesrtuct.name);
    
    %  If the subect have more files, then return error
    if numel({filesrtuct.name}) >1 
        error([isubjpath,' have more files']);
    end
    
    % -*- Exe main function
    disp('Main processing...');
    lc_suit_gui_base(file);
    
    % Get summary.mat file path
    disp('Getting summary.mat file path...');
    [~, filename] = fileparts(file);
    [path, ~,suffix] = fileparts(file);
    [~,name] = fileparts(path);
    sumarrymat{i} = fullfile(outdir,name,'summary.mat');   
    
    % Group produced file to outdir
    disp('Grouping produced files to outdir...');
    producedfiles = dir(path);
    producedfiles = {producedfiles.name}';
    producedfiles = producedfiles(3:end);
    moveloc = ~ismember(producedfiles, [filename,suffix]);
    file_to_move = fullfile(path, producedfiles(moveloc));
    groupfile(isubjpath,file_to_move, outdir);
end

%% Summary all excel files of all subjects to one file
fprintf([repmat('=',1,30),'Summarizing allinfo to one file',repmat('=',1,30),'\n']);
allsubname = cell(1,ns);
gsize = cell(ns,1);
gmean = cell(ns,1);
gmin = cell(ns,1);
gmax = cell(ns,1);
gnanmean = cell(ns,1);
% Getting summary data
disp('Getting summary data...');
for i = 1:ns
    summary_struct= importdata(sumarrymat{i});
    gsize{i} = summary_struct.size(:,1);
    gmean{i} = summary_struct.mean;
    gmin{i} = summary_struct.min;
    gmax{i} = summary_struct.max;
    gnanmean{i} = summary_struct.nanmean;
%     gregionname = summary_struct.region;
    if i == 1
        Data = zeros(ns, numel(gmean{i})*5);
    end
    Data(i,:) = cat(1,gmean{i},gmin{i},gmax{i},gnanmean{i},gsize{i});
    allsubname(i) = subname(i);
end

% Region name
disp('Getting region name...');
orignal_region_name = importdata([spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii.lut']);
splitrn = cellfun(@strsplit,orignal_region_name,'UniformOutput',false);
myfun = @(s) {str2double(s{1})};
region_atalas = cell2mat(cellfun(myfun,splitrn));
myfun = @(s) {s{end}};
region_name = cellfun(myfun,splitrn);
header = {'mean','min','max','nanmean','size'};
% In some cases, gregionname should match with the region_name.

% Save to excels
try 
    disp('Saving to excel...');
    region_name = repmat(region_name',1,5); 
    Excel = actxserver('Excel.Application');
    set(Excel, 'Visible', 0);
    Workbooks = Excel.Workbooks;
    Workbook = invoke(Workbooks, 'Add');
    Sheets = Excel.ActiveWorkBook.Sheets;
    sheet1 = get(Sheets, 'Item', 1);
    invoke(sheet1, 'Activate');
    Activesheet = Excel.Activesheet;
    blocklength = numel(gmean{1});
    for i = 1:5
        start = 2+(i-1)*blocklength;
        endpoint = start+blocklength-1;
        
        if start <= 26  % the first row was given to subname
            startchar = [upper(char(0+start-1+97)),'1'];
        elseif (start > 26) && (start <= 26*27)
            whichloop = ceil(start/26)-1;
            loc_in_loop = start - whichloop*26;
            startchar = [upper(char(0+whichloop-1+97)),upper(char(0+loc_in_loop-1+97)),'1'];
        else
            disp('The number of columns is out of the range: ZZ1');
        end
        
        if endpoint <= 26   % the first row was given to subname
            endpointchar = [upper(char(0+endpoint+97)),'1'];
        elseif (endpoint > 26) && (endpoint <= 26*27)
            whichloop = ceil(endpoint/26)-1;
            loc_in_loop = endpoint - whichloop*26;
            endpointchar = [upper(char(0+whichloop-1+97)),upper(char(0+loc_in_loop-1+97)),'1'];
        else
            disp('The number of columns is out of the range: ZZ1');
        end
        rangestr = [startchar,':',endpointchar];
        ActivesheetRange = get(Activesheet,'Range',rangestr);
        set(ActivesheetRange,'MergeCells',1);
        set(ActivesheetRange,'HorizontalAlignment',3);
        set(ActivesheetRange,'Value',header{i});
    end
    
    outexcelname = fullfile(outdir, 'All_Subject_Information.xlsx');
    Activesheet.SaveAs(outexcelname); Quit(Excel); delete(Excel);
    xlswrite(outexcelname,region_name,'sheet1','B2');
    xlswrite(outexcelname,Data,'sheet1','B3');
    xlswrite(outexcelname,allsubname','sheet1','A3');
catch
    disp('Saving to txt...');
    Gmean = pre_tabel(gmean,region_name',ns);
    Gmax = pre_tabel(gmax,region_name',ns);
    Gmin = pre_tabel(gmin,region_name',ns);
    Gsize = pre_tabel(gsize,region_name',ns);
    Gnanmean = pre_tabel(gnanmean,region_name',ns);
    T = table(Gmean,Gmax,Gmin,Gnanmean,Gsize,'RowNames',cat(1,'region',allsubname'));
    writetable(T,fullfile(outdir,'summary.txt'),'WriteRowNames',true','WriteVariableNames' ,1,'Delimiter',',') ;
end
toc;
fprintf([repmat('=',1,30),'Congratulations! All done!',repmat('=',1,30),'\n']);
end

function pro_data = pre_tabel(data,region,ns)
sall = {};
for i = 1:ns
    tmp = data{i};
    s = {};
    for j = 1:numel(tmp)
        s = cat(2,s,tmp(j));
    end
    sall = cat(1,sall,s);
end
pro_data = [region; sall];
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
    'stats', {'nanmean','max','min','size','mean','std'});
% save to mat
save(fullfile(path,'summary.mat'),'D');

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
% xlswrite(excelfile,region_name,'sheet1','A1');
% xlswrite(excelfile,size,'sheet1','B1');

%% Reslice back from SUIT space to native space.
disp('reslice back to native space...')
job.Affine={affineTrfile};
job.flowfield={flowfieldfile};
job.resample={graymatterfile};
job.ref={fullfile(path,[name,'.nii'])};  %  initial T1
suit_reslice_dartel_inv(job);
end
