function tmp4dnii = lc_3Datlas_to_4Datlas(filename)
% transform 3D image (fname) to 4D image (each 3D image only containing one ROI/component).
[path, name, suffix] = fileparts(filename);
[image_3d, header] = y_Read(filename);
uni_roi = setdiff(unique(image_3d(:)), 0);
n_roi = numel(uni_roi);
[i, j, k] = size(image_3d);
image_4d = zeros(i, j, k, n_roi);
for i = 1:n_roi
    i
    image_3d_i = image_3d;
    image_3d_i(image_3d_i ~= uni_roi(i)) = 0;
    image_4d(:,:,:,i) = image_3d_i;
end
tmp4dnii = fullfile(path, 'tmp4Dnii.nii');
y_Write(image_4d, header, tmp4dnii);