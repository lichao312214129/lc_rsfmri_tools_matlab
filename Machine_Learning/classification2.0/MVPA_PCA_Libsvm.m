labelPredict=cell(opt.K,numOfFeatureSet);
tic;
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% Outer K-fold + Inner RFE
for i=1:opt.K
    waitbar(i/opt.K,h,sprintf('%2.0f%%', i/opt.K*100)) ;
    % step1：将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    [dataTrain,dataTest,labelTrain,labelTest]=...
        BalancedSplitDataAndLabel(data_inmask,label,indiceCell,i);
    % step2： 标准化或者归一化
    [dataTrain,dataTest]=Standardization(dataTrain,dataTest,opt.standard);
    % step3：加入单变量的特征过滤
    % PCA
    [COEFF,dataTrain] = pca(dataTrain);%分别对训练样本、测试样本进行主成分降维。
    dataTest = dataTest*COEFF;
    % 参数寻优
%     [bestacc,bestc,bestg]=...
%         SVMcgForClass(labelTrain,dataTrain,-10,10,-10,10,5,0.5,0.5,4.5);
    % step5： training model and predict test data using different feature subset
%     cmdBestPara=['-c ', num2str(bestc), ' -g ', num2str(bestg)];
%     model = svmtrain(labelTrain,dataTrain,'-t 0');
%     [pre,acc(:,i)] = svmpredict(labelTest,dataTest,model);
    model=fitcsvm(dataTrain,labelTrain);
    [labelPredict{i}, dec_values] = predict(model,dataTest);
    [accuracy(i),sensitivity(i),specificity(i),ppv,npv]=Calculate_Performances(labelPredict{i},labelTest);
end
    %     if ~opt.permutation; h1 = waitbar(0,'...');end
    numOfMaxFeatureQuantity=min(opt.Max_FeatureQuantity,size(dataTrain,2));%最大特征数
    numOfMaxFeatureIteration=length(opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:numOfMaxFeatureQuantity);%最大迭代次数
    j=0;% count
    for FeatureQuantity=1:1:numOfMaxFeatureQuantity
        j=j+1;%计数
%         if ~opt.permutation
%             waitbar(j/numOfMaxFeatureIteration,h1,sprintf('%2.0f%%', j/numOfMaxFeatureIteration*100)) ;
%         end
        Index_selectfeature=feature_ranking_list(1:FeatureQuantity);
        dataTrainTemp= dataTrain(:,Index_selectfeature);
        dataTestTemp=dataTest(:,Index_selectfeature);
        label_ForPerformance{i,1}=labelTest;
        % training and predict/testing
        model= classifier(dataTrainTemp,labelTrain);
        [labelPredict{i,j}, dec_values] = predict(model,dataTestTemp);
        Decision{i,j}=dec_values(:,2);
        % Calculate performance of model
        [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(labelPredict{i,j},labelTest);
        Accuracy(i,j) =accuracy;
        Sensitivity(i,j) =sensitivity;
        Specificity(i,j) =specificity;
        PPV(i,j)=ppv;
        NPV(i,j)=npv;
        [AUC(i,j)]=AUC_LC(labelTest,dec_values(:,1));
        %  空间判别模式
    end
%     if ~opt.permutation
%         close (h1);
%     end
    % step 5 completed!
end
close (h);
toc

[loc_best,predict_label_best,~,Accuracy_best,Sensitivity_best,Specificity_best,...
    ~,~,AUC_best]=...
    IdentifyBestPerformance(labelPredict,Accuracy,Sensitivity,Specificity,PPV,NPV,AUC,'accuracy');
 plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
        opt.Initial_FeatureQuantity,opt.Step_FeatureQuantity,opt.Max_FeatureQuantity)