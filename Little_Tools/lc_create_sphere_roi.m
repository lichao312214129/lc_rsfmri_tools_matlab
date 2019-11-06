function lc_create_sphere_roi()
% This function is based on DPABI
% This function is used to Create a Sphere ROI
[RefFile,path] = uigetfile({'*.nii';'*.img';'*.nii.gz'},'Select reference file');
RefFile = fullfile(path,RefFile);
OutFile = fullfile(path,'binary_mask.nii');
Center = input('Input center coordinates:','s');
Center = str2num(Center);
Radius = input('Input radious(mm):','s');
Radius = str2double(Radius);

[SphereData, Header] = y_Sphere(Center, Radius, RefFile, OutFile, 'XYZ');
disp('Done!')
fprintf('Created mask is %s\n',OutFile);
end