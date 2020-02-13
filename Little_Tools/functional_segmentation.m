function functional_segmentation()
% GOAL: This function is used to segment one region into several sub-regions
% according to its function connectivity with other regions.
%% --------------------------------------------------
%% Step 0 is setting inputs and loading.
% Inputs
atalas_file = 'D:\WorkStation_2018\WorkStation_CNN_Schizo\Data\Atalas\sorted_brainnetome_atalas_3mm.nii';
network_index = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\network_index.txt';
data_dir = 'D:\WorkStation_2018\WorkStation_CNN_Schizo\Data\workstation_rest_ucla\FunImg\FunImgARWSFC';
target_network_id = [3];
out_name = 'D:\workstation_b\ZhangYue_Guangdongshengzhongyiyuan\segmentation.nii';

% Load
[atalas, header_atalas] = y_Read(atalas_file);
network_index = load(network_index);
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
num_target_network = length(unique(target_network_id));
target_region_id = arrayfun(@ (id)(find(network_index == id)), target_network_id, 'UniformOutput',false);
target_region_id_all = [];
for i = 1:num_target_network
    target_region_id_all = cat(1,target_region_id_all, target_region_id{i});
end
target_region_id =target_region_id_all;
clear target_region_id_all;

mask_target = arrayfun(@ (id)(atalas == id),target_region_id, 'UniformOutput',false);
mask_target_all = 0;
for i = 1:length(mask_target)
    mask_target_all = mask_target_all + mask_target{i};
end
mask_target = mask_target_all;
clear mask_target_all;
% y_Write(mask_target, header_atalas, 'mask.nii');
mask_target = logical(reshape(mask_target, 1, dim1*dim2*dim3));

coef_all = 0;
for i = 1:n_sub
    fprintf('Running %d/%d\n', i, n_sub);
    disp('----------------------------------');
    % Step 1 is to extract the time series of all voxels in the brain region that need to be segmented.
    data_target = y_Read(datafile_path{i});
    data_target = reshape(data_target, dim1*dim2*dim3, [])';
    signals_of_target_in_the_region = data_target(:,mask_target);
    
    % Step 2 is to extract the the average time series of the other regions (some regions are combined with one functional region).
    network_index_excluded_target_id = setdiff(network_index, target_network_id);
    other_regions_id = arrayfun(@(id)(find(network_index == id)), network_index_excluded_target_id, 'UniformOutput',false);
    
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
    
    % Step 4 is to average the partial correlations across all participants (sum then be devided by nsub).
    coef_all = coef_all + coef;
end

% Step 4:continue
coef = coef_all ./ n_sub;
 
% Step 5 is to segment the target region into several sub-regions.
coef_max = max(abs(coef));
segmentation = zeros(1,size(signals_of_target_in_the_region,2));
for j = 1: size(signals_of_target_in_the_region,2)
    segmentation(j) = find(abs(coef(:,j)) == coef_max(j));
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
