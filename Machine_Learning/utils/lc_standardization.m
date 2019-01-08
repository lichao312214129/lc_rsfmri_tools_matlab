function [standardizedTrainData,standardizedTestData]=...
                             lc_standardization(trainingData,testData,standardizationMethod)
% 数据的标准化
% 使用GPU处理，加快速度。2018-04-30 By Li Chao
% method='normalization' or 'scale'
%%
if nargin<3
    standardizationMethod='scale';
end
%%
% normalizing
if strcmp(standardizationMethod,'normalization')
    MeanValue = mean(trainingData);
    StandardDeviation = std(trainingData);
%     [row_quantity, columns_quantity] = size(trainingData);
%     train_data_temp=zeros(row_quantity, columns_quantity);
%     
%     for ii = 1:columns_quantity
%         if StandardDeviation(ii)
%             train_data_temp(:, ii) = (trainingData(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
%         end
%     end
    standardizedTestData = (testData - MeanValue) ./ StandardDeviation;
    standardizedTrainData=zscore(trainingData);
end
% scale: 按列(特征方向)方向归一化
if strcmp(standardizationMethod,'scale')
    [train_data_temp,PS] = mapminmax(trainingData',-1,1);
    train_data_temp=train_data_temp';
    test_data_temp = mapminmax('apply',testData',PS);
    test_data_temp =test_data_temp';
    standardizedTrainData=train_data_temp;
    standardizedTestData=test_data_temp;
end
end