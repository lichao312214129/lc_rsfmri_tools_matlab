function lc_DynamicBC_clustermatrix(k,subjdir,output,CluMet)
% 对动态功能连接矩阵进行聚类
% 请务必引用DynamicBC
% 此代码以及被我修改：
    % 1：只是用上三角矩阵（不包括对角线）
    % 2：只使用组水平的聚类结果，从而导致某些被试缺乏某些状态，但是很多研究是如此
%% ============================输入=================================
% k=5;
% subjdir='D:\WorkStation_2018\WorkStation_dynamicFC\Data\zDynamic\DynamicFC_length17_step1_screened';
% output='D:\WorkStation_2018\WorkStation_2018_08_Doctor_DynamicFC_Psychosis\Data\zDynamic\state_test'
% CluMet='cityblock';
%% =================================================================
subFold = dir(fullfile(subjdir,'*.mat'));
% save subjName
subjName={subFold.name}';
mkdir(output);
save(fullfile(output,'subjName.mat'),'subjName');
%
nSubj = size(subFold,1);
% pre-allocating space
filaName=fullfile(subjdir,subFold(1).name);
dynamicMats=importdata(filaName);
nNode=size(dynamicMats,1);
nWindow = length(dynamicMats);
upMatMask=triu(ones(nNode,nNode),1)==1;%上三角矩阵mask
nFeature=sum(upMatMask(:));
tmpMat=zeros(nFeature,nWindow);
allMatrix = zeros(nFeature,nWindow,nSubj);
for i = 1:nSubj
    fprintf('load %dth dynamic matrix to all matrix\n',i);
   % if isfile(fullfile(subjdir,subFold(i+2).name))
        filaName=fullfile(subjdir,subFold(i).name);
        dynamicMats=importdata(filaName);
        % 注意：为了节约计算成本，我只提取每一个FC的上三角矩阵
        % 由于对角线没有聚类功能，因此不包括对角线
        for imat = 1:nWindow
            upMat=dynamicMats(:,:,imat);
            upMat=upMat(upMatMask);
            tmpMat(:,imat)=upMat;
        end
        allMatrix(:,:,i) = tmpMat;
    %end
end
fprintf('======loaded all mat!======\n')
%% kmeans
fprintf('kmeans clustering...\n');
allMatrix(isinf(allMatrix))=1;
allMatrix(isnan(allMatrix))=0;
allMatrix=reshape(allMatrix,nFeature,nWindow*nSubj)';
[IDX,C,sumd,D] = kmeans(allMatrix,k,'distance',CluMet);
% 随机多次质心，样本量大将会非常耗时
% opts = statset('Display','final');
% [Idx,C,sumD,~] = kmeans(allMatrix,k,'Distance',distanceMethod,...
%     'Replicates',5,'Options',opts);
% save_dir = fullfile(output,['mat_',CluMet,'_Kmeans_',num2str(k)]);
% mkdir(save_dir);
for i = 1:k
    ind = IDX==i;
    tmpMat=allMatrix(ind,:);
    meanMat = mean(tmpMat,1);
    squareMat=eye(nNode);
    squareMat(upMatMask)=meanMat;
    squareMat=squareMat+squareMat';
    squareMat(eye(nNode)==1)=1;
    save(fullfile(output,['Cluster_',num2str(i),'.mat']),'squareMat');
end
% save IDX
save(fullfile(output,'IDX.mat'),'IDX');
fprintf('============Done!============\n');
%%
% for isubj = 1:inums-1
%     DATUSED = matrix_all{isubj};
%
%     [IDX,C,sumd,D] = kmeans(DATUSED',k,'distance',CluMet);
%     mkdir(fullfile(save_dir,subjlist{isubj}));
%     for i = 1:k
%         indtemp = find(IDX==i);
%         meanmaptemp = mean(DATUSED(:,indtemp),2);
%         DAT = reshape(meanmaptemp,dims(1),dims(2));
%         save(fullfile(save_dir,subjlist{isubj},['Cluster',num2str(i),'.mat']),'DAT')
%     end
%     IDX_subj{isubj} = IDX;
% end
end

