function [train_data_standard, test_data_standard ] = Standard( train_data,test_data, opt )
%z标准化或归一化数据
%   input =data
%   input =data_standard
if nargin<3
    opt.standard='scale';
    opt.min_scale=0;opt.max_scale=1;
end
if strcmp(opt.standard,'normalizing')
    MeanValue = mean(train_data);
    StandardDeviation = std(train_data);
    [row_quantity, columns_quantity] = size(train_data);
    train_data_standard=zeros(row_quantity, columns_quantity);
    for ii = 1:columns_quantity
        if StandardDeviation(ii)
            train_data_standard(:, ii) = (train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
        end
    end
    test_data = (test_data - MeanValue) ./ StandardDeviation;
end

if strcmp(opt.standard,'scale')
    [train_data_standard,PS] = mapminmax(train_data');
    train_data_standard=train_data_standard';
    test_data_standard = mapminmax('apply',test_data',PS);
    test_data_standard =test_data_standard';
end

end

