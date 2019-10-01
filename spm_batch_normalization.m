% normalize ASL&CBF image through T1 image using unified segmentation
clear

SubjID = 1:10; %[3,6,7,9,11,13,26,29,30,34];
for kSubj = 1:length(SubjID)
    subjname = sprintf('NC%03d',SubjID(kSubj)); % subjname = sprintf('psy%03d',SubjID(kSubj));
    fprintf('\n%s\n', subjname);
    Coregister_RefImage = ['D:\Data\DataForTrainingCourse\3DASL\MengProcessed\ASL\ASL_' subjname '.nii,1'];
    Coregister_SourceImage = ['D:\Data\DataForTrainingCourse\3DASL\MengProcessed\T1\T1_' subjname '.nii,1'];
    Normalize_WriteImages{1,1} = ['D:\Data\DataForTrainingCourse\3DASL\MengProcessed\ASL\ASL_' subjname '.nii,1'];
    Normalize_WriteImages{2,1} = ['D:\Data\DataForTrainingCourse\3DASL\MengProcessed\CBF\CBF_' subjname '.nii,1'];
    BoundingBox = [-90 -126 -72;  90 90 108];
    VoxelSize = [2 2 2];
    
    save TemInfo.mat Coregister_RefImage Coregister_SourceImage Normalize_WriteImages BoundingBox VoxelSize;
    
    % List of open inputs
    nrun = 1; % enter the number of runs here
    jobfile = {'D:\Data\DataForTrainingCourse\3DASL\MengProcessed\scripts\spm_batch_normalization_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(0, nrun);
    for crun = 1:nrun
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
end

fprintf('\n\nALL FINISHED!');