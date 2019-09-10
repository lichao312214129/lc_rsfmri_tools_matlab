function meta_summary = getSummaryMetaStates(Tcs)
% Get summary from meta states
%
% Number of unique rows (NUM_STATES)
% Change in states (CHANGE_STATES)
% MAX L1 distance between rows (STATE_SPAN)
% SUM of L1 distances between successive states (TOTAL_DIST)

num_states = zeros(size(Tcs, 3), 1);
change_states = zeros(size(Tcs, 3), 1);
state_span = zeros(size(Tcs, 3), 1);
total_dist = zeros(size(Tcs, 3), 1);
for nS = 1:size(Tcs, 3)
    tmp = squeeze(Tcs(:, :, nS));
    d1 = icatb_pdist(tmp, 'all', 1);
    d2 = icatb_pdist(tmp, 'successive', 1);
    idx = unique(tmp, 'rows');
    num_states(nS) = size(idx, 1);
    change_states(nS) = sum(d2 ~= 0); %length(find(max(abs(tmp_diff')) ~= 0));
    state_span(nS) = max(d1);
    total_dist(nS) = sum(d2);
end

freq_levels_info = compute_freq_levels(Tcs);

meta_summary.num_states = num_states;
meta_summary.change_states = change_states;
meta_summary.state_span = state_span;
meta_summary.total_dist = total_dist;
meta_summary.freq_levels_info = freq_levels_info;

