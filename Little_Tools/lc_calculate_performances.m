function [accuracy,sensitivity,specificity,PPV,NPV]=lc_calculate_performances(outputs,targets)
% Calculate classification performances
% Inputs:
% 	outputs: predict labels
% 	targets: ground truth labels (0 or 1)
% Outputs:
% 	accuracy,sensitivity,specificity,PPV,NPV
%% -----------------------------------------------------------------
 % change ~1 to 0
outputs=outputs==1;
targets=targets==1; 

% to row array
outputs=reshape(outputs,length(outputs),1);  
targets=reshape(targets,length(targets),1);
TP=sum(targets.*outputs);
FN=sum(targets)-sum(targets.*outputs);
TN=sum((targets==0).*(outputs==0));
FP=sum(targets==0)-sum((targets==0).*(outputs==0));
accuracy =(TP+TN)/(TP + FN + TN + FP);
sensitivity =TP/(TP + FN);
specificity =TN/(TN + FP);
PPV=TP/(TP+FP);  % positive predictive
NPV=TN/(TN+FN);  % negative predictive value
end

