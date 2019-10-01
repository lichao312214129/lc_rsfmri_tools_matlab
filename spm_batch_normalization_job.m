%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------

load TemInfo.mat


matlabbatch{1}.spm.spatial.coreg.estimate.ref = {Coregister_RefImage};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {Coregister_SourceImage};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.preproc.data(1) = cfg_dep;
matlabbatch{2}.spm.spatial.preproc.data(1).tname = 'Data';
matlabbatch{2}.spm.spatial.preproc.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.spatial.preproc.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.spm.spatial.preproc.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.spatial.preproc.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.spatial.preproc.data(1).sname = 'Coregister: Estimate: Coregistered Images';
matlabbatch{2}.spm.spatial.preproc.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.spatial.preproc.data(1).src_output = substruct('.','cfiles');
matlabbatch{2}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{2}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{2}.spm.spatial.preproc.output.CSF = [0 0 0];
matlabbatch{2}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{2}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{2}.spm.spatial.preproc.opts.tpm = {
                                               'E:\Software\Toolboxes\spm8\spm8\tpm\grey.nii'
                                               'E:\Software\Toolboxes\spm8\spm8\tpm\white.nii'
                                               'E:\Software\Toolboxes\spm8\spm8\tpm\csf.nii'
                                               };
matlabbatch{2}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
matlabbatch{2}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{2}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{2}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{2}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{2}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{2}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{2}.spm.spatial.preproc.opts.msk = {''};
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1) = cfg_dep;
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).tname = 'Parameter File';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).sname = 'Segment: Norm Params Subj->MNI';
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.spatial.normalise.write.subj.matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});
matlabbatch{3}.spm.spatial.normalise.write.subj.resample = Normalize_WriteImages;
matlabbatch{3}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{3}.spm.spatial.normalise.write.roptions.bb = BoundingBox;
matlabbatch{3}.spm.spatial.normalise.write.roptions.vox = VoxelSize;
matlabbatch{3}.spm.spatial.normalise.write.roptions.interp = 1;
matlabbatch{3}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.normalise.write.roptions.prefix = 'w';
