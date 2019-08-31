function [trainTC, testTC] = split_timewindows(TCwin, ntrain)
%[Nwin, nT, nC] = size(TCwin);


[Nwin, nT, nC] = size(TCwin);

r = randperm(Nwin);
trainTC = TCwin(r(1:ntrain),:,:);
testTC = TCwin(r(ntrain+1:end),:,:);

trainTC = reshape(trainTC, ntrain*nT, nC);
testTC = reshape(testTC, (Nwin-ntrain)*nT, nC);