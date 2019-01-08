% function machineLearningForLowDimensionData()
% 用来对降维后的数据进行机器学习
%% =================================================================
% input
k=10;
trainingDataPath_original='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\trainingData_originalALFF.xlsx';
trainingDataPath='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\trainingData.xlsx';
testDataPath='D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\testData.xlsx';
ifSaveModel=0;
ifShow=1;
ifOriginalALFF=0;
ifTrainingFinalModel=1;
if_save_predict_label=0;
if_save_figure=0;
%% =================================================================
% load data
if ifOriginalALFF
    [trainingData,~]=xlsread(trainingDataPath_original);
    [~,trainingLabel]=xlsread(trainingDataPath);
else
    [trainingData,trainingLabel]=xlsread(trainingDataPath);
    trainingData=trainingData(:,end-9:end);%选择n维的数据
end
[testData,testLabel_struct]=xlsread(testDataPath);
testData=testData(1:282,end-9:end);%只选择病人组的n维的数据

% extract label
trainingLabel=trainingLabel(2:end,2);
trainingLabel=double(cellfun(@(x) x=='a',trainingLabel));
testLabel_struct=testLabel_struct(2:end,1);
testLabel_struct= cellfun(@(x) strsplit(x,'-'),testLabel_struct,'UniformOutput',false);
testLabel=cellfun(@(x) str2double(x(1)), testLabel_struct);
testFolder=cellfun(@(x) x(2), testLabel_struct);

% step2： 标准化效果最好
% mean(trainingData(:));std(trainingData(:))
% mean(testData(:));std(testData(:))
% [trainingData,testData]=lc_standardization(trainingData,testData,'scale');
trainingData=zscore(trainingData,0,1);
testData=zscore(testData,0,1);
%% =================================================================
% 交叉验证
Model=cell(5,1);
Decision=cell(k,1);
AUC=zeros(k,1);
Accuracy=zeros(k,1);
Sensitivity=zeros(k,1);
Specificity=zeros(k,1);
PPV=zeros(k,1);
NPV=zeros(k,1);
for i=1:k
    fprintf('%d/%d\n',i,k);
    % step1：将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
    n_patients=sum(trainingLabel==1);
    n_controls=sum(trainingLabel~=1);
    
    indices_p = crossvalind('Kfold', n_patients, k);
    indices_c = crossvalind('Kfold', n_controls, k);
    indiceCell={indices_c,indices_p};
    
    [train_data,test_data,Train_label,Test_label]=...
        BalancedSplitDataAndLabel(trainingData,trainingLabel,indiceCell,i);
    
    % step2： 标准化或者归一化
    %     [train_data,test_data]=lc_standardization(train_data,test_data,'scale');
    
    model= fitcsvm(train_data,Train_label,'KernelFunction','RBF',...
    'KernelScale','auto');
    
    % estimate mode/SVM
    [predict_label, dec_values] = predict(model,test_data);
    Model{i}=model;
    Decision{i}=dec_values(:,1);
    [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,Test_label);
    Accuracy(i) =accuracy;
    Sensitivity(i) =sensitivity;
    Specificity(i) =specificity;
    PPV(i)=ppv;
    NPV(i)=npv;
    [AUC(i)]=AUC_LC(Test_label,dec_values(:,2));
end
fprintf('=======Done!======\n')
%% =================================================================
% save results
if ifSaveModel
    save('Model.mat','Model');
end
%% =================================================================
% show results
if ifShow
    performance={AUC,Accuracy,Sensitivity,Specificity,PPV,NPV};
    mytitle={'AUC','Accuracy','Sensitivity','Specificity','PPV','NPV'};
    figure
    for i=1:6
        subplot(2,3,i)
        plot(performance{i},'-o');
        title(mytitle{i});
    end
    % save figure
    if if_save_figure
        print(gcf,'-dtiff','-r300',['CV'])
    end
    
    % mean
    figure
    Balance_Accuracy=(Sensitivity+Specificity)./2;
    bar_errorbar3( {AUC,Accuracy,Balance_Accuracy,Sensitivity,Specificity,PPV,NPV} )
    title('mean performances');
    % save figure
    if if_save_figure
        set (gcf,'Position',[100,50,600,500], 'color','w')
        print(gcf,'-dtiff','-r300',['mean performances'])
    end

end
%% =================================================================
% 如果在训练集内交叉验证效果不错，那么就用总训练集建模，然后在测试集上测试
if ifTrainingFinalModel
    model_allTrainingData= fitcsvm(trainingData,trainingLabel,'KernelFunction','RBF',...
        'KernelScale','auto');
    [predictLabel_testData, dec_values] = predict(model_allTrainingData,testData);
%     save predictLabel_testData
    if if_save_predict_label
        xlswrite('predictLabel_testData.xlsx',predictLabel_testData)
    end
    fprintf('预测为a的数:%d\n',sum(predictLabel_testData));
end

function  bar_errorbar3( Matrix )
%% =================================================================
showXTickLabels=1;
showYLabel=0;
showLegend=0;
%% =================================================================
Mean=cell2mat(cellfun(@(x) mean(x,1),Matrix,'UniformOutput',false)')';
Std=cell2mat(cellfun(@(x) std(x),Matrix,'UniformOutput',false)')';

h = bar(Mean,0.6,'EdgeColor','k','LineWidth',1.5);
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';%获取每一个柱状图中线的x坐标
coordinate_x=f(get(h,{'xoffset','xdata'}));
hold on
%画误差线
for i=1:numel(Mean)
    if Mean(i)>=0
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)+Std(i)],'linewidth',2);
    else
        line([coordinate_x(i),coordinate_x(i)],[Mean(i),Mean(i)-Std(i)],'linewidth',2);
    end
end
grid on
box off
ax=gca;
% x轴的label
ax.XTickLabels = ...
    {'AUC','Accuracy','Balance-Accuracy','Sensitivity','Specificity','PPV','NPV'};
set(ax,'Fontsize',15);
ax.XTickLabelRotation = 45;

% y轴的labe
ylabel('dALFF','FontName','Times New Roman','FontWeight','bold','FontSize',20);
% legend
% h=legend('HC','SZ','BD','MDD','Orientation','horizontal','Location','best');%根据需要修改
% set(h,'Fontsize',15);%设置legend字体大小
% set(h,'Box','off');
% h.Location='best';
box off
end
