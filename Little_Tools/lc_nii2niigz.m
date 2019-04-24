function lc_nii2niigz(out_path,in_path,dcm2nii_path)
% transform .nii files to .nii.gz files 
%%
% input
if nargin < 3
    dcm2nii_path=pwd;
end

if nargin < 2
    in_path=uigetdir(pwd,'.nii文件夹');
end

if nargin < 1
    out_path=uigetdir(pwd,'结果保持文件夹');
end

% fetch all nii path
try
    all_file=dir(fullfile(in_path,'*.nii'));
catch
    all_file=dir([in_path,filesep,'*.nii']);
end
all_file_name={all_file.name};
try
    all_file_path=fullfile(in_path,all_file_name)';
catch
    disp('=== old version ===');
    n_subj=length(all_file_name);
    all_file_path=cell(n_subj,1);
    for i =1:n_subj
        all_file_path{i}=[in_path,filesep,all_file_name{i}];
    end
end

% nii to nii.gz and move to outpath
n_subj=length(all_file_name);
for i =1:n_subj
    cmd=[
        strcat(dcm2nii_path,'\dcm2nii.exe'),...
        ' -b ' strcat(dcm2nii_path,'\dcm2nii_conv.ini'), ...
        [' ',all_file_path{i}]
    ];
system(cmd);
% remove .nii.gz to out_path
in_file=strcat(in_path,['\f',all_file_name{i},'.gz']);
out_file=strcat(out_path,['\',all_file_name{i},'.gz']);
fprintf('%s\n%s\n%s\n%s\n','move',in_file,'to',out_file);
movefile(in_file,out_file)
end
disp('====== All Done! ======');
end