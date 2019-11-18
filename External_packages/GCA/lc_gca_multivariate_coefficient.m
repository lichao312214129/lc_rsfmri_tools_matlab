function Results = restgca_CROI(timecourses,order,covariables)
% Tis function is used to perform multivariate ROI-wise Granger Causal Analysis
% Revised from REST software
nDim4=length(timecourses);
numROIs=size(timecourses,2);
Past=zeros(nDim4-order,numROIs,order);
Now=timecourses(order+1:end,:);
Results=zeros(numROIs,numROIs*order);
for i=1:order,
    for j=1:numROIs,
        Past(:,j,i)=timecourses(i:nDim4-order+i-1,j);
    end
end
Past=reshape(Past,nDim4-order,numROIs*order);
covariables=[covariables(order+1:end,:),ones(nDim4-order,1)];
Regressors=[Past,covariables];
for k=1:numROIs,
    b=rest_regress(Now(:,k),Regressors);
    Results(k,:)=b(1:numROIs*order);
end
Results=reshape(Results,numROIs,numROIs,order);