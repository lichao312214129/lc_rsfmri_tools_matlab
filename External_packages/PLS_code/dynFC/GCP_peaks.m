function [Locs,st]=GCP_peaks(A,peaks,L)
% find the local maxima in the standard deviation of the dynamic connectivity matrices
% (std calculated per window over all connections). 
% GCP = global connectivity power, in analogy to GFP = global field power,
% which is used in EEG microstate analysis
%
% IN:
%   A: cell array with dynamic connectivity for all subjects
%   peaks: method to select peaks (findpeaks, all, threshold)
% optional
%     L: which windows to retain or neighborhood over which maximum is searched (default: 5)
% OUT:
%   Locs: cell with indices of peaks
% 
% v1.0 March 2013 Nora Leonardi, Dimitri Van De Ville

if nargin<2, peaks='all'; end
if nargin<3, L=5; % neighborhood over which maximum searched OR fixed step size
end

nSubjs=length(A);
Locs=cell(1,nSubjs); st=Locs;
for s=1:nSubjs
    if size(A{s},2)>1
        st{s}=std(A{s});
        switch peaks
            case 'findpeaks' % a la microstates
                try
                    stsmoothed=conv(st{s},gausswin(L)/sum(gausswin(L)));
                catch
                    stsmoothed = st;
                    disp('dynFC not smoothed as signal processing toolbox not installed');
                end
                st{s}=stsmoothed(1+floor(L/2):end-floor(L/2));
                [~,Locs{s}]=findpeaks(st{s}); % find local maxima
                
            case 'all'
                Locs{s}=1:L:size(A{s},2); % use all windows
                
            case 'threshold' % 0.5*std is arbitrary
                Locs{s}=abs([0,diff(st{s})])>0.5*std(st{s}); Locs{s}(Locs{s}==0)=[];
            otherwise
                error('Unknown type');
        end
    else % static case
        Locs{s}=1;
    end
end

