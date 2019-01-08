function [ feature_ranking_list ] = FeatureSelection_RFE_SVM( data,label,opt )
% Chao Li Email:lichao19870617@gmail.com
% using Recursive Feature Elimination (RFE) to perform feature selection
% please refer to Guyon I, Weston J, Barnhill S, et al.
% Gene selection for cancer classification using support vector machines[J].
% Machine learning, 2002, 46(1): 389-422.
% input----data=M*N matrix; label=M*1 matrix[-1,+1]; M=number of sample; N=number of features
% opt=options,opt.learner='svm' or 'logistic', or ''
% output---features_RFE=selected features by RFE M*n matrix
%% here goes code
%setting opt
if nargin <= 2
    opt.learner='svm';
    opt.step=50;
    % iterations
    data_temp=data;
    [~,n]=size(data_temp);
    N=n;%for count the iteration
    Index_original=1:1:n;
    feature_ranking_list=[];
    while n>0
        disp([num2str(N-n+1),'/',num2str(N)]);
        Mdl= fitclinear(data_temp,label,'Learner',opt.learner);%step 1: training a svm model
        [~,index_sort]=sort(Mdl.Beta.^2,'ascend'); %step 2: sorting the features according the w^2 of the svm.
        if n>=opt.step
            index_removed=index_sort(1:opt.step);%index of be removed features regarding the changed data
        else
            index_removed=index_sort(1);
        end
        % that with the smallest w^2 of the svm.
        feature_ranking_list=[Index_original(index_removed),feature_ranking_list];% final sorted index (from importance to not)
        Index_original(index_removed)=[];% Removing the orignal index in the same way.
        % in order to keep the same order with the changed data
        data_temp(:,index_removed)=[];%step 3: removing the features with the smallest w^2 of the svm from the data.
        [~,n]=size(data_temp);
%         clc
    end
end

if nargin==3
    switch strcmp(opt.stepmethod, 'percentage')
        case 1
            % iterations
            data_temp=data;
            [~,n]=size(data_temp);
            N=n;%for count the iteration
            Index_original=1:1:n;
            feature_ranking_list=[];
            while n>0
%                 disp([num2str(N-n+1),'/',num2str(N)]);
                Mdl= fitclinear(data_temp,label,'Learner',opt.learner);%step 1: training a svm model
                [~,index_sort]=sort(Mdl.Beta.^2,'ascend'); %step 2: sorting the features according the w^2 of the svm.
                if n >10
                    index_removed=index_sort(1: ceil(n*opt.step/100));%index of be removed features regarding the changed data
                    % that with the smallest w^2 of the svm.
                else
                    index_removed=index_sort(1);
                end
                feature_ranking_list=[Index_original(index_removed),feature_ranking_list];% final sorted index (from importance to not)
                Index_original(index_removed)=[];% Removing the orignal index in the same way.
                % in order to keep the same order with the changed data
                data_temp(:,index_removed)=[];%step 3: removing the features with the smallest w^2 of the svm from the data.
                [~,n]=size(data_temp);
%                 clc
            end
        case 0
            % iterations
            data_temp=data;
            [~,n]=size(data_temp);
            N=n;%for count the iteration
            Index_original=1:1:n;
            feature_ranking_list=[];
            while n>0
%                 disp([num2str(N-n+1),'/',num2str(N)]);
                Mdl= fitclinear(data_temp,label,'Learner',opt.learner);%step 1: training a svm model
                [~,index_sort]=sort(Mdl.Beta.^2,'ascend'); %step 2: sorting the features according the w^2 of the svm.
                if n>=opt.step
                    index_removed=index_sort(1:opt.step);%index of be removed features regarding the changed data
                else
                    index_removed=index_sort(1);
                end
                feature_ranking_list=[Index_original(index_removed),feature_ranking_list];% final sorted index (from importance to not)
                Index_original(index_removed)=[];% Removing the orignal index in the same way.
                % in order to keep the same order with the changed data
                data_temp(:,index_removed)=[];%step 3: removing the features with the smallest w^2 of the svm from the data.
                [~,n]=size(data_temp);
%                 clc
            end
    end
end
end