function [outputArg1,outputArg2] = lc_repeated_two_way_anova()
% Purpose: this function is used to perform repeated measure of two way ANOVA.
%% Longitudinal Data  

%% 
% Load the sample data. 
load(fullfile(matlabroot,'examples','stats','longitudinalData.mat')); 

%%
% The matrix |Y| contains response data for 16 individuals. The response is
% the blood level of a drug measured at five time points (time = 0, 2, 4,
% 6, and 8). Each row of |Y| corresponds to an individual, and each column
% corresponds to a time point. The first eight subjects are female, and the
% second eight subjects are male. This is simulated data.

%% 
% Define a variable that stores gender information. 
Gender = ['F' 'F' 'F' 'F' 'F' 'F' 'F' 'F' 'M' 'M' 'M' 'M' 'M' 'M' 'M' 'M']';  

%% 
% Store the data in a proper table array format to do repeated measures
% analysis. 
t = table(Gender,Y(:,1),Y(:,2),Y(:,3),Y(:,4),Y(:,5),...
'VariableNames',{'Gender','t0','t2','t4','t6','t8'});  

t= t([1,2,9,10],[1,2,4]);
t.t4 = t.t4;
%% 
% Define the within-subjects variable. 
Time = [0 4]';  

%% 
% Fit a repeated measures model, where the blood levels are the responses
% and gender is the predictor variable. 
rm = fitrm(t,'t0-t4 ~ Gender','WithinDesign',Time);  
rm = fitrm(t,'t0-t4 ~ Gender');  

%% 
% Perform repeated measures analysis of variance. 
ranovatbl = ranova(rm);

%% NBS
design_matrix1 = [1 0 0 0 1 0 0 0;...
                 0 1 0 0 0 1 0 0;...
                 0 0 1 0 0 0 1 0;...
                 0 0 0 1 0 0 0 1]';
             
design_matrix2 = [-1 -1 -1 -1 1 1 1 1;...
                  -1 -1 1 1 -1 -1 1 1;...
                   1 1 -1 -1 -1 -1 1 1]';  
               
design_matrix = [ones(8,1), design_matrix1, design_matrix2];
% design_matrix = [ones(8,1),  design_matrix2];
contrast = [0 0 0 0 0 0 0 0 1];

perms = 100;
GLM.perms = perms;
GLM.X = design_matrix;
GLM.y = cat(1,t.t0,t.t4);
GLM.contrast = contrast;
GLM.test = 'ftest';
a=NBSglm(GLM);

end

