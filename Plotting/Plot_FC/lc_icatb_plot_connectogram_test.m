comp_network_names = {'BG', 1:10;                    % Basal ganglia 21st component
    'AUD', 11:20;                   % Auditory 17th component
    'SM', 21:30;    % Sensorimotor comps
    'VIS', 31:60;  % Visual comps
    'DMN', 61:90;        % DMN comps
    'ATTN', 100:200; % ATTN Comps
    'FRONT', 201:246};     % Frontal comps
%
C = icatb_corr(rand(1000, 246)); C = C - eye(size(C)); C(abs(C) < 0.01) = 0;
C(abs(C) < 0.1) = 0;
comp_labels = num2cell(1:246);
comp_labels = cellfun(@num2str, comp_labels, 'UniformOutput', false);
fname = 'D:\WorkStation_2018\WorkStation_CNN_Schizo\Data\Atalas\sorted_brainnetome_atalas_3mm.nii';
% tmp4dnii = lc_3Datlas_to_4Datlas(fname);
lc_icatb_plot_connectogram(comp_network_names, 'C', C, 'threshold', 0.6, 'image_file_names', tmp4dnii, 'colorbar_label', 'Corr', 'comp_labels', comp_labels, 'line_width', 0.2, 'display_type', 'render');