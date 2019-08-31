function tc = getTruncatedTcs(tcs, nT)


numOfSub = size(tcs, 1);
numOfSess = size(tcs, 2);
numComp = size(tcs{1,1}, 2);
tc = zeros(numOfSub, numOfSess, nT, numComp);

%% Loop over subjects
for nSub = 1:numOfSub
    %% Loop over sessions
    for nSess = 1:numOfSess
        tmp = tcs{nSub, nSess};
        tmp = squeeze(tmp);
        tp = size(tmp, 1);
        if (tp ~= nT)
            interpFactor = nT/tp;
            [num, denom] = rat(interpFactor);
            tmp = resample(tmp, num, denom);
        end
        tc(nSub, nSess, :, :) = tmp;
    end
end