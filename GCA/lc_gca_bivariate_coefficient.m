function [result_x2y,result_y2x,roi_sequence] = lc_gca_bivariate_coefficient(timecourses,order,covariables)
% Tis function is used to perform bivariate ROI-wise Granger Causal Analysis
% Inputs:
%   timecourses: rois' timecourses with dimension of number of timepoints by number of rois
% 	order: default is 1 wihich means 1 timepoints lag
%   covariables: orther covariables
% Outputs:
%   See rest manual
% Revised from REST software
if nargin < 3
    covariables = [];
end
nDim4=length(timecourses);
numROIs=size(timecourses,2);
roi_sequence=nchoosek(1:numROIs,2);
past_1=zeros(nDim4-order,order);
past_2=zeros(nDim4-order,order);
result_x2y=zeros(order*2,size(roi_sequence,1))';
result_y2x=zeros(order*2,size(roi_sequence,1))';
b_autoreg = zeros(numROIs,1);
covariables=[covariables(order+1:end,:),ones(nDim4-order,1)];
n_pairs = size(roi_sequence,1);
for i=1:n_pairs
    roipair = roi_sequence(i,:);
    roi_used=timecourses(:,roipair);
    now=roi_used(order+1:end,:);
    for j=1:order
        past_1(:,j)=roi_used(j:nDim4-order+j-1,1);
        past_2(:,j)=roi_used(j:nDim4-order+j-1,2);
        Regressors1=[past_1,past_2,covariables];
        Regressors2=[past_2,past_1,covariables];
    end
    b_x2y=rest_regress(now(:,2),Regressors1);
    b_y2x=rest_regress(now(:,1),Regressors2);
    
    % TODO or FIX
    % autoregression coefficient neet check!
    b_autoreg(roipair(2))=rest_regress(now(:,2),past_2);
    b_autoreg(roipair(1))=rest_regress(now(:,1),past_1);
    
    result_x2y(i,:)=b_x2y(1:order*2);
    result_y2x(i,:)=b_y2x(1:order*2);
end
end

function [matgc, matgc_auto] = pair2mat(pairgc,b_autoreg,roi_sequence,n_node)
% pairwise GC to matrix
matgc = zeros(n_node,n_node);
matgc_auto = zeros(n_node,n_node);
n_pairs = size(roi_sequence,1);
for i = 1: n_pairs
    matgc(roi_sequence(i,1),roi_sequence(i,2)) = pairgc(i,1);
    matgc_auto(roi_sequence(i,1),roi_sequence(i,2)) = pairgc(i,2);
end
matgc = matgc + matgc';
matgc_auto = matgc_auto + matgc_auto';
matgc(eye(10)==1) = b_autoreg;
end