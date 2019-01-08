function signal = extractROISignal(data,mask,extractType)
% usage: extract mean or PCA signals from 3D or 4D data. If the data are 4D,
% the dimension 4 is the volume/time point
% input:
%      data: 3D or 4D  data.
%      If the data are 4D,the dimension 4 is the volume/time point.
%      mask: 3D logic matrix
%      extractType='mean' OR 'pca',extract mean signals or pca signals
% output:
%      signal: its dimension is the same as the data
%%
if nargin
    extractType='mean';
end
%%
signal=[];
[~,~,~,dim4]=size(data);
%%
if dim4==1
    if strcmp(extractType,'mean')
        signal=mean(data(mask));
    elseif strcmp(extractType,'pca')
        %             signal=data(mask);% 后续添加
    else
        fprintf('please set which signal to extract：mean or pca\n')
    end
else
    if strcmp(extractType,'mean')
        for i=1:dim4
            data_temp=data(:,:,:,i);
            signal=cat(2,signal,mean(data_temp(mask)));
        end
    elseif strcmp(extractType,'pca')
        %             signal=data(mask);% 后续添加
    else
        fprintf('please set which signal to extract：mean or pca\n')
    end
end
end