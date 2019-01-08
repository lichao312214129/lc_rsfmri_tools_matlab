function lc_ProportionOfOneRrange_slideWindow(numOfWindows)
% 此代码用来计算动态功能连接中，对于多个slide window的Pearson's r向量（经过Fisher’s z-transformed），
% 落在某个区间的r数目占总r数目的比值。
% refer to {Dynamic Resting-State Functional Connectivity in Major Depression}
% high negative:z<? 0.5), moderate negative:?0.5<=z<-0.25,
% low/uncorrelated:?0.25pzp0.25), moderate positive
% (0.25ozp0.5), and high positive (z>0.5).
%%
if nargin<1
    numOfWindows=str2double(input('请输入window的数目：','s'));
end
% results path
pathOfResult=uigetdir({},'选择结果保存路径');
mkdir(pathOfResult,'Signals');
pathOfSignal=fullfile(pathOfResult,'Signals');
% sinal extracting
[ signal,nameOfAllSubj] = Extract_ROI_Signal4D(numOfWindows,pathOfSignal);
% abs number
high_neg=bsxfun(@lt,signal,-0.5);
moderate_neg=bsxfun(@gt,signal,-0.5).*bsxfun(@lt,signal,-0.25)+bsxfun(@eq,signal,-0.5);
lowOrUncor=(bsxfun(@gt,signal,-0.25)+bsxfun(@eq,signal,-0.25)).*...
    (bsxfun(@lt,signal,0.25)+bsxfun(@eq,signal,0.25));
moderate_pos=bsxfun(@gt,signal,0.25).*bsxfun(@lt,signal,0.5)+bsxfun(@eq,signal,0.5);
high_pos=bsxfun(@gt,signal,0.5);
% proportion
[numOfSubj,n_windows]=size(signal);
prop_high_neg=sum(high_neg,2)/n_windows;
prop_moderate_neg=sum(moderate_neg,2)/n_windows;
prop_lowOrUncor=sum(lowOrUncor,2)/n_windows;
prop_moderate_pos=sum(moderate_pos,2)/n_windows;
prop_high_pos=sum(high_pos,2)/n_windows;
% save proportion
save([pathOfSignal,filesep,'all_proportions.mat'],...
    'prop_high_neg','prop_moderate_neg','prop_lowOrUncor',...
    'prop_moderate_pos','prop_high_pos');

for i=1:numOfSubj
    if mod(i,10)==0
        fprintf('%.0f%%\n',i*100/numOfSubj);
    else
        fprintf('%.0f%%\t',i*100/numOfSubj);
    prop_high_neg1=prop_high_neg(i);
    prop_moderate_neg1=prop_moderate_neg(i);
    prop_lowOrUncor1=prop_lowOrUncor(i);
    prop_moderate_pos1=prop_moderate_pos(i);
    prop_high_pos1=prop_high_pos(i);
        % save
        save([pathOfSignal,filesep,nameOfAllSubj{i},'_prop.mat'],...
            'prop_high_neg1','prop_moderate_neg1','prop_lowOrUncor1',...
    'prop_moderate_pos1','prop_high_pos1');
    end
end
end




function [ Signal,nameOfAllSubj] = Extract_ROI_Signal4D(numOfVolume,pathOfSignal)
% usage: extract multiple signals from 3D or 4D data. If 4D data, the dimension 4 is the volume/time point
% input:
%     data:5D data, dimension 4 is volume/time point,dimension 5 is the number of subjects;
%     mask:3D logic matrix, equal to a volume.
%     numOfVolume= number of volume
% output:
%     signals: N*M, N=number of subjects, M=number of volume/time points.
%% path to save results
% pathOfResult=uigetdir({},'选择结果保存路径');
% mkdir(pathOfResult,'Signals');
% pathOfSignal=fullfile(pathOfResult,'Signals');
%% mask
[nameOfMask,pathOfMaks,~] = uigetfile({'*.nii;*.img;','All Image Files';...
    '*.*','All Files'},'MultiSelect','off','选择mask');
fullNameOfMask=fullfile(pathOfMaks,nameOfMask);
mask=load_nii(fullNameOfMask);
mask=mask.img;
mask=mask~=0;
%% extract signal
dirContainAllSubj=uigetdir({},'选择所有被试的4D .img/.nii 文件所在文件夹');
dirOfAllSubj=dir(dirContainAllSubj);
nameOfAllSubj={dirOfAllSubj.name};
nameOfAllSubj=nameOfAllSubj(3:end)';
pathOfAllSubj=fullfile(dirContainAllSubj,nameOfAllSubj);
numOfSubj=length(pathOfAllSubj);
% preallocate
Signal=zeros(numOfSubj,numOfVolume);
% extract signal according subject's order
for i=1:numOfSubj
    if mod(i,10)==0
        fprintf('%.0f%%\n',i*100/numOfSubj);
    else
        fprintf('%.0f%%\t',i*100/numOfSubj);
    end
    imgName=dir(pathOfAllSubj{i});
    imgName={imgName.name};
    %     imgName=imgName(3:end)';
    pathOfImgName=fullfile(dirContainAllSubj,imgName);
    dataStrut=load_nii(char(pathOfImgName));
    data=dataStrut.img;
    signal=extractROISignal(data,mask,'mean');
    Signal(i,:) = signal;
    % save
    save([pathOfSignal,filesep,nameOfAllSubj{i},'.mat'],'signal');
end
%% save all signal
save([pathOfSignal,filesep,'signalAllSubj_From_',nameOfMask,'.mat'],'Signal');
fprintf('\n===============Completed!===================\n');
end

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