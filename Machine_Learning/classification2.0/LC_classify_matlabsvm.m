function [results]=LC_classify_matlabsvm(data_train, label_train, data_test, opt)
% matlab svm classifier
%
% [results]=LC_classify_matlabsvm(data_train, label_train, data_test, opt)
%
% Inputs:
%   data_train      PxR training data for P samples and R features
%   label_train      Px1 training data classes
%   data_test       QxR test data
%   opt                struct with field:
%     .knn             Number of nearest neighbors to be considered
%     .norm            distance norm (default: 2)
%
% Output:
%   results         struct with field:
%     .knn             Number of nearest neighbors to be considered
%     .norm            distance norm (default: 2)
%%

    cosmo_isfield(opt,'knn',true);
    knn=opt.knn;

    if cosmo_isfield(opt,'norm')
        norm_=opt.norm;
    else
        norm_=2;
    end

    [ntrain, nfeatures]=size(data_train);
    [ntest, nfeatures_]=size(data_test);
    ntrain_=numel(label_train);

    if nfeatures~=nfeatures_ || ntrain_~=ntrain
        error('illegal input size');
    end

    if knn>ntrain
        error(['Cannot find nearest %d neighbors: only %d samples '...
                    'in training set'],...
                    knn, ntrain);
    end

    % allocate space for output
    all_predicted=zeros(ntest, knn);

    % classify each test sample
    for k=1:ntest
        % for each sample in the test set:
        % - compute its  distance to each sample in the train set.
        % - assign the class label of the feature that is nearest
        % >@@>
        delta=bsxfun(@minus, data_train, data_test(k,:));

        pow_distance=sum(abs(delta).^norm_,2);

        [unused, i]=sort(pow_distance);
        all_predicted(k, 1:knn)=i(1:knn);
        % <@@<
    end

    % determine which targets are predicted most often
    [winners,classes]=cosmo_winner_indices(label_train(all_predicted));
    predicted=classes(winners);
