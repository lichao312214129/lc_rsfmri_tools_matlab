function levels_info = compute_freq_levels(TCs)
%% Get frequency for each level, component and subject
%

Levels = unique(TCs(:));
Levels = Levels(:)';
num_windows = size(TCs, 1);
FreqCompLevels = zeros(size(TCs, 2), length(Levels), size(TCs, 3));

for sub = 1:size(TCs, 3)
    for comp = 1:size(TCs, 2)
        for lev = 1:length(Levels)
            FreqCompLevels(comp, lev, sub) = sum(TCs(:, comp, sub) == Levels(lev))/num_windows;
        end
    end
end


levels_info.levels = Levels;
levels_info.FreqCompLevels = FreqCompLevels;