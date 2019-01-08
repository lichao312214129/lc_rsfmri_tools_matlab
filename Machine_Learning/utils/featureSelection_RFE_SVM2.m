function [ feature_ranking_list ] = featureSelection_RFE_SVM2( data,label,opt )
% Chao Li Email:lichao19870617@gmail.com
% using Recursive Feature Elimination (RFE) to perform feature selection
% please refer to Guyon I, Weston J, Barnhill S, et al.
% Gene selection for cancer classification using support vector machines[J].
% Machine learning, 2002, 46(1): 389-422.
% input----data=M*N matrix; label=M*1 matrix[-1,+1]; M=number of sample; N=number of features
% opt=options,opt.learner='svm' or 'logistic', or ''
% output---features_RFE=selected features by RFE M*n matrix
% new feature:将fitclinear改为fitcsvm，从而使每次建立的机器学习模型一样;2018-02-03 by Li Chao
% new feature:preallocated 'feature_ranking_list'，accelerate code;2018-03-31 by Li Chao
% new feature: 扩展了classifier;2018-04-11 by Li Chao
%% setting opt and identify classifier
% opt
if nargin < 3
    opt.learner='fitcsvm';
    opt.step=10;
    opt.stepmethod='percentage';
end
% classifier
cmdClassifier=['classifier=@ ',opt.learner,';'];
eval(cmdClassifier);
%% preallocate
[~,n]=size(data);
feature_ranking_list=zeros(1,n);
% feature_ranking_list=[];
Index_original=1:1:n;
%% RFE
switch strcmp(opt.stepmethod, 'percentage')
    case 1
        % iterations
        while n>0
            Mdl= classifier(data,label);%step 1: training a svm model
            [~,index_sort]=sort(Mdl.Beta.^2,'ascend'); %step 2: sorting the features according the w^2 of the svm.
            if n > 10
                index_removed=index_sort(1: ceil(n*opt.step/100));%index of be removed features regarding the changed data
                % that with the smallest w^2 of the svm.
            else
                index_removed=index_sort(1);
            end
            %             indexAdd=Index_original(index_removed);
            %             startPointAdd=sum( feature_ranking_list==0)-numel(indexAdd)+1;
            %             endPointAdd=sum( feature_ranking_list==0);
                        feature_ranking_list(sum( feature_ranking_list==0)-numel(Index_original(index_removed))+1:sum( feature_ranking_list==0))=...
                            Index_original(index_removed);
%             feature_ranking_list=[Index_original(index_removed), feature_ranking_list];
            Index_original(index_removed)=[];% Removing the orignal index in the same way.
            % in order to keep the same order with the changed data
            data(:,index_removed)=[];%step 3: removing the features with the smallest w^2 of the svm from the data.
            [~,n]=size(data);
        end
    case 0
        % iterations
        
        while n>0
            %                 disp([num2str(N-n+1),'/',num2str(N)]);
            Mdl= classifier(data,label);% step 1: training a svm model
            [~,index_sort]=sort(Mdl.Beta.^2,'ascend'); % step 2: sorting the features according the w^2 of the svm.
            if n>=opt.step
                index_removed=index_sort(1:opt.step);%index of be removed features regarding the changed data
            else
                index_removed=index_sort(1);
            end
%             feature_ranking_list=[Index_original(index_removed),feature_ranking_list];% final sorted index (from importance to not)
             feature_ranking_list(sum( feature_ranking_list==0)-numel(Index_original(index_removed))+1:sum( feature_ranking_list==0))=...
                            Index_original(index_removed);
            Index_original(index_removed)=[];% Removing the orignal index in the same way.
            % in order to keep the same order with the changed data
            data(:,index_removed)=[];%step 3: removing the features with the smallest w^2 of the svm from the data.
            [~,n]=size(data);
            %                 clc
        end
end
end