function [ PER,Accuracy, Sensitivity, Specificity, PPV, NPV, Decision, AUC, W_M_Brain,performances] =...
    SVM_LC_Kfold_ttest2_ByPValue3(K,Initial_PValue,Max_PValue,Step_PValue,opt)
%feature selection by ttest2
%此代码在heart数据集上测试成功
%input：K=K-fold cross validation,K<N
%input:Initial_FeatureNum=初始的特征数；Max_FeatureNum=最大特征数；Step_FeatureNum=每次增加的特征数。
%output：分类表现以及K-fold的平均分类权重
% path=pwd;
% addpath(path);
if nargin<5
    opt.standard='normalizing';
end
if nargin<1
    K=3;Initial_PValue=0.01;Max_PValue=0.1;Step_PValue=0.005;
    opt.standard='normalizing';
end

%% transform .nii/.img into .mat data, and achive corresponding label
[~,~,data_patients ] = Img2Data_LC;
[~,~,data_controls ] = Img2Data_LC;
[dim1,dim2,dim3,n_patients]=size(data_patients);
[~,~,~,n_controls]=size(data_controls);
data=cat(4,data_patients,data_controls);%data
label=[ones(n_patients,1);zeros(n_controls,1)];%label
%% just keep data in inmask
N=n_patients+n_controls;
data=reshape(data,[dim1*dim2*dim3,N]);%行方向为特征方向，每一列为一个样本，每一行为一个特征
implicitmask = sum(data,2)~=0;%内部mask,逐行累加
data_inmask=data(implicitmask,:);%内部mask内的data
data_inmask=data_inmask';
data_inmask_p=data_inmask(label==1,:);
data_inmask_c=data_inmask(label==0,:);
%%
PER=[];%不同特征数目的平均分类表现
% for PValue=Initial_PValue:Step_PValue:Max_PValue % 不同特征数目情况下
%% 预分配空间
% w_M_Brain=zeros(1,sum(implicitmask));
Num_loop_Pvalue=length(Initial_PValue:Step_PValue:Max_PValue);
Accuracy=zeros(K,Num_loop_Pvalue);Sensitivity =zeros(K,Num_loop_Pvalue);Specificity=zeros(K,Num_loop_Pvalue);
AUC=zeros(K,Num_loop_Pvalue);Decision=cell(K,Num_loop_Pvalue);PPV=zeros(K,Num_loop_Pvalue); NPV=zeros(K,Num_loop_Pvalue);
W_M_Brain=zeros(Num_loop_Pvalue,dim1*dim2*dim3);
W_Brain=zeros(Num_loop_Pvalue,sum(implicitmask),K);%weight map of implicit mask
label_ForPerformance=NaN(N,1);
Predict=NaN(K,N,1);
%%  K fold loop
% 多线程预备
% if nargin < 2
%   parworkers=0;%default
% end
% 多线程准备完毕
h=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
% s=rng;%可重复、一致
% rng(s);%可重复、一致
indices = crossvalind('Kfold', N, K);%此处不受随机种子点控制，因此每次结果还是不一样。
indices_p = crossvalind('Kfold', n_patients, K);%此处不受随机种子点控制，因此每次结果还是不一样。
indices_c = crossvalind('Kfold', n_controls, K);%此处不受随机种子点控制，因此每次结果还是不一样。
switch K<N
    case 1
        % initialize progress indicator
        %         parfor_progress(K);
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %% 将数据分成训练样本和测试样本（分别从患者和对照组中抽取，目的是为了数据平衡）
            % patients data
            Test_index_p = (indices_p == i); Train_index_p = ~Test_index_p;
            Test_data_p =data_inmask_p(Test_index_p,:);Train_data_p =data_inmask_p(Train_index_p,:);
            % controls data
            Test_index_c = (indices_c == i); Train_index_c = ~Test_index_c;
            Test_data_c =data_inmask_c(Test_index_c,:);Train_data_c =data_inmask_c(Train_index_c,:);
            % all data
            Train_data=[Train_data_p;Train_data_c];
            Test_data=[Test_data_p;Test_data_c];
            % all label
            Test_label = [ones(sum(indices_p==i),1);zeros(sum(indices_c==i),1)];
            Train_label =  [ones(sum(indices_p~=i),1);zeros(sum(indices_c~=i),1)];
            %双样本t检验（filter）
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:),'Tail','both');
            %% inner loop: ttest2, feature selection and scale
            j=0;%计数，为W_M_Brain赋值。
            h1 = waitbar(0,'...');
            for PValue=Initial_PValue:Step_PValue:Max_PValue % 不同P value情况下
                j=j+1;%计数。
                waitbar(j/Num_loop_Pvalue,h1,sprintf('%2.0f%%', j/Num_loop_Pvalue*100)) ;
                Index=find(P<=PValue);%将小于等于某个P值得特征选择出来。
                train_data= Train_data(:,Index);
                test_data=Test_data(:,Index);
                % step2： 标准化或者归一化
                if strcmp(opt.standard,'normalizing')
                    MeanValue = mean(Train_data);
                    StandardDeviation = std(Train_data);
                    [row_quantity, columns_quantity] = size(Train_data);
                Train_data_temp=zeros(row_quantity, columns_quantity);
                for ii = 1:columns_quantity
                    if StandardDeviation(ii)
                        Train_data_temp(:, ii) = (Train_data(:, ii) - MeanValue(ii)) / StandardDeviation(ii);
                    end
                end
                Test_data_temp = (Test_data - MeanValue) ./ StandardDeviation;
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
            
            if strcmp(opt.standard,'scale')
                [Train_data_temp,PS] = mapminmax(Train_data');
                Train_data_temp=Train_data_temp';
                Test_data_temp = mapminmax('apply',Test_data',PS);
                Test_data_temp =Test_data_temp';
                Train_data=Train_data_temp;Test_data=Test_data_temp;
            end
                %% 训练模型
                model= fitcsvm(train_data,Train_label);
                %%
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                %% estimate mode/SVM
                [accuracy,sensitivity,specificity,ppv,npv]=Calculate_Performances(predict_label,Test_label);
                Accuracy(i,j) =accuracy;
                Sensitivity(i,j) =sensitivity;
                Specificity(i,j) =specificity;
                PPV(i,j)=ppv;
                NPV(i,j)=npv;
                [AUC(i,j)]=AUC_LC(Test_label,dec_values(:,2));
                %%  空间判别模式
                w_Brain = model.Beta;
                W_Brain(j,Index,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                %而Index(1:N_feature)内的权重则被赋值（前面有预分配0向量）
                %             if ~randi([0 4])
                %                 parfor_progress;%进度条
                %             end
            end
            close (h1)
        end
        close (h)
    case 0 %equal to leave one out cross validation, LOOCV
        clear Predict
        for i=1:K
            waitbar(i/K,h,sprintf('%2.0f%%', i/K*100)) ;
            %K fold
            test_index = (indices == i); train_index = ~test_index;
            Train_data =data_inmask(train_index,:);
            Train_label = label(train_index,:);
            Test_data = data_inmask(test_index,:);
            Test_label = label(test_index);
            label_ForPerformance(i)=Test_label;
            [~,P,~,~]=ttest2(Train_data(Train_label==1,:), Train_data(Train_label==0,:));%patients VS controls;
            %% ttest2, feature selection and scale
            %% inner loop: ttest2, feature selection and scale
            j=0;%计数，为W_M_Brain赋值。
            h1 = waitbar(0,'...');
            for PValue=Initial_PValue:Step_PValue:Max_PValue % 不同特征数目情况下
                j=j+1;%计数。
                waitbar(j/Num_loop_Pvalue,h1,sprintf('%2.0f%%', j/Num_loop_Pvalue*100)) ;
                Index=find(P<=PValue);%将小于等于某个P值得特征选择出来。
                train_data= Train_data(:,Index);
                test_data=Test_data(:,Index);
                %按列方向归一化
                % [train_data,test_data,~] = ...
                %    scaleForSVM(train_data,test_data,0,1);%一起按列方向归一化，此处有争议，但从实际角度来说，是可以的。
                [train_data,PS] = mapminmax(train_data');
                train_data=train_data';
                test_data = mapminmax('apply',test_data',PS);
                test_data =test_data';
                %% 训练模型
                model= fitclinear(train_data,Train_label);
                %% 预测 or 分类
                [predict_label, dec_values] = predict(model,test_data);
                Decision{i,j}=dec_values(:,2);
                Predict(i,j)=predict_label;
                %%  空间判别模式
                w_Brain = model.Beta;
                W_Brain(j,Index,i) = w_Brain;%次W_Brian将Index(1:N_feature)以外位置的体素权重设为0
                %而Index(1:N_feature)内的权重则被赋值（前面有预分配0向量）
                %             if ~randi([0 4])
                %                 parfor_progress;%进度条
                %             end
            end
            close (h1)
        end
        close (h)
end
%% 平均的空间判别模式
W_mean=mean(W_Brain,3);%取所有LOOVC的w_brain的平均值，注意此处考虑到loop中未被选中的体素，处理方法是前面将其权重设为0
W_M_Brain(:,implicitmask)=W_mean;%不同P value时的全脑体素权重
% W_M_Brain_3D=reshape(W_M_Brain,dim1,dim2,dim3);
%% 整理分类性能
Accuracy(isnan(Accuracy))=0; Sensitivity(isnan(Sensitivity))=0; Specificity(isnan(Specificity))=0;
PPV(isnan(PPV))=0; NPV(isnan(NPV))=0; AUC(isnan(AUC))=0;
%% 显示模型性能 K < N
if K<N
    performances=[[mean(Accuracy);mean(Sensitivity);mean(Specificity);mean(PPV);mean(NPV);mean(AUC)],...
        [std(Accuracy);std(Sensitivity);std(Specificity);std(PPV);std(NPV);std(AUC)]];%前一半是Mean 后一半是Std
end
%% 显示模型性能 K==N，等价于LOOCV
if K==N
    clear Accuracy Sensitivity Specificity PPV NPV AUC
    for k=1:size(Predict,2)
        [Accuracy(k), Sensitivity(k), Specificity(k), PPV(k), NPV(k)]=Calculate_Performances(Predict(:,k),label_ForPerformance);
        AUC(k)=AUC_LC(label_ForPerformance,cell2mat(Decision(:,k)));
        performances=[Accuracy;Sensitivity;Specificity;PPV;NPV];%显示分类表现
    end
end

%% visualize performance
Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
N_plot=length(Initial_PValue:Step_PValue:Max_PValue);
h=figure;
h.Name='Mean performance';
% for j=1:6
% subplot(3,2,j);
plot((Initial_PValue:Step_PValue:Max_PValue),performances(1,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
hold on;
plot((Initial_PValue:Step_PValue:Max_PValue),performances(2,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
hold on;
plot((Initial_PValue:Step_PValue:Max_PValue),performances(3,(1:1:N_plot)),'-','markersize',10,'LineWidth',3.5);
% plot((Initial_PValue:Step_PValue:Max_PValue),PER(1,[2:2:2*N_plot]),'--o','LineWidth',3);
xlabel('P value','FontName','Times New Roman','FontWeight','bold','FontSize',20);
ylabel([Name_plot{6}],'FontName','Times New Roman','FontWeight','bold','FontSize',20);
set(gca,'Fontsize',15);%设置坐标字体大小
fig=legend('accuracy','sensitivity', 'specificity');
% fig=legend('mean','standard deviation');
set(fig,'Fontsize',15);%设置legend字体大小
fig.Location='NorthEastOutside';
% set(gca,'XTick',Initial_PValue:Step_PValue:Max_PValue);%设置x轴的间隔及范围。
xlim([0 Max_PValue]);
set(gca,'YTick',0.1:0.1:1);%设置y轴的间隔及范围。
grid on;
%% errorbar
if K<N
    h1=figure;
    h1.Name='accuracy';
    errorbar((Initial_PValue:Step_PValue:Max_PValue),performances(1,(1:1:N_plot)),performances(3,(N_plot+1:1:2*N_plot)))
end
end

