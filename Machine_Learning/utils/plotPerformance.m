function plotPerformance(Accuracy,Sensitivity,Specificity,AUC,...
    Initial_FeatureQuantity,Step_FeatureQuantity,Max_FeatureQuantity)
% plot performance
% refrence to IdentifyBestPerformance
% 
% 
% 
opt.color=[1 .5 0];
%%
    % Name_plot={'accuracy','sensitivity', 'specificity', 'PPV', 'NPV','AUC'};
    N_plot=length(Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity);
    figure;
    plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),mean(Accuracy(:,1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2,'Color',opt.color);title('Mean accuracy');
    figure;
    plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),mean(Sensitivity(:,1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2,'Color',opt.color);title('Mean sensitivity');
    figure;
    plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),mean(Specificity(:,1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2,'Color',opt.color);title('Mean specificity');
    figure;
    plot((Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity),mean(AUC(:,1:1:N_plot)),...
        '-','markersize',5,'LineWidth',2,'Color',opt.color); title('Mean AUC');
    % error bar of Accuracy
    figure;
    %      errorbar(mean(Accuracy),std(Accuracy));
    dy=std(Accuracy);
    MeanAccurcay=mean(Accuracy);
    loc_maxAccuracy=find(mean(Accuracy)==max(mean(Accuracy)));
    loc_maxAccuracy= loc_maxAccuracy(1);
    maxAccuracy= MeanAccurcay(loc_maxAccuracy);
    axis_x=Initial_FeatureQuantity:Step_FeatureQuantity:Max_FeatureQuantity;
    %      axis_x=opt.Initial_FeatureQuantity:opt.Step_FeatureQuantity:opt.Max_FeatureQuantity;
    fig_fill=fill([axis_x,fliplr(axis_x)],[MeanAccurcay-dy,fliplr(MeanAccurcay+dy)],[0.5 0.2 0.2]);%ÃÓ≥‰CI
    fig_fill.EdgeColor=[0.8 0.2 0.2];fig_fill.FaceColor='r';fig_fill.LineStyle='none';
    fig_fill.FaceAlpha=0.3;
    hold on;
    line([axis_x(loc_maxAccuracy),axis_x(loc_maxAccuracy)],[maxAccuracy-dy(loc_maxAccuracy),maxAccuracy+dy(loc_maxAccuracy)],'Color',[1 0 0],'LineWidth',2);
    plot(axis_x(loc_maxAccuracy),maxAccuracy,'o','MarkerSize',8,'Color',[1 0 0],'LineWidth',2)
    plot(axis_x,MeanAccurcay,'-','MarkerSize',8,'Color',[0.6 0 0],'LineWidth',1)
    title(Accuracy)
end