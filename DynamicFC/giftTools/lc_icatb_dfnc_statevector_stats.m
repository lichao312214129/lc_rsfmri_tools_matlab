function [F, TM, MDT, NT] = lc_icatb_dfnc_statevector_stats(idx, k)
% Copy from gift.
% input£º
%   idx:state index, e.g., [1 1 1 3 3 5 3 2 4]
%   k: number of states
% 
%%
Nwin = length(idx);

%% Fraction of time spent in each state
F = zeros(1,k);
for jj = 1:k
    F(jj) = (sum(idx == jj))/Nwin;
end

%% Number of Transitions
NT = sum(abs(diff(idx)) > 0);

%% Mean dwell time in each state
MDT = zeros(1,k);
for jj = 1:k
    start_t = find(diff(idx==jj) == 1);
    end_t = find(diff(idx==jj) == -1);
    if idx(1)==jj
        start_t = [0; start_t];
    end
    if idx(end) == jj
        end_t = [end_t; Nwin];
    end
    MDT(jj) = mean(end_t-start_t);
    if isempty(end_t) & isempty(start_t)
        MDT(jj) = 0;
    end
end

%% Full Transition Matrix
TM = zeros(k,k);
for t = 2:Nwin
    TM(idx(t-1),idx(t)) =  TM(idx(t-1),idx(t)) + 1;
end

for jj = 1:k
    if sum(TM(jj,:)>0)
        TM(jj,:) = TM(jj,:)/sum(idx(1:Nwin-1) == jj);
    else
        TM(jj,jj) = 1;
    end
end

