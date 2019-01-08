function TCs = kMeansTCs(wFNCs, KmeansCentroids, opts1)
%wFNCs should be numWindows by numCorrelations by numSubjects
%KmeansCentroids should be numCorrelations by numClusters


% if nargin<3
%     opts1=1;
% end
% if nargin<4
%     if length(opts1)==0
%         opts1=1;
%     end
%     opts2=1;
% end

if (~exist('opts1', 'var'))
    opts1 = 'sqeuclidean';
end

eps=0.0001;
nClusts=size(KmeansCentroids,2);

%distance_opts =  {'City', 'sqEuclidean', 'Hamming', 'Correlation', 'Cosine'};

Ds = zeros(size(wFNCs, 1), nClusts, size(wFNCs,3));
for c=1:nClusts
    CtrdRep = repmat(squeeze(KmeansCentroids(:, c))', [size(wFNCs, 1), 1, size(wFNCs, 3)]);
    %ctrdrep=repmat(squeeze(KmeansCentroids(:,c)),[1,size(wFNCs,3)]);
    %     CtrdRep = zeros(size(wFNCs, 1), size(ctrdrep, 1), size(ctrdrep, 2));
    %     for w=1:size(wFNCs,1)
    %         CtrdRep(w,:,:)=ctrdrep;
    %     end
    %     clear ctrdrep
    if (strcmpi(opts1, 'city') || strcmpi(opts1, 'cityblock'))
        % L1 metric
        Ds(1:size(wFNCs,1),c,1:size(wFNCs,3))=squeeze(sum(abs(wFNCs - CtrdRep),2));
    elseif (strcmpi(opts1, 'sqeuclidean'))
        % L2 metric
        Ds(1:size(wFNCs,1),c,1:size(wFNCs,3))=squeeze((sum((wFNCs - CtrdRep).^2,2)));
    elseif (strcmpi(opts1, 'correlation'))
        % Correlation metric
        C1 = num2cell(wFNCs, 2);
        C2 = num2cell(CtrdRep, 2);
        dd = cellfun(@icatb_corr2, C1, C2, 'UniformOutput', false);
        Ds(1:size(wFNCs, 1), c, 1:size(wFNCs, 3)) = cell2mat(dd);
        %Ds(1:size(wFNCs,1),c,1:size(wFNCs,3))= icatb_corr(squeeze(wFNCs(:, );
    elseif (strcmpi(opts1, 'cosine'))
        % Cosine metric
        func_h = @(xa, ya) sum(xa(:).*ya(:))/(sqrt(sum(xa(:).*xa(:))*sum(ya(:).*ya(:))));
        C1 = num2cell(wFNCs, 2);
        C2 = num2cell(CtrdRep, 2);
        dd = cellfun(func_h, C1, C2, 'UniformOutput', false);
        Ds(1:size(wFNCs, 1), c, 1:size(wFNCs, 3)) = cell2mat(dd);
        % Ds(1:size(wFNCs, 1), c, 1:size(wFNCs, 3)) = 1- ((wFNC.C_i)/sqrt((wFNC.wFNC)(C_i.C_i))]/2;
        %Ds = 1;
    else
        % hamming
        if (~isempty(which('pdist2.m')))
            func_h = @(xa, ya) pdist2(xa(:)', ya(:)', 'hamming');
        else
            func_h = @(xa, ya) sum(xor(xa(:), ya(:)))/length(xa);
        end
        
        C1 = num2cell(wFNCs, 2);
        C2 = num2cell(CtrdRep, 2);
        dd = cellfun(func_h, C1, C2, 'UniformOutput', false);
        Ds(1:size(wFNCs, 1), c, 1:size(wFNCs, 3)) = cell2mat(dd);
        
    end
end

%if opts2==1
if (strcmpi(opts1, 'city') || strcmpi(opts1, 'cityblock') || strcmpi(opts1, 'sqeuclidean'))
    denom = squeeze(sum(Ds,2));
    TCs = zeros(size(wFNCs, 1), nClusts, size(wFNCs,3));
    for c=1:nClusts
        TCs(:,c,:)=squeeze(Ds(:,c,:))./denom;
    end
    TCs = (1 - TCs);
elseif (strcmpi(opts1, 'correlation'))
    TCs = (1 + Ds)/2;
elseif (strcmpi(opts1, 'cosine'))
    TCs = (1 - Ds)/2;
else
    % hamming
    TCs = (1 - Ds);
end
%elseif opts2==2
%   denom=Ds+eps.*ones(size(Ds));
%   TCs=1./denom;
%end