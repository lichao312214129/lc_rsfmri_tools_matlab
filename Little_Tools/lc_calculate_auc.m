function auc = lc_calculate_auc(targets,outputs)  
% Calculate AUC value
% Inputs:
% 	outputs: predict values (decisions)
% 	targets: ground truth labels (0 or 1)
% Outputs:
% 	AUC value
%% -----------------------------------------------------------------
% to row array
targets=reshape(targets,length(targets),1);
outputs=reshape(outputs,length(outputs),1);
% change ~1 to 0
targets=targets==1;
[~,I]=sort(outputs);  
M=0;
N=0;  
for i=1:length(outputs)  
    if(targets(i)==1)  
        M=M+1;  
    else  
        N=N+1;  
    end  
end  
sigma=0;  
for i=M+N:-1:1  
    if(targets(I(i))==1)  
        sigma=sigma+i;  
    end  
end  
auc = (sigma-(M+1)*M/2)/(M*N); 
end

