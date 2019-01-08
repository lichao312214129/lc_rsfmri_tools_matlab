%% Main panel
function MVPA_LC_gui_Beta()
% currentFolder = pwd;
% addpath(genpath(currentFolder))
% generate MVPA methods selection figure
anafig = figure('Name','MVPA',...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Resize', 'off', ...
    'Position',[450,200,200,300]); %X,Y then Width, Height
set(anafig, 'Color', ([50,200,50] ./255));
uipanel('Title','Choose MVPA Method',...
    'BackgroundColor','white',...
    'Units','Pixels',...
    'Position',[10 10 180 280]);

uicontrol('Style','PushButton','HorizontalAlignment','left','String','Classification_RFE',...
    'Position',[25,200,150,40],'Callback',@which_MVPA);
uicontrol('Style','PushButton','HorizontalAlignment','left','String','Regression_RFE',...
    'Position',[25,150,150,40],'Callback',@which_MVPA);
uicontrol('Style','PushButton','HorizontalAlignment','left','String','Logistic_ElasticNet',...
    'Position',[25,100,150,40],'Callback',@which_MVPA);
uicontrol('Style','PushButton','HorizontalAlignment','left','String','Permutation Test',...
    'Position',[25,50,150,40],'Callback',@which_MVPA);
end

%% Options panel and identify MVPA method
function which_MVPA(method,~)
%% seting  options and identify MVPA method
%% panel
global f;
f = figure('Name','MVPA',...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Resize', 'off', ...
    'Position',[100,200,600,500]); %X,Y then Width, Height
set(f, 'Color', ([50,200,50] ./255));
% f=figure('Name','options of MVPA');
yp = 50;xp=0;
%colum 1
uipanel('Title','Number of Fold','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[40+xp 390+yp 140 40]);
uipanel('Title','Initial feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 340+yp 140 40]);
uipanel('Title','Max feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 290+yp 140 40]);
uipanel('Title','Step of feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 240+yp 140 40]);
uipanel('Title','Threshold of P value','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[40+xp 190+yp 140 40]);
uipanel('Title','Kind of mechine learing','BackgroundColor','white','Units','Pixels','Position',[40+xp 140+yp 140 40]);
% colum2
uipanel('Title','RFE stepmethod','BackgroundColor','white','Units','Pixels','Position',[220+xp 390+yp 140 40]);
uipanel('Title','RFE step','BackgroundColor','white','Units','Pixels','Position',[220+xp 340+yp 140 40]);
uipanel('Title','Feature Frequence','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[220+xp 290+yp 140 40]);
uipanel('Title',' Calculate feature weights','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[220+xp 240+yp 140 40]);
uipanel('Title','view performance','BackgroundColor','white','Units','Pixels','Position',[220+xp 190+yp 140 40]);
uipanel('Title','save results', 'BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[220+xp 140+yp 140 40]);
%colum3
uipanel('Title','Standardized data', 'BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[400+xp 390+yp 140 40]);
if  strcmp(method.String,'Logistic_ElasticNet')
    uipanel('Title','alpha','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[400+xp 340+yp 140 40]);%alpha
    uipanel('Title','lambda','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[400+xp 290+yp 140 40]);%lambda
end
if  strcmp(method.String,'Permutation Test')
    uipanel('Title','Number of permutation','BackgroundColor','white','Units','Pixels','Position',[400+xp 340+yp 140 40]);%permutation
    uipanel('Title','Number of paraworks','BackgroundColor','white','Units','Pixels','Position',[400+xp 290+yp 140 40]);%permutation
    uipanel('Title','Statistics: AUC, Accuracy, Sensitivity, Specificity, MAE, R, CombinedPerformance','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[xp+10 yp-30 420 50]);%statistics
    uipanel('Title','Which MVPA','BackgroundColor','white','Units','Pixels','Position',[400+xp 235+yp 140 40]);%which MVPA
end
% floor
if  strcmp(method.String,'Regression_RFE')
    uipanel('Title','Dependent variables for Regression','BackgroundColor',[1 0.5 0.5],'Units','Pixels','Position',[xp 35+yp 400 50]);%label
end
%% control
%colum1
u1 = uicontrol('Style','edit','HorizontalAlignment','left','String','5','Position',[40+xp,395+yp,120,20]);
u2 = uicontrol('Style','edit','HorizontalAlignment','left','String','10','Position',[40+xp,345+yp,120,20]);
u3 = uicontrol('Style','edit','HorizontalAlignment','left','String','5000','Position',[40+xp,295+yp,120,20]);
u4 = uicontrol('Style','edit','HorizontalAlignment','left','String','50','Position',[40+xp,245+yp,120,20]);
u5 = uicontrol('Style','edit','HorizontalAlignment','left','String','0.05','Position',[40+xp,195+yp,120,20]);
u6 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'svm','logistic'},'Position',[40+xp,145+yp,120,20]);
% colum2
u7 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'percentage','fixed'},'Position',[220+xp,395+yp,120,20]);
u8 = uicontrol('Style','edit','HorizontalAlignment','left','String','10','Position',[220+xp,345+yp,120,20]);
u9 = uicontrol('Style','edit','HorizontalAlignment','left','String','0.8','Position',[220+xp,295+yp,120,20]);
u10 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[220+xp,245+yp,120,20]);
u11 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[220+xp,195+yp,120,20]);
u12 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[220+xp,145+yp,120,20]);
%colum3
u13 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'no standard','scale','normalizing'},'Position',[400+xp 395+yp,120,20]);
if  strcmp(method.String,'Logistic_ElasticNet')
    alpha=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[400+xp 345+yp,120,20]);
    lambda=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[400+xp 295+yp 120 20]);
end
if  strcmp(method.String,'Permutation Test')
    nperm=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[400+xp 345+yp,120,20]);
    paraworks=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[400+xp 295+yp 120 20]);
    statistics=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[xp+10 yp-30 420 30]);
    MVPA=uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'Classification_RFE','Regression_RFE','Logistic_ElasticNet'},'Position',[400+xp 240+yp 120 20]);
    save('MVPA.mat','MVPA')
end
%floor
if  strcmp(method.String,'Regression_RFE')
    label=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[xp 35+yp 400 30]);%label
end
%% Identify MVPA method
if strcmp(method.String,'Classification_RFE')
    disp('SVM_LC_Kfold_RFEandUnivariate_beta')
    uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
        'Position',[490,10,90,40],...
        'Callback',{@run_Classification,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13]});
elseif strcmp(method.String,'Regression_RFE')
    disp('SVMRegression_Kfold_RFE_beta')
    uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
        'Position',[490,10,90,40],...
        'Callback',{@run_Regression,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13,label]});
elseif strcmp(method.String,'Logistic_ElasticNet')
    disp('Classification_ElasticNet')
    uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run',...
        'Position',[490,10,90,40],...
        'Callback',{@run_Logistic_ElasticNet,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13,alpha,lambda]});
elseif strcmp(method.String,'Permutation Test')
    disp('Permutation Test')
    uicontrol('Style','PushButton','BackgroundColor','[ 1 .3 .3]','HorizontalAlignment','center','String','Run Permutation',...
        'Position',[490,10,90,40],...
        'Callback',{@run_PermutationTest,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13,nperm,paraworks,statistics,MVPA]});
end
end


%% Excute exact MVPA methods
function run_Classification(~,~,uis)
global f
f.Visible = 'off';
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
% set opt
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});opt.standard=strings{13}{values(13)};
opt.permutation=0;
SVM_LC_Kfold_RFEandUnivariate_beta(opt);%run classification
global f
f.Visible = 'on';
end

function run_Regression(~,~,uis)
global f
f.Visible = 'off';
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
% set opt and label
label=str2num(strings{14});
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});opt.standard=strings{13}{values(13)};
opt.permutation=0;
SVMRegression_Kfold_RFE_beta(label,opt);%run regression
global f
f.Visible = 'on';
end

function run_Logistic_ElasticNet(~,~,uis)
global f
f.Visible = 'off';
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
% set opt
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});
opt.standard=strings{13}{values(13)};opt.alpha=str2num(strings{14});opt.lambda=str2num(strings{15});
opt.permutation=0;
Logistic_Regression_ElasticNet(opt);%run Logistic_Regression_ElasticNet
global f
f.Visible = 'on';
end

function run_PermutationTest(~,~,uis)
global f
f.Visible = 'off';
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
% set opt
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});opt.standard=strings{13}{values(13)};
opt.nperm=str2double(strings{14});opt.paraworks=str2double(strings{15});opt.permutation=1;
statistics=str2num(strings{16});opt.MVPA=strings{17}{values(17)};
%Permutation
[AUC_All, Accuracy_All, Sensitivity_All, Specificity_All,p_AUC,p_Accuracy, p_Sensitivity, p_Specificity,...
    MAE_All,R_All,CombinedPerformance_All,p_MAE, p_R, p_CombinedPerformance]=...
    Permutation_MVPA(statistics(1),statistics(2),statistics(3),statistics(4),...
    statistics(5),statistics(6),statistics(7),opt);%run permutation
%save results
Time=datestr(now,30);
outdir = uigetdir({},'Path of results');
save([outdir filesep [Time,'Results_Permutation.mat']],...
    'AUC_All', 'Accuracy_All', 'Sensitivity_All', 'Specificity_All',...
    'p_AUC','p_Accuracy', 'p_Sensitivity', 'p_Specificity',...
    'MAE_All,R_All','CombinedPerformance_All','p_MAE', 'p_R', 'p_CombinedPerformance');

global f
f.Visible = 'on';
end