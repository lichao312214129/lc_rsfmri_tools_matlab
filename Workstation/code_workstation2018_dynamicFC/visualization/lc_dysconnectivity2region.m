function lc_dysconnectivity2region(data,perc_to_display, template, outname_nii, outname_pdf)
%  To highlight those regions with significantly different connectivity.

% DEBUG
if nargin < 1
    data = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_4vs1_FDR0.05.mat';
    perc_to_display = 1;
    template = 'G:\BranAtalas\Template_Yeo2011\Yeo2011_17Networks_N1000.split_components.FSL_MNI152_1mm.nii.gz';
    node_name_file = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\toy_data\17network_label.xlsx';
    outname_nii = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_bd_contribution_region.nii';
    outname_pdf = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state1\state1_bd_contribution_region1.pdf';
end

% Load
Tvalues = importdata (data);
if isstruct(Tvalues)
    H = Tvalues.H_posthoc;
    Tvalues = Tvalues.Tvalues;
    Tvalues(H ~=1 ) = 0;
end
[node_value, node_str] = xlsread(node_name_file);

%
[i, j] = find(Tvalues);
node = cat(1, i, j);
weight = Tvalues(Tvalues ~= 0);
weight = cat(1, weight, weight);

uni_node = unique(node);
n_uni_node = length(uni_node);
node_weight_abssum = zeros(n_uni_node,1);
for inode = 1:n_uni_node
    node_weight = weight(node == uni_node(inode));
    node_weight_abssum(inode) = norm(node_weight,1);
end
[sorted_node_weight_abssum, sorted_idx] = sort(node_weight_abssum, 'descend');
sorted_idx = uni_node(sorted_idx);  % Very important!!!
% Softmax scale
sorted_node_weight_abssum = power(sorted_node_weight_abssum,exp(1))/sum(power(sorted_node_weight_abssum,exp(1)));


% Node name with high contribution
node_name = node_str(sorted_idx(1:round(n_uni_node*perc_to_display)),3);
sorted_idx_cell = num2cell(sorted_idx(1:round(n_uni_node*perc_to_display)));
node_name = cellfun(@(s,i) [s, ' (',num2str(i), ')'], node_name,sorted_idx_cell,'UniformOutput',false); 
barh(sort(sorted_node_weight_abssum(1:round(n_uni_node*perc_to_display)), 'ascend'), ...
    'FaceColor',[0.5 0.5 0.5],...
     'EdgeColor','w',...
     'LineWidth',1);
 
set(gca,'linewidth',1);
node_name = flipud(node_name);
yticklabels(node_name);
set(gca,'YTick',1:round(n_uni_node*perc_to_display));
box off
% saveas(gca, outname_pdf);


% Load template
[template_nii, header] = y_Read(template);
for i = 1:round(n_uni_node*perc_to_display)
    template_nii(template_nii == sorted_idx(i)) = sorted_node_weight_abssum(i);
end
template_nii(template_nii>=1) = 0;

% Save to nii
y_Write(template_nii, header, outname_nii);
end

