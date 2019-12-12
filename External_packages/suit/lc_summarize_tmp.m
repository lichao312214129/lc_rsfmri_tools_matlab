%% Inputs
source_root = 'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\External_packages\suit\12-12';
result_root = 'D:\My_Codes\LC_Machine_Learning\lc_rsfmri_tools\External_packages\suit\Test';

%%
spm_dir = fileparts(which('spm'));
atlas=[spm_dir '/toolbox/suit/atlasesSUIT/Lobules-SUIT.nii'];
root = dir(source_root);
names = {root.name}';
names = names(3:end);
if iscell(names)
    n_subj = length(names);
else
    n_subj = 1;
end
%
size = zeros(n_subj, n_region);
for i = 1:n_subj
    name = names{i};
    fprintf('%d/%d: %s...\n', i, n_subj, name);
    path = fullfile(result_root,name);
    
    disp('Reslicing back to native space...')
    affineTrfile = fullfile(path,['Affine_',name,'_seg1.mat']);
    flowfieldfile = fullfile(path,['u_a_',name,'_seg1.nii']);
    reslicegraymatterfile = atlas;
    graymatterfile = fullfile(path,[name,'_seg1.nii']);
    job.Affine={affineTrfile};
    job.flowfield={flowfieldfile};
    job.resample={atlas};
    job.ref=graymatterfile;
    suit_reslice_dartel_inv(job);
    
    disp('Getting size...')
    targefile = fullfile(path, ['iw_Lobules-SUIT_u_a_',name, '_seg1.nii']);
    targetdata = y_Read(targefile);
    n_region = numel(setdiff(unique(targetdata(:)),0));
  
    for j = 1:n_region
        size(i,j) = length(find(targetdata == j));
    end
end

%% Sortting results
T1 = array2table(size);
T2 = cell2table(names);
T = cat(2,T2,T1);
writetable(T,'size.csv')