function lc_functional_segmentation(varargin)
% GOAL: This function is used to segment one region into several sub-regions
% according to its function connectivity with other regions.
% NOTE: Function of Reading NIfTI file is revised from DPABI, if you used the function, please cite both DPABI and this function.
% varargin have follow field:
% ---------------------------
%   atalas_file: the atlas file
%   exclude_region_file: region need to exclude
%   target_file: the data needed segmentation
%   target_region_id: region index of target regions that needed to be segmented.
%   network_index_atlas: network index of each region in atlas.
%   data_dir: directory of all 4D files.
%   criterion: using which type coefficient to identify the max
%   correlation. ( 'all_coef', 'pos_coef', 'neg_coef')
%   out_name: output name of the segmented file.
% example:
% --------
%     lc_functional_segmentation('atalas_file', 'file/of/your/atalas_file.nii', 'exclude_region_file', '...', ...)
%% --------------------------------------------------
%% Step 0 is setting inputs and loading.
% Inputs
 [atalas_file,target_file, target_region_id, exclude_mask_file, network_index_atlas, data_dir,...
 criterion, out_name] = parse_inputs(varargin{:});

% Load
[atalas, header_atalas] = y_Read(atalas_file);
if ~strcmp(exclude_mask_file, '')
    exclude_mask = y_Read(exclude_mask_file); 
    atalas = atalas .* (exclude_mask == 0);
end
network_index_atlas = load(network_index_atlas);
[dim1, dim2, dim3] = size(atalas);

data_strut = dir(data_dir);
data_path = fullfile(data_dir, {data_strut.name});
data_path = data_path(3:end)';

n_sub = length(data_path);
datafile_path = cell(n_sub,1);
for i = 1: n_sub
    fprintf('%d/%d\n', i, n_sub);
    one_data_strut = dir(data_path{i});
    one_data_path = fullfile(data_path{i}, {one_data_strut.name});
    one_data_path = one_data_path(3:end);
    datafile_path(i) = one_data_path(1);
end

%% Main
% To get the mask in which 1 is the target region.
% num_target_network = length(unique(target_region_id));
% target_region_id = arrayfun(@ (id)(find(network_index_atlas == id)), target_network_id, 'UniformOutput',false);
% target_region_id_all = [];
% for i = 1:num_target_network
%     target_region_id_all = cat(1,target_region_id_all, target_region_id{i});
% end
% target_region_id =target_region_id_all;
% clear target_region_id_all;
target_data = y_Read(target_file);
mask_target = arrayfun(@ (id)(target_data == id),target_region_id, 'UniformOutput',false);
mask_target_all = 0;
for i = 1:length(mask_target)
    mask_target_all = mask_target_all + mask_target{i};
end
mask_target = mask_target_all;
clear mask_target_all;
mask_target = logical(reshape(mask_target, 1, dim1*dim2*dim3));

% Core codes
coef_all = 0;
for i = 1:n_sub
    fprintf('Running %d/%d\n', i, n_sub);
    disp('----------------------------------');
    % Step 1 is to extract the time series of all voxels in the brain region that need to be segmented.
    data_target = y_Read(datafile_path{i});
    data_target = reshape(data_target, dim1*dim2*dim3, [])';
    signals_of_target_in_the_region = data_target(:,mask_target);
    
    % Step 2 is to extract the the average time series of the other regions (some regions are combined with one functional region).
%     network_index_excluded_target_id = setdiff(network_index_atlas, target_region_id);
    network_index_excluded_target_id = unique(network_index_atlas);
    other_regions_id = arrayfun(@(id)(find(network_index_atlas == id)), network_index_excluded_target_id, 'UniformOutput',false);
    
    num_other_network = length(network_index_excluded_target_id);
    atalas_combined_all_all=0;
    for j = 1:num_other_network
        atalas_combined = arrayfun(@(id)(atalas == id), other_regions_id{j}, 'UniformOutput',false);
        
        num_id = length(atalas_combined);
        atalas_combined_all = 0;
        for k = 1: num_id
            atalas_combined_all = atalas_combined_all + atalas_combined{k};
        end
        atalas_combined_all_all = atalas_combined_all_all + atalas_combined_all .* network_index_excluded_target_id(j);
    end
    
    average_signals_other_regions = y_ExtractROISignal_copy(datafile_path{i}, {atalas_combined_all_all},[], atalas, 1);
    
    % Step 3 is to calculate the partial correlations between time series of all voxels in the target brain region and average time series of the other regions.
    coef = zeros(num_other_network, size(signals_of_target_in_the_region,2));
    for j = 1 : num_other_network
        cov = average_signals_other_regions;
        cov(:,j) = [];
        coef(j,:) = partialcorr(signals_of_target_in_the_region, average_signals_other_regions(:,j), cov, 'Type','Pearson');
    end
    
    % Step 4_1: update the partial correlations across all participants (sum).
    coef_all = coef_all + coef;
end

% Step 4 is to average the partial correlations across all participants (sum then be devided by nsub).
coef = coef_all ./ n_sub;
coef(isnan(coef)) = 0;
coef(isinf(coef)) = 1;
 
% Step 5 is to segment the target region into several sub-regions.
if strcmp(criterion, 'all_coef')
    coef_max = max(abs(coef));
    segmentation = zeros(1,size(signals_of_target_in_the_region,2));
    for j = 1: size(signals_of_target_in_the_region,2)
        segmentation(j) = find(abs(coef(:,j)) == coef_max(j));
    end
    
elseif strcmp(criterion, 'pos_coef')
    pos_coef = coef;
    pos_coef(pos_coef < 0) = 0;
    coef_max = max(abs(pos_coef));
    segmentation = zeros(1,size(signals_of_target_in_the_region,2));
    for j = 1: size(signals_of_target_in_the_region,2)
        seg = find(abs(pos_coef(:,j)) == coef_max(j));
        seg = seg(1);
        segmentation(j) = seg;
    end

elseif strcmp(criterion, 'neg_coef')
    neg_coef = coef;
    neg_coef(neg_coef > 0) = 0;
    coef_max = max(abs(neg_coef));
    segmentation = zeros(1,size(signals_of_target_in_the_region,2));
    for j = 1: size(signals_of_target_in_the_region,2)
        seg = find(abs(neg_coef(:,j)) == coef_max(j));
        seg = seg(1);
        segmentation(j) = seg;
    end
end

% clear atalas  atalas_combined atalas_combined_all average_signals_other_regions coef coef_all

% Step 6 is to save the sub-regions.
seg = zeros(1,dim1 * dim2 * dim3);
seg(mask_target) = segmentation;
segmentation = reshape(seg, dim1, dim2, dim3);
header = header_atalas;
header.descrip = 'region segmentation';
y_Write(segmentation, header, out_name);
disp('Done!');
end

function [atalas_file,target_file, target_region_id,...
         exclude_mask_file, network_index_atlas, data_dir,...
         criterion, out_name] = parse_inputs(varargin)

if mod(nargin,2)~=0
    error('输入参数个数不对，应为成对出现');
end

atalas_file = '';
exclude_mask_file = '';
target_file = '';
target_region_id = [];
network_index_atlas = '';
data_dir = '';
criterion = 'all_coef';  % 'pos_coef', 'neg_coef'
out_name = pwd;

arg_name = {'atalas_file', 'exclude_mask_file','target_file',...
          'network_index_atlas', 'data_dir', 'target_region_id',...
          'criterion', 'out_name'};
      
n_var = length(varargin);
for i = 1:2:n_var
    [isin, loc] = ismember(varargin{i}, arg_name);  
    if ~ isin
        error('%s is not a valid input!\n', varargin{i});
    end
    break
    cmd = [varargin{i}, '=', '''', varargin{i+1}, ''''];
    eval(cmd);
end

end

function [ROISignals] = y_ExtractROISignal_copy(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel, IsNeedDetrend, Band, TR, TemporalMask, ScrubbingMethod, ScrubbingTiming, Header, CUTNUMBER)             
% NOTE. This function is modified from DPABI.
% Written by YAN Chao-Gan 120216 based on fc.m.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('IsMultipleLabel','var')
    IsMultipleLabel = 0;
end

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;
% fprintf('\n\t Extracting ROI signals...');

if ~isnumeric(AllVolume)
    [AllVolume,VoxelSize,theImgFileList, Header] =y_ReadAll(AllVolume);
end

AllVolume(find(isnan(AllVolume))) = 0; %YAN Chao-Gan, 171022. Set the NaN voxels to 0.

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));


if ischar(MaskData)
    if ~isempty(MaskData)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskData);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
end

% Convert into 2D
AllVolume=reshape(AllVolume,[],nDimTimePoints)';
% AllVolume=permute(AllVolume,[4,1,2,3]); % Change the Time Course to the first dimention
% AllVolume=reshape(AllVolume,nDimTimePoints,[]);

MaskDataOneDim=reshape(MaskData,1,[]);
MaskIndex = find(MaskDataOneDim);
AllVolume=AllVolume(:,MaskIndex);

% Scrubbing
if exist('TemporalMask','var') && ~isempty(TemporalMask) && ~strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end


% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    %AllVolume=detrend(AllVolume);
    fprintf('\n\t Detrending...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
        fprintf('.');
    end
end

% Filtering
if exist('Band','var') && ~isempty(Band)
    fprintf('\n\t Filtering...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = y_IdealFilter(AllVolume(:,Segment), TR, Band);
        fprintf('.');
    end
end



% Scrubbing after filtering
if exist('TemporalMask','var') && ~isempty(TemporalMask) && strcmpi(ScrubbingTiming,'AfterFiltering')
    if ~all(TemporalMask)
        AllVolume = AllVolume(find(TemporalMask),:); %'cut'
        if ~strcmpi(ScrubbingMethod,'cut')
            xi=1:length(TemporalMask);
            x=xi(find(TemporalMask));
            AllVolume = interp1(x,AllVolume,xi,ScrubbingMethod);
        end
        nDimTimePoints = size(AllVolume,1);
    end
end


% Extract the Seed Time Courses

SeedSeries = [];
MaskROIName=[];

for iROI=1:length(ROIDef)
    IsDefinedROITimeCourse =0;
    if strcmpi(int2str(size(ROIDef{iROI})),int2str([nDim1, nDim2, nDim3]))  %ROI Data
        MaskROI = ROIDef{iROI};
        MaskROIName{iROI} = sprintf('Mask Matrix definition %d',iROI);
    elseif size(ROIDef{iROI},1) == nDimTimePoints %Seed series% strcmpi(int2str(size(ROIDef{iROI})),int2str([nDimTimePoints, 1])) %Seed series
        SeedSeries{1,iROI} = ROIDef{iROI};
        IsDefinedROITimeCourse =1;
        MaskROIName{iROI} = sprintf('Seed Series definition %d',iROI);
    elseif strcmpi(int2str(size(ROIDef{iROI})),int2str([1, 4]))  %Sphere ROI definition: CenterX, CenterY, CenterZ, Radius
        MaskROI = y_Sphere(ROIDef{iROI}(1:3), ROIDef{iROI}(4), Header);
        MaskROIName{iROI} = sprintf('Sphere definition (CenterX, CenterY, CenterZ, Radius): %g %g %g %g.',ROIDef{iROI});
    elseif exist(ROIDef{iROI},'file')==2    % Make sure the Definition file exist
        [pathstr, name, ext] = fileparts(ROIDef{iROI});
        if strcmpi(ext, '.txt'),
            TextSeries = load(ROIDef{iROI});
            if IsMultipleLabel == 1
                for iElement=1:size(TextSeries,2)
                    MaskROILabel{1,iROI}{iElement,1} = ['Column ',num2str(iElement)];
                end
                SeedSeries{1,iROI} = TextSeries;
            else
                SeedSeries{1,iROI} = mean(TextSeries,2);
            end
            IsDefinedROITimeCourse =1;
            MaskROIName{iROI} = ROIDef{iROI};
        elseif strcmpi(ext, '.img') || strcmpi(ext, '.nii') || strcmpi(ext, '.gz')
            %The ROI definition is a mask file
            
            MaskROI=y_ReadRPI(ROIDef{iROI});
            if ~strcmpi(int2str(size(MaskROI)),int2str([nDim1, nDim2, nDim3]))
                error(sprintf('\n\tMask does not match.\n\tMask size is %dx%dx%d, not same with required size %dx%dx%d',size(MaskROI), [nDim1, nDim2, nDim3]));
            end

            MaskROIName{iROI} = ROIDef{iROI};
        else
            error(sprintf('Wrong ROI file type, please check: \n%s', ROIDef{iROI}));
        end
        
    else
        error(sprintf('File doesn''t exist or wrong ROI definition, please check: %s.\n', ROIDef{iROI}));
    end

    if ~IsDefinedROITimeCourse
        % Speed up! YAN Chao-Gan 101010.
        MaskROI=reshape(MaskROI,1,[]);
        MaskROI=MaskROI(MaskIndex); %Apply the brain mask
        
        if IsMultipleLabel == 1
            Element = unique(MaskROI);
            Element(find(isnan(Element))) = []; % ignore background if encoded as nan. Suggested by Dr. Martin Dyrba
            Element(find(Element==0)) = []; % This is the background 0
            SeedSeries_MultipleLabel = zeros(nDimTimePoints,length(Element));
            for iElement=1:length(Element)
                
                SeedSeries_MultipleLabel(:,iElement) = mean(AllVolume(:,find(MaskROI==Element(iElement))),2);
                
                MaskROILabel{1,iROI}{iElement,1} = num2str(Element(iElement));

            end
            SeedSeries{1,iROI} = SeedSeries_MultipleLabel;
        else
            SeedSeries{1,iROI} = mean(AllVolume(:,find(MaskROI)),2);
        end
    end
end


%Merge the seed series cell into seed series matrix
ROISignals = double(cell2mat(SeedSeries)); %Suggested by H. Baetschmann.    %ROISignals = cell2mat(SeedSeries);

theElapsedTime = cputime - theElapsedTime;
% fprintf('\n\t Extracting ROI signals finished, elapsed time: %g seconds.\n', theElapsedTime);
end