%% Partial Least Squares (PLS) for Neuroimaging %%
% Main script

% Behavior PLS : looks for optimal associations between imaging and
% behavior data. Imaging can be either a volume (voxel-based)
% (e.g., brain activity) or a functional correlation matrix. 
% If input is a volume, a binary mask should be entered so that all
% subjects have the same number of voxels.

% Requires SPM for loading & reading volumes

% ~ PLS steps ~
% 1. Data normalization
% 2. Cross-covariance matrix
% 3. Singular value decomposition
% 4. Brain & behavior scores
% 5. Permutation testing for LV significance
% 6. Bootstrapping to test stability of brain saliences
% 7. Contribution of original variables to the LVs

% ~ FIGURES ~
% I.   Screeplot (explained covariance)
% II.  Correlations between brain & behavior scores
% III. Brain saliences (bootstrap ratio)
% IV. Behavior saliences
% V.  Brain structure coefficients
% VI. Behavior structure coefficients


% NOTE FOR DATASETS WITH SUBJECTS FROM DIFFERENT GROUPS 
% (e.g., controls & patients) : it is possible to normalize data 
% within each group instead of across subjects 
% (options 1,3 in myPLS_norm & change subj_grouping to diagnosis_grouping)
% Note that permutations and bootstrapping should be done within each 
% group, rather than across all subjects.


% ~~~~~~ CREDITS ~~~~~~~~~
% Code written by Prof. Dimitri Van De Ville, Daniela Zoller and Valeria
% Kebets, with subfunctions borrowed from PLS toolbox by Rotman Baycrest
% (https://www.rotman-baycrest.on.ca/index.php?section=84)

% Please cite the following papers when using this code for your analyses:

% Zoller D, Schaer M, Scariati E, Padula MC, Eliez S, Van De Ville D (2017).
% Disentangling resting-state BOLD variability and PCC
% functional connectivity in 22q11.2 deletion syndrom.
% Neuroimage 149, pp. 85-97.
%
% McIntosh AR, Lobaugh NJ (2004). Partial least squares analysis of
% neuroimaging data: applications and advances.
% Neuroimage 23(Suppl 1), pp. S250-263.

clear
close all

%% Set parameters

% Paths
scriptsPath = [ pwd() '/PLS_code' ] ;
inputPath = [ pwd() '/example_data' ] ;  % 
outputPath = [ pwd() '/results' ] ; % where results/plots will be saved
addpath(genpath(scriptsPath)); % add subfunctions to MATLAB path

% Indicate type of imaging data
imagingType = 'volume' ; % 'volume' (voxel-based) or 'corrMat' (correlation matrix)
    
% Behavior
%CONST_BEHAV_NAMES = {''} ; % names of behavior measures 

% Data normalization options (% default=1 - zscore across all subjects)
CONST_NORM_IMAGING = 1; 
CONST_NORM_BEHAV = 1;

% Groups information
%NUM_GROUPS = 2;
%CONST_DIAGNOSIS = {'',''}; % names groups
%diagnosis_grouping = [ones(30,1);  2*ones(32,1)];

% Permutations & Bootstrapping
NUM_PERMS = 200;
NUM_BOOTSTRAP = 100;

resultsFilename = 'myPLSresults_example'; % name of results file that will be saved in outputPath

%% Load data

% Matrix X is typically a matrix with imaging data,
% of size subjects (rows) x imaging features (columns)
% Matrix Y is a a matrix containing behavior data,
% of size subjects (rows) x behavior features (columns)

% Load X and Y

%%%%%%%% LOAD YOUR DATA HERE %%%%%%%%

% Example 1: task activity during associative memory encoding in MCI
% patients and elderly controls 
load([ inputPath '/data_CMST.mat' ]);
X=X0; Y=Y0; clear X0 Y0
NUM_GROUPS = 2;
maskFile = spm_vol(fullfile(inputPath,'groupTemplate_CMST.nii')); % filename of binary mask that will constrain analysis 

% Example 2: resting-state FC in 4 psychiatric groups
% load([ inputPath '/data_CNP.mat' ]);
% CONST_BEHAV_NAMES(3:54)=[]; Y0(:,3:54)=[];
% X=X0; Y=Y0; clear X0 Y0
% NUM_GROUPS = 4;
% NUM_PERMS = 100; NUM_BOOTSTRAP = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch imagingType
    case 'volume'
                  
        % Load mask
        mask = spm_read_vols(maskFile);
        maskIdx = find(mask ~= 0);
        
        % Make sure the mask is binary 
        a = unique(mask); 
        if size(a,1)>2, 
            disp('Please input binary mask');
        end
        clear a
        
        % Load images for each subject and constrain data within mask
%         for iter_subj = 1:CONST_NUM_SUBJ
%             clear A Ai
%             myImg = spm_vol('volume.nii'); 
%             A = spm_read_vols(Ai); 
%             X(iter_subj,:)=A(maskIdx);
%         end
        
    case 'corrMat'
        
        nRois = 419; 
%         
%         for iter_subj = 1:CONST_NUM_SUBJ
%             clear A Ai
%             myCM = load('FC.mat'); 
%             nRois = size(myCM,1); % number of regions in correlation matrix
%             X(iter_subj,:)=jUpperTriMatToVec(myCM,1); % vectorize correlation matrix, and stack all subjects together
%         end
        
        
end

% Check if X and Y matrices have same number of rows (subjects)
if size(X,1) ~= size(Y,1)
    disp('Matrices X and Y should have same number of rows [number of samples]');
end

% Get number of subjects
CONST_NUM_SUBJ = size(X,1); % number of subjects
CONST_NUM_IMAGING = size(X,2);  % number of imaging measures
CONST_NUM_BEHAV = size(Y,2);% number of behavior measures

subj_grouping = ones(CONST_NUM_SUBJ,1);

%% 1. Normalize X and Y

% Save original matrices
X0 = X; Y0 = Y;

X = myPLS_norm(X,1,subj_grouping,CONST_NORM_IMAGING);
Y = myPLS_norm(Y,1,subj_grouping,CONST_NORM_BEHAV);

%% 2. Cross-covariance matrix
clear R

R = myPLS_cov(X,Y,1,subj_grouping);

%% 3. Singular value decomposition
clear U S V

[U,S,V] = svd(R,'econ');
NUM_LVs = min(size(S));

% ICA convention: turn latent variables (LVs) such that max is positive
for iter_lv = 1 : NUM_LVs
    [~,idx] = max(abs(V(:,iter_lv)));
    if sign(V(idx,iter_lv)) < 0,
        V(:,iter_lv) = -V(:,iter_lv);
        U(:,iter_lv) = -U(:,iter_lv);
    end;
end;

explVarLVs = (diag(S).^2) / sum(diag(S.^2)); % Explained covariance by each LV

%% 4. Brain and behavior scores
clear Lx Ly

Lx = X * V; % Brain scores : original imaging data projected on brain saliences
Ly = Y * U; % Behavior scores : original behavior data projected on behavior saliences

%% 5. Permutation testing for LV significance

clear perm_order Xp Yp Rp Up Sp Vp rotatemat permsamp sp mypvals mySignifLVs numSignifLVs

disp('... Permutations ...')
for iter_perm = 1:NUM_PERMS,
    
    % Display number of permutations (every 50 permuts)
    if mod(iter_perm,50) == 0, disp(num2str(iter_perm)); end
    
    % Leave X unchanged (no need to permute both X and Y matrices)
    Xp = X; % X is already normalized
    
    % Permute Y by shuffling rows (subjects) within groups
    if NUM_GROUPS == 1
        perm_order = randperm(size(Y,1));
        Yp = Y0(perm_order,:);
        
    elseif NUM_GROUPS > 1
        Yp = [];
        for iter_group = 1:NUM_GROUPS
            clear thisY0 thisYp
            thisY0 = Y0(find(diagnosis_grouping == iter_group),:);
            perm_order = randperm(size(thisY0,1));
            thisYp = thisY0(perm_order,:);
            Yp = [Yp; thisYp];
        end
    end    
    
    % Normalize permuted Y
    Yp = myPLS_norm(Yp,1,subj_grouping,CONST_NORM_BEHAV);
    
    % Cross-covariance matrix between X and permuted Y
    Rp = myPLS_cov(Xp,Yp,1,subj_grouping);
    
    % SVD of Rp
    [Up,Sp,Vp] = svd(Rp,'econ');
    
    % Procrustas transform (to correct for axis rotation/reflection)
    rotatemat = rri_bootprocrust(U, Up);
    Up = Up * Sp * rotatemat; 
    Sp = sqrt(sum(Up.^2)); 
    
    % Keep singular values for sample distribution of singular values
    permsamp(:,iter_perm) = Sp';
    
    if iter_perm == 1, 
        sp = (Sp' >= diag(S));
    else
        sp = sp + (Sp' >= diag(S));
    end;
    
end;

myLVpvals = (sp + 1) ./ (NUM_PERMS + 1);

mySignifLVs = find(myLVpvals<0.05); % index of significant LVs
numSignifLVs = size(mySignifLVs,1); % number of significant LVs

% Display significant LVs
disp([num2str(numSignifLVs) ' significant LV(s)']);
for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);
    disp(['LV' num2str(this_lv) ' - p=' num2str(myLVpvals(this_lv),'%0.3f') ]);
end

%% 6. Bootstrapping to test stability of brain saliences

clear all_boot_orders Xb Yb Rb Ub Sb Vb rotatemat Vbmean Vbmean2 Ubmean Ubmean2 Ub_std Vb_std Ures Vres

% Get bootstrap subject sampling
if NUM_GROUPS == 1
    [all_boot_orders,~] = rri_boot_order(CONST_NUM_SUBJ,1,NUM_BOOTSTRAP);
    
elseif NUM_GROUPS > 1    
    all_boot_orders = [];
    for iter_group = 1:NUM_GROUPS
        clear boot_order num_subj_group  
        num_subj_group = size(find(diagnosis_grouping==iter_group),1);
        [boot_order,~] = rri_boot_order(num_subj_group,1,NUM_BOOTSTRAP);
        all_boot_orders = [all_boot_orders; boot_order];
    end
end

disp('... Bootstrapping ...');
for iter_boot = 1 : NUM_BOOTSTRAP,
    
    % Display number of bootstraps (every 50 samples)
    if mod(iter_boot,50) == 0, disp(num2str(iter_boot)); end
    
    % Bootstrap of X
    Xb = X0(all_boot_orders(:,iter_boot),:);
    Xb = myPLS_norm(Xb,1,subj_grouping,CONST_NORM_IMAGING);
    
    % Bootstrap of Y
    Yb = Y0(all_boot_orders(:,iter_boot),:);
    Yb = myPLS_norm(Yb,1,subj_grouping,CONST_NORM_BEHAV);
    
    % Bootstrap version of R
    Rb = myPLS_cov(Xb,Yb,1,subj_grouping);
    
    % SVD of Rb
    [Ub,Sb,Vb] = svd(Rb,'econ');
    
    % Procrustas transform (to correct for axis rotation/reflection)
    rotatemat = rri_bootprocrust(U, Ub);
    Vb = Vb * rotatemat;
    Ub = Ub * rotatemat;
    
    % Online computing of mean and variance
    if iter_boot == 1,
        Vb_mean = Vb;
        Ub_mean = Ub;
        Vb_mean2 = Vb.^2;
        Ub_mean2 = Ub.^2;
    else
        Vb_mean = Vb_mean + Vb;
        Ub_mean = Ub_mean + Ub;
        
        Vb_mean2 = Vb_mean2 + Vb.^2;
        Ub_mean2 = Ub_mean2 + Ub.^2;
    end
    
end

% Calculation of standard errors of saliences
Ub_mean = Ub_mean / NUM_BOOTSTRAP;
Ub_mean2 = Ub_mean2 / NUM_BOOTSTRAP;
Vb_mean = Vb_mean / NUM_BOOTSTRAP;
Vb_mean2 = Vb_mean2 / NUM_BOOTSTRAP;

Ub_std = sqrt(Ub_mean2 - Ub_mean.^2); Ub_std = real(Ub_std);
Vb_std = sqrt(Vb_mean2 - Vb_mean.^2); 
 
% Bootstrap ratio (ratio of saliences by standard error)
Ures = U ./ Ub_std;
Vres = V ./ Vb_std; 

% Change bootstrapped saliences in case they contain infinity 
% (when Ub_std/Vb_std are close to 0)
inf_Vvals = find(~isfinite(Vres));
for iter_inf = 1:size(inf_Vvals,1)
    Vres(inf_Vvals(iter_inf)) = V(inf_Vvals(iter_inf));
end
inf_Uvals = find(~isfinite(Ures));
for iter_inf = 1:size(inf_Uvals,1)
    Ures(inf_Uvals(iter_inf)) = U(inf_Uvals(iter_inf));
end

clear inf_Vvals inf_Uvals iter_inf

%% Contribution of original variables to LVs
% Brain & behavior structure coefficients (Correlations imaging/behavior variables - brain/behavior scores)

clear myBrainStructCoeff myBehavStructCoeff

% Brain structure coefficients
for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);
    
    for iter_img = 1:size(X,2)
        clear tmpy tmpx r p
        tmpx = X(:,iter_img);
        tmpy = Lx(:,this_lv);
        [r,p] = corrcoef(tmpx,tmpy.');
        myBrainStructCoeff(iter_img,iter_lv) = r(1,2);
    end
    
end

% Behavior structure coefficients
for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);

    for iter_behav = 1:size(Y,2),
        clear tmpy tmpx r p
        tmpx = Y(:,iter_behav);
        tmpy = Ly(:,this_lv);        
        [r,p] = corrcoef(tmpx,tmpy.');
        myBehavStructCoeff(iter_behav,iter_lv) = r(1,2);
    end
end


%% PLOTS

%% I. Scree plot

if CONST_NUM_BEHAV > 2,
    figure; myScreePlot(diag(S),1);
end
 
% Display covariance explained by each significant LV
for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);
    disp(['LV' num2str(this_lv) ' explains ' num2str(round(100*explVarLVs(this_lv))) '% of covariance']);    
end

%% II. Correlations between brain and behavior scores

CONST_PLOT={'bx','rx','co','gx','mx'}; % 
CONST_PLOT = CONST_PLOT(1:NUM_GROUPS);

clear r p

for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);
    
    figure;    
    for iter_group = 1:numel(CONST_DIAGNOSIS),
        plot(Lx(find(diagnosis_grouping == iter_group),this_lv),...
            Ly(find(diagnosis_grouping == iter_group),this_lv),CONST_PLOT{iter_group});
        hold on;
    end
    
    title(['LV' num2str(this_lv) ': Correlations between brain and behavior scores']);
    xlabel(['Brain scores LV' num2str(this_lv)]);
    ylabel(['Behavior scores LV' num2str(this_lv)]);
    legend(CONST_DIAGNOSIS);
    
    [r,p] = corr(Lx(:,this_lv),Ly(:,this_lv));
    disp(['r = ' num2str(r,'%0.2f') ' p=' num2str(p,'%0.3f')]);
    
end

%% III. Brain saliences (bootstrap ratio [BSR])
% Display output will depend on type of imaging data (volume or correlation matrix)            

switch imagingType
    case 'volume'
        
        BSRthreshold = 2; % BSR is akin to zscore -> threshold of 2 is ~p=0.05, 3 is ~p=0.01
        
        for iter_lv = 1:numSignifLVs
            this_lv = mySignifLVs(iter_lv);
            
            % ~~ Write bootstrap ratio (BSR) into volume ~~           
            % Constrain BSR to mask
            clear myBSR Vi
            myBSR = zeros(size(mask));
            myBSR(maskIdx) = Vres(:,this_lv);            
            Vi = maskFile;
            Vi.dt = [spm_type('float32') 0];
            Vi.fname = fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainSaliences.nii']);
            spm_write_vol(Vi,myBSR);
            
            % ~~ Display BSR map ~~
            
            % Load template object 
            load(fullfile(scriptsPath,'myobj_axial.mat')); % sagittal & coronal views also possible

            % Load BSR volume to get minimum/maximum values
            clear Ai A myMin myMax
            Ai = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainSaliences.nii']));
            A = spm_read_vols(Ai);
            myMax = max(max(max(A)));
            myMin = min(min(min(A)));
            
            figure(11*iter_lv);
            set(gcf,'name',['LV' num2str(this_lv) ' - Brain saliences']);
            set(gcf,'Position',[484 77 560 751]);
            myobj.img(1).vol = spm_vol(fullfile(scriptsPath,'ch2.nii')); % template
            myobj.img(2).vol = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainSaliences.nii'])); % positive values of BSR map
            myobj.img(3).vol = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainSaliences.nii'])); % negative values of BSR map
            myobj.img(2).range = [BSRthreshold myMax];
            myobj.img(3).range = [-BSRthreshold myMin];
            myobj.figure = 11*iter_lv ;
            paint(myobj);
            
        end
        
        
    case 'corrMat'
        
        for iter_lv = 1:numSignifLVs
            this_lv = mySignifLVs(iter_lv);           

            clear CM
            CM=jVecToSymmetricMat(Vres(:,this_lv),nRois);
            figure; imagesc(CM);
            colormap('jet'); colorbar;
            xlabel('ROIs');
            ylabel('ROIs');
            title(['LV' num2str(this_lv) ' - Brain saliences']);
            
            saveas(gcf,fullfile(outputPath,['LV' num2str(this_lv) '_brainSaliences.png']),'png');
        end
end

%% IV. Behavior saliences

for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);
    
    figure;
    bar(reshape(U(:,this_lv),[CONST_NUM_BEHAV 1]));
    xlabel('Behavioral variables');
    ylabel('Behavioral saliences');
    title(['LV' num2str(this_lv) ' - Behavior saliences']);    
    hold on
    %errorbar((1:CONST_NUM_BEHAV)-.15+.30*(1-1), ...
    %U(CONST_NUM_BEHAV*(1-1)+(1:CONST_NUM_BEHAV),this_lv),...
    %Ub_std(CONST_NUM_BEHAV*(1-1)+(1:CONST_NUM_BEHAV),this_lv),'r.','MarkerSize',10);
    hold off
    
end

%% V. Brain structure coefficients
% Display will depend on type of imaging data (volume or correlation matrix)

corrThreshold = 0.25; % 

switch imagingType
    case 'volume'
        
        for iter_lv = 1:numSignifLVs
            this_lv = mySignifLVs(iter_lv);
                       
            % ~~ Write brain structure coefficients into volume ~~           
            % Constrain map to mask
            clear myMap Vi
            myMap = zeros(size(mask));
            myMap(maskIdx) = myBrainStructCoeff(:,iter_lv);
            Vi = maskFile;
            Vi.dt = [spm_type('float32') 0];
            Vi.fname = fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainStructCoeff.nii']);
            spm_write_vol(Vi,myMap);
            
            % ~~ Display map of correlations ~~
            % Load BSR volume to get minimum/maximum values
            clear Ai A myMin myMax
            Ai = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainStructCoeff.nii']));
            A = spm_read_vols(Ai);
            myMax = max(max(max(A)));
            myMin = min(min(min(A)));
             
            % Load template object
            load(fullfile(scriptsPath,'myobj_axial.mat')); % sagittal & coronal views also possible

            figure(12*iter_lv);
            set(gcf,'name',['LV' num2str(this_lv) ' - Brain structure coefficients']);
            set(gcf,'Position',[484 77 560 751]);
            myobj.img(1).vol = spm_vol(fullfile(scriptsPath,'ch2.nii')); % template
            myobj.img(2).vol = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainStructCoeff.nii'])); % positive values of BSR map
            myobj.img(3).vol = spm_vol(fullfile(outputPath,['myPLS_LV' num2str(this_lv) '_brainStructCoeff.nii'])); % negative values of BSR map
            myobj.img(2).range = [corrThreshold myMax];
            myobj.img(3).range = [-corrThreshold myMin];
            myobj.figure = 12*iter_lv ;
            paint(myobj);
            
        end
               
    case 'corrMat'
        
        for iter_lv = 1:numSignifLVs
            this_lv = mySignifLVs(iter_lv);
            clear CM
            CM=jVecToSymmetricMat(myBrainStructCoeff(:,iter_lv),nRois);
            figure; imagesc(CM);
            colormap('jet'); colorbar;
            xlabel('ROIs');
            ylabel('ROIs');
            title(['LV' num2str(this_lv) ' - Brain structure coefficients']);
            saveas(gcf,fullfile(outputPath,['LV' num2str(this_lv) '_brainStructCoeff.png']),'png');
        end
end

clear tmpy tmpx r p CM

%% VI. Behavior structure coefficients
% Display top values only 

numTopVals = CONST_NUM_BEHAV; % number of top correlations to display
if CONST_NUM_BEHAV>20 
    numTopVals=20;
end

for iter_lv = 1:numSignifLVs
    this_lv = mySignifLVs(iter_lv);

    clear absCorrs sortedCorrs sortIdx sortedCorrs2 sortIdx2 top_absCorrs top_vars 
    
    % Sort absolute values of correlations and select top values
    absCorrs = abs(myBehavStructCoeff(:,iter_lv));
    [sortedCorrs,sortIdx] = sort(absCorrs,'descend');
    top_absCorrs = myBehavStructCoeff(sortIdx(1:numTopVals),iter_lv);
    top_vars = CONST_BEHAV_NAMES(sortIdx(1:numTopVals))';
    
    % Sort again within the top values
    [sortedCorrs2,sortIdx2] = sort(top_absCorrs,'descend');
    mySortedTopCorrs(:,iter_lv) = top_absCorrs(sortIdx2);
    mySortedTopVars{:,iter_lv} = top_vars(sortIdx2);
    
    figure;
    bar(mySortedTopCorrs(:,iter_lv));
    xlabel('Behavioral variables');
    ylabel('Correlations');
    title(['LV' num2str(this_lv) ' - Behavior structure coefficients']);
    saveas(gcf,fullfile(outputPath,['LV' num2str(this_lv) '_behavStructCoeff.png']),'png');
    
    disp(['Top correlations for LV' num2str(this_lv) ' :']);
    for iter_corr = 1:numTopVals
        disp([mySortedTopVars{iter_lv}{iter_corr} ' - r=' num2str(mySortedTopCorrs(iter_corr,iter_lv),'%0.2f')]);
    end
end

% Clear all temporary variables
clear num_subj_group Rb Vp Up Vb Ub Xp Yp Yb Xb perm_order rotatemat Rp Sb Sp thisY0 thisYp low_CI high_CI tmpx tmpy r p iter_perm iter_lv this_lv iter_img iter_lv idx iter_behav iter_boot iter_group 

%% Save workspace with results

save(fullfile(outputPath,[resultsFilename '.mat']));
