function lc_img2nii(out_path,in_path,out_suffix,in_suffix)
% transform .img files to .nii
%%
% read all files
disp('====== runing ======');

if nargin < 4
    in_suffix='.img';
end

if nargin < 3
    out_suffix='.nii';
end

if nargin < 2
    %in_path='F:\黎超\dynamicFC\Code\lc_rsfmri_tools_matlab-master\Dcm2nii\dcm2nii_LC\test';
    %out_path='F:\黎超\dynamicFC\Code\lc_rsfmri_tools_matlab-master\Dcm2nii\dcm2nii_LC';
	in_path=uigetdir(pwd,'img文件夹');
end

if nargin < 1
	out_path=uigetdir(pwd,'结果保持文件夹');
end

try
    all_file=dir(fullfile(in_path,['*',in_suffix]));
catch
    all_file=dir([in_path,filesep,'*',in_suffix]);
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

% .img to .nii
[data,~,~,header]=y_ReadAll(all_file_path);

n_subj=length(all_file_name);
for i =1:n_subj
    disp([num2str(i),'/',num2str(n_subj)]);
    [~,out_name]=fileparts(all_file_name{i});
    try
        y_Write(data(:,:,:,1),header,fullfile(out_path,[out_name,out_suffix]));
    catch
        disp('=== old version ===');
        y_Write(data(:,:,:,1),header,[out_path,filesep,out_name,out_suffix]);
    end
end
disp('====== All Done! ======');
end

