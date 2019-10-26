%% Dynamic functional connectivity analysis

%% parameters
conn='Corr';
windowSize=30;
step=5; % step to move window
Abs=0;
RtoZ=1;
l1norma=0; % norma corr matrices
scrambleT=0; % scramble phases of time courses
scrambleA=0; % scramble phases of connectivity
static=0; % if true estimates a single FC estimate across the entire scan instead of using sliding windoes
TR=2;
demean=1;

%% load time series and index of scans to cut: cell array 
TCS=cell(1,1); % each subject in a cell
cut=[]; % cell with indices to cut or empty

load 'DynConnSynthData.mat' % 2 subjects, 90 ROIs, 440 scans (group test doesn't work as too few subjects)
n1 = 2; % indicate number of subjects in group 1 for group test below

%% initialize variables
nSubjs=length(TCS);
TP=size(TCS{1},2);
N=size(TCS{1},1);

%% estimate dynamic functional connectivity
[A,TMask,TT,~,ConnS]=dynFC(TCS,conn,windowSize,step,'seeds',1:N,'Abs',Abs,'RtoZ',RtoZ,'cut',cut,'l1norma',l1norma,'scramble',scrambleT);
tpp=max(cellfun(@length,TT));

%% plot time courses and dynamic connectivity
plot_TCS_dynconn(TCS,A,TMask) 

%% visualize some networks
ind=find(triu(ones(N),1));
s=1;
ww=1:5:40; % the first ones or any combination as a vector
dim = ceil(sqrt(length(ww)));
figure
for i=1:length(ww)
    row = mod(i-1, dim);
    col = floor((i-1) / dim);    
    subplot('position', [.02+row*(1/dim), .02+(dim-col-1)*(1/dim), .9/dim, .9/dim]); 
    plotCMfromVec(A{s}(:,ww(i)),'lab',0,'ConnS',ConnS);
    axis off
end

%% select a subset or all windows
[Locs,GCP]=GCP_peaks(A,'all'); 
% the option 'all' returns an index including all windows, 
% 'findpeaks' returns only windows with locally maximal standard deviation (i.e. a variable connectivity topography), 
% 'threshold' applies an (arbitrary) threshold to the standard deviation of each dynFC estimate

%% concatenate across subjects
if static % demean
    PCAmat=cell2mat(A);
    mmm=mean(PCAmat,2);
    PCAmat=PCAmat-repmat(mmm,1,size(PCAmat,2));
else
    [PCAmat,mm]=concatA(A,'Locs',Locs,'scrambleA',scrambleA,'demean',demean);
end

%% decompose concatenated matrix
fprintf('Decomposing matrix of size %d x %d...',size(PCAmat));
[u,S,v]=svd(PCAmat,'econ'); % or svds(PCAmat,K,'L'): calculate only K components
% u = eigenconnectivities
% v = time-dependent contribution

SS=diag(S);
fprintf('Done\n');

%% retained variance for e.g. K components (needs all components estimated by svd)
K=10; % components to retain
fprintf('%d components explain %d percent of total variance\n', K,round(100*sum(SS(1:K).^2)/sum(SS.^2)));
ScreePlot(SS,K)

%% visualize eigennetworks
ind=find(triu(ones(N),1));
ww=1:10; % the first ones or any combination as a vector
dim = ceil(sqrt(length(ww)));
figure
for i=1:length(ww)
    row = mod(i-1, dim);
    col = floor((i-1) / dim);    
    subplot('position', [.02+row*(1/dim), .02+(dim-col-1)*(1/dim), .9/dim, .9/dim]); 
    plotCMfromVec(u(:,ww(i)),'lab',0,'ConnS',ConnS);
    hold on; 
    line([1 1],[1 N],'color','k','linewidth',2); line([1 N],[1 1],'color','k','linewidth',1);
    line([1 1]*N,[1 N],'color','k','linewidth',2); line([1 N],[1 1]*N,'color','k','linewidth',1);
end

%% project full dynamic connectivity (if in v only time courses of peaks)
TC=cell(1,nSubjs);
for s=1:nSubjs
    if static
        cc=A{s}-mmm; % subtract mean network
    else
        cc=A{s}-repmat(mm(:,s),1,size(A{s},2) );
    end
    tmp= u(:,1:K)' * cc;
    
    % ensure the matrices of all subjects have equal length for further
    % analyses
    if size(tmp,2)<tpp, tmp=[tmp,nan(size(tmp,1),tpp-size(tmp,2))]; end
    TC{s} = double(tmp');
end
