% 用途： 对Logistic_Regression_ElasticNet_1D做置换检验
%% options
    opt.lambda=exp(-3:3);opt.alpha=0.5:0.1:1;%elastic net
        opt.K=5;opt.Initial_FeatureQuantity=50;opt.Max_FeatureQuantity=5000;opt.Step_FeatureQuantity=50;%uter opt.K fold.
    opt.P_threshold=0.01;% univariate feature filter.
    %     opt.learner='svm';opt.stepmethod='percentage';opt.step=10;% RFE.
    opt.percentage_consensus=0.2;%The most frequent voxels/features;range=(0,1];
    opt.weight=1;opt.viewperformance=1;opt.saveresults=1;
    opt.standard='scale';opt.min_scale=0;opt.max_scale=1;
    opt.permutation=0;

%%
hh=waitbar(0,'请等待 Outer Loop>>>>>>>>','Position',[50 50 280 60]);
set(hh, 'Color','c');
for n_p=1:20
    waitbar(n_p/20);
    label_perm=label(randperm(numel(label)));
    [ AUC{n_p}, Accuracy{n_p}, Sensitivity{n_p}, Specificity{n_p},Real_label{n_p},Decision{n_p}, B{n_p}] = ...
        Logistic_Regression_ElasticNet_1D(opt,data,label_perm);
end
close (hh)