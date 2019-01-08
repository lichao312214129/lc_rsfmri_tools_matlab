function residuals=regressOutCovariance(y,X)
% this script is used to regress out covariance using Multiple linear
% regression
% y is the number of samples N *1 vector
% X is the number of samples N * number of features M matrix
%%
nFeatures=size(y,2);
nSubj=size(y,1);
residuals=zeros(nSubj,nFeatures);
for i =1:nFeatures
    residuals(:,i)=regressOutCovarianceForOne(y(:,i),X);
end
end
function residuals=regressOutCovarianceForOne(y,X)
% this script is used to regress out covariance using Multiple linear
% regression
% y is the number of samples N *1 vector
% X is the number of samples N * number of covariances M matrix
%%
nSubj=length(y);
X = [ones(nSubj,1) X];
[~,~,residuals,~,~] = regress(y,X);
end