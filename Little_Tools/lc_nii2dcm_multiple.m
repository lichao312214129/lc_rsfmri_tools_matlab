function lc_nii2dcm_multiple(nii_files, out_path)
% transfer multiple nii files to dcm with changed name dcm_name
%%
if nargin < 2
    out_path = uigetdir(pwd, '选择结果保存位置');
end
if nargin < 1
    nii_files = get_files_name();
end
%%
if iscell(nii_files)
    n_files = length(nii_files);
    for i = 1:n_files
        [~, name] = fileparts(nii_files{i});
        lc_nii2dcm_3D(nii_files{i}, fullfile(out_path, name));
        fprintf('%d/%d\n',i, n_files)
    end
else
    [~, name] = fileparts(nii_files);
    lc_nii2dcm_3D(nii_files, fullfile(out_path, strcat(name, '.dcm')));
end

end

function nii_files = get_files_name()
[name, path] = uigetfile('*.nii', '选择nii文件', 'MultiSelect', 'on');
nii_files = fullfile(path, name);
end

function lc_nii2dcm_3D(nii_file, dcm_folder)
%lc_nii2dcm used to transfer 3D nifti data to dicom file
if ~exist(dcm_folder, 'dir')
    mkdir(dcm_folder);
end

nii = load_nii(nii_file);
niidata = nii.img;
n_frame = size(niidata, 3);
for i = 1:n_frame
    savename = fullfile(dcm_folder, strcat('file',num2str(i), '.dcm'));
    dataset = double(niidata(:,:,i));
    dicomwrite(dataset, savename);
end
end

