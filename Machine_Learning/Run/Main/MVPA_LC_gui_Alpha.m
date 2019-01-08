function MVPA_LC_gui_Alpha()
%% MVPA
% generate MVPA methods selection figure
anafig = figure('Name','MVPA',...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Resize', 'off', ...
    'Position',[450,200,200,300]); %X,Y then Width, Height
set(anafig, 'Color', ([128,0,0] ./255));
uipanel('Title','Choose MVPA Method',...
    'BackgroundColor','white',...
    'Units','Pixels',...
    'Position',[10 10 180 280]);

uicontrol('Style','PushButton','HorizontalAlignment','left','String','Classification_RFE',...
    'Position',[25,200,150,40],'Callback',@which_MVPA);
uicontrol('Style','PushButton','HorizontalAlignment','left','String','Regression_RFE',...
    'Position',[25,150,150,40],'Callback',@which_MVPA);
end

%%
function which_MVPA(method,~)
%% seting  options
%panel
figure;
yp = -20;xp=40;
uipanel('Title','Number of Fold','BackgroundColor','white','Units','Pixels','Position',[40+xp 390+yp 140 40]);
uipanel('Title','Initial feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 340+yp 140 40]);
uipanel('Title','Max feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 290+yp 140 40]);
uipanel('Title','Step of feature quantity','BackgroundColor','white','Units','Pixels','Position',[40+xp 240+yp 140 40]);
uipanel('Title','Threshold of P value','BackgroundColor','white','Units','Pixels','Position',[40+xp 190+yp 140 40]);
uipanel('Title','Kind of mechine learing','BackgroundColor','white','Units','Pixels','Position',[40+xp 140+yp 140 40]);
%
uipanel('Title','RFE stepmethod','BackgroundColor','white','Units','Pixels','Position',[220+xp 390+yp 140 40]);
uipanel('Title','RFE step','BackgroundColor','white','Units','Pixels','Position',[220+xp 340+yp 140 40]);
uipanel('Title','Percentage of consensus voxels in K fold','BackgroundColor','white','Units','Pixels','Position',[220+xp 290+yp 250 40]);
uipanel('Title',' Calculate feature weights','BackgroundColor','white','Units','Pixels','Position',[220+xp 240+yp 140 40]);
uipanel('Title','view performance','BackgroundColor','white','Units','Pixels','Position',[220+xp 190+yp 140 40]);
uipanel('Title','save results', 'BackgroundColor','white','Units','Pixels','Position',[220+xp 140+yp 140 40]);
uipanel('Title','Standardized data', 'BackgroundColor','white','Units','Pixels','Position',[40+xp 90+yp 140 40]);
if  strcmp(method.String,'Regression_RFE')
    uipanel('Title','Dependent variables for Regression','BackgroundColor','white','Units','Pixels','Position',[xp 30+yp 400 50]);%label
end
% control
u1 = uicontrol('Style','edit','HorizontalAlignment','left','String','5','Position',[80,390+yp,120,20]);
u2 = uicontrol('Style','edit','HorizontalAlignment','left','String','10','Position',[80,340+yp,120,20]);
u3 = uicontrol('Style','edit','HorizontalAlignment','left','String','5000','Position',[80,290+yp,120,20]);
u4 = uicontrol('Style','edit','HorizontalAlignment','left','String','50','Position',[80,240+yp,120,20]);
u5 = uicontrol('Style','edit','HorizontalAlignment','left','String','0.05','Position',[80,190+yp,120,20]);
u6 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'svm','logistic'},'Position',[80,140+yp,120,20]);
%
u7 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'percentage','fixed'},'Position',[260,390+yp,120,20]);
u8 = uicontrol('Style','edit','HorizontalAlignment','left','String','50','Position',[260,340+yp,120,20]);
u9 = uicontrol('Style','edit','HorizontalAlignment','left','String','0.8','Position',[260,290+yp,120,20]);
u10 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[260,240+yp,120,20]);
u11 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[260,190+yp,120,20]);
u12 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'0','1'},'Position',[260,140+yp,120,20]);
u13 = uicontrol('Style','popupmenu','HorizontalAlignment','left','String',{'no standard','scale','normalizing'},'Position',[80,90+yp,120,20]);
if  strcmp(method.String,'Regression_RFE')
    label=uicontrol('Style','edit','HorizontalAlignment','left','String','','Position',[xp 30+yp 400 30]);%label
end
%% Identify MVPA method
if strcmp(method.String,'Classification_RFE')
    disp('SVM_LC_Kfold_RFEandUnivariate_beta')
    uicontrol('Style','PushButton','BackgroundColor','[ 0.5 .5 .8]','HorizontalAlignment','center','String','Run MVPA',...
        'Position',[450,10,90,40],...
        'Callback',{@run_Classification,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13]});
elseif strcmp(method.String,'Regression_RFE')
    disp('SVMRegression_Kfold_RFE_beta')
    uicontrol('Style','PushButton','BackgroundColor','[ 0.5 .5 .8]','HorizontalAlignment','center','String','Run MVPA',...
        'Position',[450,10,90,40],...
        'Callback',{@run_Regression,[u1 u2 u3 u4 u5 u6 u7,u8,u9,u10,u11,u12,u13,label]});
end
end

%% Excute exact MVPA
function run_Classification(~,~,uis)
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
close all;
% set opt
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});opt.standard=strings{13}{values(13)};
SVM_LC_Kfold_RFEandUnivariate_beta(opt);%run classification
end

function run_Regression(~,~,uis)
strings = arrayfun(@(x) get(x,'String'),uis,'UniformOutput',false);
values = arrayfun(@(x) get(x,'Value'),uis);
close all;
% set opt and label
label=str2num(strings{14});
opt.K=str2double(strings{1});opt.Initial_FeatureQuantity=str2double(strings{2});opt.Max_FeatureQuantity=str2double(strings{3});opt.Step_FeatureQuantity=str2double(strings{4});%options for outer K fold.
opt.P_threshold=str2double(strings{5});%options for univariate feature filter, if P_threshold=1,then equal to no univariate filter.
opt.learner=strings{6}{values(6)};opt.stepmethod=strings{7}{values(7)};opt.step=str2double(strings{8});%options for RFE, refer to related codes.
opt.percentage_consensus=str2double(strings{9});%options for indentifying the most important voxels.range=(0,1];
%K fold中某个权重不为零的体素出现的概率，如percentage_consensus=0.8，K=5，则出现5*0.8=4次以上的体素才认为是consensus体素
opt.weight=str2double(strings{10}{values(10)});opt.viewperformance=str2double(strings{11}{values(11)});
opt.saveresults=str2double(strings{12}{values(12)});opt.standard=strings{13}{values(13)};
SVMRegression_Kfold_RFE_beta(label,opt);%run regression
end

% function run_PermutationTest
% end