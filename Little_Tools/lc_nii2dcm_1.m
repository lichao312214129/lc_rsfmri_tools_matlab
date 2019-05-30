function lc_nii2dcm_1(nii_file, dcm_name)
%lc_nii2dcm used to transfer nifti file to dicom file
nii = load_nii(nii_file);
niidata = nii.img;
dicomwrite(niidata, dcm_name);
end

