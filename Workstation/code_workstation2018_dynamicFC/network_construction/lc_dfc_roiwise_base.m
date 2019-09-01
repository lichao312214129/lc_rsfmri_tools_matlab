function [zDynamicFC,zStaticFC]=lc_dfc_roiwise_base(time_series, window_step, window_length, window_type, window_alpha)
%  Used to calculate  roi-wise dynamic fc using sliding-window method for on subject, similar to DPABI software, but not GIFT software.
% input:
%   time_series: size=T-by-N, T is number of timepoints, N is number of ROIs
% 	window_step: sliding-window step
% 	window_length: sliding-window length
% 	window_type: e.g.,Gaussian window
% 	window_alpha: convolving a rectangle with a Gaussian (σ(alpha), default is 3 TRs; Reference doi: 10.1093/cercor/bhs352)
% output
%   zDynamicFC: dynamic FC matrix with Fisher r-to-z transformed; size=N*N*W, N is the number of ROIs, W is the number of sliding-window
%   zStaticFC: static FC matrix with Fisher r-to-z transformed; size=N*N, N is the number of ROIs
%   varOfZDynamicFC: variance of dynamic FC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[volume, nRegion]=size(time_series);  % dynamic FC parameters
nWindow=ceil((volume - window_length + 1) / window_step);

% TODO: Expand to other window type
if strcmp(window_type, 'Gaussian')
	windowvector = icatb_compute_sliding_window(window_length, window_alpha, window_length);  % Similiar to DPABI software
else
	fprintf('Currently only Gaussian window is available!\m')
end
windowvector = repmat(windowvector, 1, nRegion);
% static FC
staticR=corrcoef(time_series);
zStaticFC=atanh(staticR);  % Fisher R-to-Z
% dynamic FC
window_star=1;
window_end=window_length;  % re-innitiation
count=1;
zDynamicFC=zeros(nRegion,nRegion,nWindow);
while window_end <= volume
    windowed_timecourse=time_series(window_star:window_end,:);
    % Apply rectangle window with a Gaussian to windowed_timecourse
    windowed_timecourse = windowed_timecourse .* windowvector;
    dynamicR=corrcoef(windowed_timecourse);
    zDynamicFC(:,:,count)=atanh(dynamicR);  % Fisher R-to-Z transformation
    window_star=window_star+window_step;
    window_end=window_end+window_step;
    count=count+1;
end
% varOfZDynamicFC=std(zDynamicFC,0,3);
end