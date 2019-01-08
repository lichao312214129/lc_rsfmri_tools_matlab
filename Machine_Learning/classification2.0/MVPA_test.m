% load test data
load('J:\lichao\MATLAB_Code\libsvm\libsvm\heart_scale.mat')
% split data to generate training and test data and label
dataTrain=heart_scale_inst(1:200,:);
dataTest=heart_scale_inst(201:end,:);
labelTrain=heart_scale_label(1:200,:);
labelTest=heart_scale_label(201:end,:);
% choose classifier
classifier=@fitclinear;
% training and test
model=classifier(dataTrain, labelTrain);

[labelPredict] = predict(model,dataTest);
% performances
[accuracy,sensitivity,specificity,PPV,NPV]=...
    Calculate_Performances(labelPredict,labelTest)