function [PCAmat,mm,sts,AS]=concatA(A,varargin)
% concatenate dynamic FC matrices of multiple subjects
%
% IN:
%   A: cell array with dynamic connectivity for all subjects
% optional
%   Locs: cell with indices of peaks (defaults to all columns)
%   scrambleA: whether to scramble the dynamic connectivity time course
%     (default: false)
%   demean: remove each ROIs mean connectivity (make XX^T a cov)
%   norma: divide by std over time (make XX^T a corr)
%   subjPCA: reduce temp dimension doing a PCA to this dimension
%   pre: which preprocessing (w=whitening, r=pca rotation), if subjPCA==0
%       then this option is not used
% OUT:
%   PCAmat: matrix with time-subject-concatenated functional connectivity
%       (conn x time/subjects)
%   mm: connectivity-wise mean of each subject (conn x subject)
%   sts: connectivity-wise variability (mad)
%   AS: scrambled connectivity time courses (cell)
% 
% v1.0 March 2013 Nora Leonardi, Dimitri Van De Ville
% v1.1 July 2013 NL: added deman, AS/sts output, subjPCA preproc options

[Locs,scrambleA,demean,subjPCA,pre,norma]=process_options(varargin,...
    'Locs',[],'scrambleA',false,'demean',0,'subjPCA',0,'pre','w','norma',0);

if isempty(Locs)
    Locs=cell(1,length(A)); 
    for s=1:length(A)
        Locs{s}=1:size(A{s},2);
    end
end

LocsInd=cumsum(cellfun(@length,Locs));
if strcmp(pre,'z'), 
    subjPCA = length(Locs{1}); 
    if mod(LocsInd(end)/length(Locs),1)~=0, error('code does not work for cells with unequal lengths'); end
    % need to make subjPCA different for each subj
end % original dimension

LocsInd=[0,LocsInd];
if subjPCA==0
    PCAmat=zeros(size(A{1},1),LocsInd(end));
else
    PCAmat=zeros(size(A{1},1),subjPCA*length(A));
end
mm=zeros(size(A{1},1),length(A)); sts=mm;
AS=cell(1,length(A));

for s=1:length(A)
    tmp=A{s}(:,Locs{s});
    mm(:,s)=mean(tmp,2);
    sts(:,s)=std(tmp,[],2); % or use "mad(tmp',1)'" for more robustness to outliers
    
    if demean
        tmp = bsxfun(@minus, tmp, mm(:,s)); % demean each connectivity pair's time course
        if norma
            tmp = bsxfun(@rdivide, tmp, std(tmp,[],2)); 
        end
    end
    
    if scrambleA
        f=fft(A{s}');
        ranp=angle(fft(rand(size(f)))); 
        tmp=real(ifft(abs(f).*exp(sqrt(-1)*(angle(f)+ranp))))';       
        AS{s}=tmp;
        tmp=tmp(:,Locs{s});
        if demean, tmp=tmp-repmat(mean(tmp,2),1,length(Locs{s}) ); end
    end
    
    if subjPCA==0 
        PCAmat(:,LocsInd(s)+1:LocsInd(s+1))=tmp;
    else % do subject-wise PCA
        if s==1, fprintf('doing PCA...\n'); end
        [u,S,~] = svds(tmp,subjPCA,'L'); % conn x time
        switch pre
            case 'w' % whitening (rotate and unit-variance)
                tmp = u; 
            case 'r' % simple rotation
                tmp = u*S; % include variance
        end
        PCAmat(:,subjPCA*(s-1)+1:subjPCA*s)=tmp;
    end    
    
end

PCAmat = double(PCAmat);
%fprintf('Done concatenating\n');
