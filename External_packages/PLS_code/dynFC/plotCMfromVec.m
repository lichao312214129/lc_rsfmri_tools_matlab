function plotCMfromVec(FC,varargin)
% displays a symmetric correlation matrix from a vectorized upper triangular part
% 
% IN
%     FC: vectorized correlation matrix
% optional
%     lab: axis on/off (default: faulse=off)
%     ConnS: a mask if not all entries of the NxN correlation matrix are included in the vector
% 
% v1.0 March 2013 Nora Leonardi, Dimitri Van De Ville


[lab,ConnS]=process_options(varargin,...
    'lab',0,'ConnS',[]);

N = ceil(sqrt(2*length(FC)));
tmpp = zeros(N);
if isempty(ConnS)
    tmpp(logical(triu(ones(N),1)))=FC; 
else
    tmpp(ConnS)=FC;
end    
    
tmpp = tmpp+tmpp';

imagesc(tmpp);
cax=caxis; caxis([-1 1]*max(abs(cax)));
if ~lab, axis off; end
axis square

end