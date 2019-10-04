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
    columns_quantity = size(testData,2);
    test_data_temp = zeros(size(testData));
    for i = 1:columns_quantity
        if StandardDeviation(i)
            test_data_temp(:, i) = (testData(:, i) - MeanValue(i)) / StandardDeviation(i);
        end
    end
    standardizedTestData = test_data_temp;
    standardizedTrainData=zscore(trainingData);
end

% scale: 按列(特征方向)方向归一化
if strcmp(standardizationMethod,'scale')
    [trian_data_temp,PS] = mapminmax(trainingData',-1,1);
    trian_data_temp=trian_data_temp';
    test_data_temp = mapminmax('apply',testData',PS);
    test_data_temp =test_data_temp';
    standardizedTrainData=trian_data_temp;
    standardizedTestData=test_data_temp;
end
end