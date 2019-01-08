% 计算一组被试dFC的Std
%% input: all mat path
pathStruct=dir('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\DynamicFC18_1\zDynamicFC');
folder={pathStruct.folder};
name={pathStruct.name};
myStd=zeros(114,114,length(name)-2);
%%
parpool(3)
parfor i=3:length(name)
    fprintf('第%d\n',i)
    filePath=fullfile(folder{i},name{i});
    zDynamicFC=importdata(filePath);
    myStd(:,:,i-2)=std(zDynamicFC,0,3);
end
%% save
save('D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\myStd.mat','myStd');
meanStd=mean(myStd,3);
%%
%left
% figure
% % meanStd(abs(meanStd)<0.42)=0;
% imagesc(meanStd([1:57],[1:57]));
% title('left')
% colormap(jet)
% 
% %right
% figure
% % meanStd(abs(meanStd)<0.42)=0;
% imagesc(meanStd([58:end],[58:end]));
% colormap(jet)

%left-right
figure
% meanStd(abs(meanStd)<0.42)=0;
imagesc(meanStd);
colormap(jet)
