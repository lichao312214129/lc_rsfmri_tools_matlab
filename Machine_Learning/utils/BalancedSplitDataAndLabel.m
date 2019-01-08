function [train_data,test_data,train_label,test_label]=...
    BalancedSplitDataAndLabel(data,label,indiceCell,i)
% 平衡的分配训练样本和测试样本：即从各个组中分别按比例分配，再组合
% input：
%     data：all subjects' data,N*M matrix,N=number of subjects,M=number of
%     features
%     indiceCell：各个group的index，cell with demension of 1*N_group,
%     N_group=number of group
%     i: the ith fold CV
% output：
%
%%
numOfGroup=numel(unique(label));
uniLabel=unique(label);
train_data=[];
test_data=[];
train_label=[];
test_label=[];
%%
for ith_group=1:numOfGroup
    index_label_temp=label==uniLabel(ith_group);
    data_temp=data(index_label_temp,:);
    label_temp=label(index_label_temp,:);
    indices_temp=indiceCell{1,ith_group};
    [train_data_temp,test_data_temp,train_label_temp,test_label_temp]=...
        splitOneGroup(data_temp,label_temp,indices_temp,i);
    train_data=cat(1,train_data,train_data_temp);
    test_data=cat(1,test_data,test_data_temp);
    train_label=cat(1,train_label,train_label_temp);
    test_label=cat(1,test_label,test_label_temp);
end

end

function [Train_data,Test_data,Train_label,Test_label]=splitOneGroup(data,label,indices,i)
% 根据indices，将一个组的data和label分成训练集和测试集
Test_index = (indices == i); 
Train_index = ~Test_index;
Test_data =data(Test_index,:);
Train_data =data(Train_index,:);
Test_label=label(Test_index,:);
Train_label=label(Train_index,:);
end