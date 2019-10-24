MATLAB implementation of Behaviour Partial Least Squares (PLS) for Neuroimaging


Behaviour PLS looks for optimal associations between imaging and behavior data. 

Imaging data can be either a volume (voxel-based; e.g., brain activity) or a functional correlation matrix. If input is a volume, a binary mask should be entered so that all subjects have the same number of measures.

NOTE FOR DATASETS WITH SUBJECTS FROM DIFFERENT GROUPS (e.g., controls & patients) : 
Group information can be entered; the default options constrain the PLS to maximize covariance between imaging and behaviour latent variables across all subjects, not within groups. Data normalization is also computed across all subjects.
It is possible to normalize data within each group instead of across subjects (options 1,3 in myPLS_norm & change subj_grouping to diagnosis_grouping). Note that independently of how data is normalized, permutations and bootstrapping should be computed within each group, rather than across all subjects.

~~~~~~~~~ DESCRIPTION ~~~~~~~~~

PLS code contains: 

myPLS_PR4NI: main script
myPLS_norm : computes data normalisation 
myPLS_cov : computes cross-covariance matrix
myScreePlot : scree plot to visualize explained variance

ch2.nii : T1 MRI template (from MRIcron, used for visualisation)

myobj_axial/coronal/sagittal : Matlab object files for slover visualisation (http://imaging.mrc-cbu.cam.ac.uk/imaging/DisplaySlices)

jUpperTriMatToVec,jVecToSymmetricMat : transform (correlation) matrix to vector, and vice versa

rri_boot_check, rri_boot_order_ rri_bootprocrust : bootstrap functions (from Rotman Baycrest PLS toolbox)


~~~~~~~~~ REQUIREMENTS ~~~~~~~~~

Requires SPM8/12 for loading & reading volumes, and for visualisation (@slover functions).


~~~~~~~~~ CREDITS ~~~~~~~~~

Code written by Prof. Dimitri Van De Ville, Daniela Zöller and Valeria Kebets.
Are also included 3 functions (rri_boot_check, rri_boot_order, rri_bootprocrust) from the PLS toolbox by Rotman Baycrest (https://www.rotman-baycrest.on.ca/index.php?section=84).

Please cite the following papers when using this code:

Zoller D, Schaer M, Scariati E, Padula MC, Eliez S, Van De Ville D (2017). Disentangling resting-state BOLD variability and PCC functional connectivity in 22q11.2 deletion syndrome. Neuroimage 149, pp. 85-97.

McIntosh AR, Lobaugh NJ (2004). Partial least squares analysis of neuroimaging data: applications and advances. Neuroimage 23(Suppl 1), pp. S250-263.	



If you have issues, please email Valeria (valkebets@gmail.com)