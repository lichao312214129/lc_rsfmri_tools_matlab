function fc_mat_prepared = lc_prepare_data(fc_mat,mask)
% prepare data

% extract connectvity in ID_Mask. The result is 1D vector for each subject
fc_mat_prepared = fc_mat(:,mask);

% change Inf/NaN to 1/0
fc_mat_prepared(isinf(fc_mat_prepared)) = 1;
fc_mat_prepared(isnan(fc_mat_prepared)) = 0;
end