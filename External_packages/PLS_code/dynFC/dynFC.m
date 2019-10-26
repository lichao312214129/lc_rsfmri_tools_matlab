function [A,TMask,TT,best_lambda,ConnS] = dynFC(TCS,conn,windowSize,step,varargin)
% calculates dynamic functional connectivity from time courses
%
% IN:
%   TCS: cell array with the time courses of all subjects (each cell
%       contains a space x time array)
%   conn: type of dependency between time courses
%       ('Corr','MI','WTC'), WTC is slow
%    windowSize: length of window for dependency calculation
%    step: number of TRs by which to shift window
% optional
%     Abs: use absolute value of dependency (default: false)
%     RtoZ: RtoZ transform (default: true)
%     cut: remove flagged scans (requires a cell of vectors as input of same size as TCS, default: empty)
%     scramble: phase randomize time courses (default: false)
%     l1norma: normalize the connectivity matrix at each window (default: false)
%     l2norma: normalize by l2 norm (default:false)
%     static: calculate a single connectivity matrix (default: false)
%     TR: required for conn WTC (default: empty)
%     best_lambda: if best_lambdas for each subject are already known
%       (vector with entry for each subject, default: empty)
%     seeds: vector of ROIs for which to estimate dynamic FC (all
%       duplicates are removed, use "ConnS" for indices of all connections:
%       e.g. CM=zeros(N); CM(ConnS)=A{1}(:,1); CM=CM+CM'; )
% OUT:
%   A: cell with dynamic connectivity for each subject, each column contains an unfolded connectivity matrix for the metric chosen (connectivity pairs
%       x windows)
%   TMask: cell with included scans
%   TT: cell with window locations
%   D: cell with degree
%   best_lambda: for regularization
%   ConnS: index of seed correlations
% 
% v1.0 March 2013 Nora Leonardi, Dimitri Van De Ville
% v1.01 June 2013 NL: added seed option

[Abs,RtoZ,cut,scramble,l1norma,static,TR,best_lambda,l2norma,seeds,allROIs,...
    Anorma]=process_options(varargin,'Abs',...
    false,'RtoZ',1,'cut',[],'scramble',false,'l1norma',false,'static',...
    false,'TR',[],'best_lambda',[],'l2norma',false,'seeds',[],'allROIs',0,'Anorma',0);

conn = lower(conn);

if (length(TCS) ~= length(cut)) && ~isempty(cut)
    error('TCS and cut need to be of the same size');
end
if ~iscell(TCS) && length(size(TCS))==2 % single subject
    TCS={TCS};
end

N=size(TCS{1},1);
TP=size(TCS{1},2);
nSubjs=length(TCS);

%% seeds
if ~isempty(seeds) % not full whole-brain
  %  nconn = N*Nrois - Nrois/2*(Nrois+1); % remove duplicates
    ConnS = zeros(N); 
    ConnS(:,seeds)=1;
    ConnS = ConnS - diag(diag(ConnS)); % don't use autocorr
    if allROIs % use conn to all other ROIs
        [i,j]=find(ConnS+ConnS'); 
        ind = find(ConnS+ConnS'); 
        ConnS(ind(i>j)) = 0; % keep only those above diag
        ConnS = logical(ConnS);
    else % use conn only btw seeds
        ConnS = logical(ConnS+ConnS'==2);
        [i,j]=find(ConnS);
        ind = find(ConnS); 
        ConnS(ind(i>j)) = 0; % keep only those above diag
        % OR ConnS(seeds,seeds)=1 & triu
    end
else
    ConnS=logical(triu(ones(N),1));
end
nconn = sum(ConnS(:));
N2 = sum(sum(ConnS+ConnS')>=1); % how many nodes

%% initialize
A=cell(1,nSubjs);
T=1:step:TP-windowSize;
TMask=cell(1,nSubjs); % all included scans
TT=TMask; % indices of windows

%%
if static
   A = cellfun(@(X) jUpperTriMatToVec(jFisherRtoZtransform( corr(X') )), TCS, 'uniformoutput',0);  
   return
end

disp('Calculating dynamic connectivity...');
for s=1:nSubjs
    if ~isempty(cut), if mod(s,5)==0, fprintf('\n'); end, fprintf('s%d ',s); 
    else fprintf('Subject %d ',s); end
    cc=1;   

    Y=TCS{s}; % space x time
    Y=zscore(Y')'; 
    
    %% scrubbing
    if ~isempty(cut) % remove scans with too much motion
        indd=cut{s};
        indd=[indd;indd-1;indd+1;indd+2]; indd=sort(unique(indd)); 
        indd(indd<1)=[]; indd(indd>TP)=[];
        if ~isempty(indd), fprintf('Removing %d scans ',length(indd)); end
        TM=logical(1:TP);
        TM(indd)=0;    
        Y=Y(:,TM); 
        T=1:step:size(Y,2)-windowSize;
        TMask{s}=TM; TT{s}=T;
    else
        TMask{s}=logical(1:TP);
        TT{s}=1:step:size(Y,2)-windowSize;
    end
    
    %% static
    if static
        windowSize=sum(TMask{s})-1; T=1; TT{s}=T;
    end
    
    %% phase randomize
    if scramble % phase randomize data
        f=Y';
        %f = f.*repmat(hamming(size(f,1)), 1, size(f, 2)); % taper ends
        f=fft(f);
        r = rand(size(f));
        ranp=angle(fft(r));
        Y=real(ifft(abs(f).*exp(sqrt(-1)*(ranp))))'; 
    end
        
    %% dynFC calculation: corr, rcorr, MI
    if ~strcmp(conn,'wtc')  
        dyncon=zeros(nconn,length(T));    
        for t = T
            y=Y(:,t:t+windowSize)'; % time x ROIs
            y=double(y); 
            
            % tapered window
            %try, y = y.* repmat(tukeywin(size(y,1),0.25),1,size(y,2)); 
            %catch, y = [y;zeros(1,size(y,2))].* repmat(tukeywin(size(y,1)+1,0.05),1,size(y,2)); y=y(1:end-1,:); end

                switch conn
                    case 'ip' % inner product
                        CM = y' * y /(windowSize-1);
                        
                    case 'corr'
                        [CM,P]=corr(y); % or zscore(y)'*zscore(y)/(windowSize-1)
                                        
                    case 'mi' % mutual info
                        if ~exist('mutualinfo','file'), error('Please download the "Mutual Information computation" toolbox from Matlab File Exchange'); end
                        CM=zeros(N);
                        for i=1:N-1
                            for j=i+1:N
                                CM(i,j)=mutualinfo(y(:,i),y(:,j));
                                CM(j,i)=CM(i,j);
                            end
                        end

                    otherwise
                        error('Unknown connectivity type. Choose between corr, rcorr, MI, WTC');
                end
                
                if (strcmp(conn,'corr') || strcmp(conn,'rcorr')) && RtoZ
                    CM=jFisherRtoZtransform(CM); 
                end

                CM(abs(CM)<.01)=0; % set small values to zero
                CM(isnan(CM))=0; % remove any NaNs
                if Abs, CM=abs(CM); end
                
                CM=triu(CM,1)+triu(CM,1)'; % make sure symmetric and rmv diag
                if l1norma, CM=CM/sum(abs(jUpperTriMatToVec(CM,1))); end % normalize corr
                if l2norma, CM=CM./norm(jUpperTriMatToVec(CM,1)); end
                if Anorma, CM=diag(1./sqrt(sum(abs(CM))))*CM*diag(1./sqrt(sum(abs(CM)))); end % "norma adj": makes sense after RtoZ?
                if isempty(seeds)
                    dyncon(:,cc)=jUpperTriMatToVec(CM);
                else
                    dyncon(:,cc)=CM(ConnS);
                end                
                
                cc=cc+1;        
        end 
    
    %% wavelet transform coherence, based on Grinsted's toolbox
    % http://noc.ac.uk/using-science/crosswavelet-wavelet-coherence
    else 
        dyncon=zeros(nconn,TP);
        if isempty(TR), error('TR required for wavelet transform coherence'); end

        y=Y'; 
        [IJ]=find(ConnS);  Dj=1/8;
         for a=1:length(IJ)
            [i,j] = ind2sub([N,N],IJ(a));
            % wavelet transform
            [X,period,scale,coix] = wavelet_n(y(:,i),TR,1,Dj,2*TR,-1,'Morlet');
            Y = wavelet_n(y(:,j),TR,1,Dj,2*TR,-1,'Morlet');
            
            freq=1./period;
            indx=freq<1/(2*TR) & freq>0.01; % upper bound lower if band-pass filtered data
            W=zeros(size(X)); W(indx,:)=1;
            %W(repmat(period',1,size(W,2))>repmat(coi,size(W,1),1))=0; % remove points affected by edge effects
            
            % wavelet coherence
            sX=smoothwavelet_n(abs(X).^2,TR,period,Dj,scale);
            sY=smoothwavelet_n(abs(Y).^2,TR,period,Dj,scale);
            Wxy=X.*conj(Y);
            sWxy =smoothwavelet_n(Wxy,TR,period,Dj,scale);
            Rsq=abs(sWxy).^2./(sX.*sY); % how coherent CWT is in time-freq space, "localized corr coeff"
            dyncon(a,:) = sum(W.*Rsq)./sum(W); % weighted sum
         end
        dyncon(isnan(dyncon))=0; % where outside COI
    end
    
    %% save
    A{s}=dyncon;
end
fprintf('\n Done\n');
end

function zprime=jFisherRtoZtransform(r)
% convert Pearson correlations (whose sampling distrubtion is not normal)
% to normally distributed variable zprime by applying Fisher's 
% z' transformation.
%
% IN: r: a matrix of Pearson r values
% OUT: z: a matrix of fisher z values, approximately normally distributed
%       and with a standard error of 1/sqrt(N-3)
%
% v1.0 Oct 2009 Jonas Richiardi

if (any(r>1 | r<-1))
    error('Please input a correlation matrix');
end

% limit range to avoid infs in mapping
r(r>0.999999)=0.999999;
r(r<-0.999999)=-0.999999;
% do transform
zprime=atanh(r);

end

function v=jUpperTriMatToVec(m,varargin)
% converts the upper-triangular part of a matrix to a vector
%
% IN:
%   m: matrix
%   offset: offset above leading diagonal, fed to triu function
% OUT:
%   v: vector of upper-triangular values
% 
% v1.0 Oct 2009 Jonas Richiardi
% - initial release

switch nargin
    case 1
        offset=1;
    case 2
        offset=varargin{1};
end

% get indices of upper triangular part
[ind] = find(triu(ones(size(m)), offset));
v = m(ind);
end