function varargout = MVPA_Regression_GUI(varargin)
% MVPA_REGRESSION_GUI MATLAB code for MVPA_Regression_GUI.fig
%      MVPA_REGRESSION_GUI, by itself, creates a new MVPA_REGRESSION_GUI or raises the existing
%      singleton*.
%
%      H = MVPA_REGRESSION_GUI returns the handle to a new MVPA_REGRESSION_GUI or the handle to
%      the existing singleton*.
%
%      MVPA_REGRESSION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVPA_REGRESSION_GUI.M with the given input arguments.
%
%      MVPA_REGRESSION_GUI('Property','Value',...) creates a new MVPA_REGRESSION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MVPA_Regression_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MVPA_Regression_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MVPA_Regression_GUI

% Last Modified by GUIDE v2.5 03-Nov-2017 19:37:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MVPA_Regression_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @MVPA_Regression_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MVPA_Regression_GUI is made visible.
function MVPA_Regression_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MVPA_Regression_GUI (see VARARGIN)

% Choose default command line output for MVPA_Regression_GUI
handles.opt={...
    'num_fold','10';....
    'num_initialfeature','10';...
    'num_maxfeature','5000';...
    'num_stepfeature','10';....
    'thred_p','0.05';....
    'machin_name','svm';...
    'rfe_stepmethods','percentage';...
    'rfe_step','10';...
    'freq_feature','0.6';...
    'if_calcweight','0';...
    'if_viewperf','1';...
    'if_saveresults','0';...
    'standardization','no standard';...
    'dependent variables',''};
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MVPA_Regression_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MVPA_Regression_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% save varargout


% --- Executes on selection change in RFE_StepMethod.
function RFE_StepMethod_Callback(hObject, eventdata, handles)
% hObject    handle to RFE_StepMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RFE_StepMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFE_StepMethod
opt_cell=get(handles.RFE_StepMethod, 'String');
opt_value=get(handles.RFE_StepMethod, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'rfe_stepmethods'));
handles.opt{loc_tmp,2}=opt_string;
% Update handles structure
guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function RFE_StepMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RFE_StepMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RFE_Step.
function RFE_Step_Callback(hObject, eventdata, handles)
% hObject    handle to RFE_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RFE_Step contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFE_Step
opt_cell=get(handles.RFE_Step, 'String');
opt_value=get(handles.RFE_Step, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'rfe_step'));
handles.opt{loc_tmp,2}=opt_string;
% Update handles structure
guidata(hObject, handles)




% --- Executes during object creation, after setting all properties.
function RFE_Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RFE_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thred_p_Callback(hObject, ~, handles)
% hObject    handle to thred_p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thred_p as text
%        str2double(get(hObject,'String')) returns contents of thred_p as a double
opt_cell=get(handles.thred_p,'String');
opt_value=get(handles.thred_p, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'thred_p'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function thred_p_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thred_p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in standardization.
function standardization_Callback(hObject, eventdata, handles)
% hObject    handle to standardization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns standardization contents as cell array
%        contents{get(hObject,'Value')} returns selected item from standardization
clear opt_cell opt_value;
opt_cell=get(handles.standardization, 'String');
opt_value=get(handles.standardization, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'standardization'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function standardization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to standardization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in machin_name.
function machin_name_Callback(hObject, eventdata, handles)
% hObject    handle to machin_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns machin_name contents as cell array
%        contents{get(hObject,'Value')} returns selected item from machin_name
opt_cell=get(handles.machin_name, 'String');
opt_value=get(handles.machin_name, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'machin_name'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% handles.machin_name=opt_cell{opt_value}
% opt_string=opt_cell{opt_value}
% handles.machin_name=opt_string
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function machin_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to machin_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_fold_Callback(hObject, eventdata, handles)
% hObject    handle to num_fold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_fold as text
%        str2double(get(hObject,'String')) returns contents of num_fold as a double
opt_cell=get(handles.num_fold, 'String');
opt_value=get(handles.num_fold, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'num_fold'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function num_fold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_fold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_initialfeature_Callback(hObject, eventdata, handles)
% hObject    handle to num_initialfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_initialfeature as text
%        str2double(get(hObject,'String')) returns contents of num_initialfeature as a double
opt_cell=get(handles.num_initialfeature, 'String');
opt_value=get(handles.num_initialfeature, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'num_initialfeature'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function num_initialfeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_initialfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_maxfeature_Callback(hObject, eventdata, handles)
% hObject    handle to num_maxfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_maxfeature as text
%        str2double(get(hObject,'String')) returns contents of num_maxfeature as a double
opt_cell=get(handles.num_maxfeature, 'String');
opt_value=get(handles.num_maxfeature, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'num_maxfeature'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function num_maxfeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_maxfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_stepfeature_Callback(hObject, eventdata, handles)
% hObject    handle to num_stepfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_stepfeature as text
%        str2double(get(hObject,'String')) returns contents of num_stepfeature as a double
opt_cell=get(handles.num_stepfeature, 'String');
opt_value=get(handles.num_stepfeature, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'num_stepfeature'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function num_stepfeature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_stepfeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in if_saveresults.
function if_saveresults_Callback(hObject, eventdata, handles)
% hObject    handle to if_saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns if_saveresults contents as cell array
%        contents{get(hObject,'Value')} returns selected item from if_saveresults
opt_cell=get(handles.if_saveresults, 'String');
opt_value=get(handles.if_saveresults, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'if_saveresults'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function if_saveresults_CreateFcn(hObject, eventdata, handles)
% hObject    handle to if_saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in if_viewperf.
function if_viewperf_Callback(hObject, eventdata, handles)
% hObject    handle to if_viewperf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns if_viewperf contents as cell array
%        contents{get(hObject,'Value')} returns selected item from if_viewperf
clear opt_cell opt_value
opt_cell=get(handles.if_viewperf, 'String');
opt_value=get(handles.if_viewperf, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'if_viewperf'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function if_viewperf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to if_viewperf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in if_calcweight.
function if_calcweight_Callback(hObject, eventdata, handles)
% hObject    handle to if_calcweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns if_calcweight contents as cell array
%        contents{get(hObject,'Value')} returns selected item from if_calcweight
opt_cell=get(handles. if_calcweight, 'String');
opt_value=get(handles.if_calcweight, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'if_calcweight'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function if_calcweight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to if_calcweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freq_feature_Callback(hObject, eventdata, handles)
% hObject    handle to freq_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_feature as text
%        str2double(get(hObject,'String')) returns contents of freq_feature as a double
% opt_cell=get(handles.freq_feature, 'String')
% opt_value=get(handles.freq_feature, 'Value')
% try
%     opt_string=opt_cell{opt_value};
% catch
%     opt_string=opt_cell;
% end
% handles.freq_feature=opt_string;
% % Update handles structure
% guidata(hObject, handles)
opt_cell=get(handles.freq_feature, 'String');
opt_value=get(handles.freq_feature, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'freq_feature'));
handles.opt{loc_tmp,2}=opt_string;
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function freq_feature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_opt.
function save_opt_Callback(hObject, eventdata, handles)
% hObject    handle to save_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% OPT=handles.opt;%cell
Time=datestr(now,30);
path_outdir_tmp = uigetdir({},'Path of Results');
mkdir([path_outdir_tmp filesep 'OPT_MVPA_Classification_GUI_',Time]);
path_outdir=[path_outdir_tmp filesep 'OPT_MVPA_Classification_GUI_',Time];
OPT=handles.opt;
savefig([path_outdir filesep ['OPT_',Time,'.fig']]);
save([path_outdir filesep ['OPT_',Time,'.mat']],'OPT');

% --- Executes on button press in load_opt.
function load_opt_Callback(hObject, eventdata, handles)
% hObject    handle to load_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name,path_source1,~]= uigetfile( ...
    {'*.mat;','All Image Files';...
    '*.*','All Files' },...
    '请选择mask（单选）', ...
    'MultiSelect', 'off');
OPT=load([path_source1,char(file_name)]);
%updata OPT
handles.opt=OPT.OPT;
guidata(hObject, handles);
%updata fig
close MVPA_Classification_GUI
name_fig=[file_name(1:length(file_name)-4),'.fig'];
open([path_source1,name_fig])

% --------------------------------------------------------------------
function dependent_variables_Callback(hObject, eventdata, handles)
% hObject    handle to dependent_variables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dependent_variables as text
%        str2double(get(hObject,'String')) returns contents of dependent_variables as a double
opt_cell=get(handles.dependent_variables, 'String');
opt_value=get(handles.dependent_variables, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
%
if strcmp(opt_string,'Dependent varaibles for regression: load')
    [file_name1,path_source1,~] = uigetfile({'*.xlsx;*.xls;*.txt','All Image Files';...
        '*.*','All Files'},'MultiSelect','on','select dependent variables');
    try
        label=xlsread(fullfile(path_source1,file_name1));
    catch
        label=load((fullfile(path_source1,file_name1)));
    end
end
label=reshape(label,1,numel(label));
set(handles.dependent_variables,'Visible','off');
set(handles.disp_dep_var1,'Visible','on');
set(handles.disp_dep_var1,'String',num2str(label));
msgbox (['the number of dependent variable is ',num2str(numel(label))])
%
loc_tmp=find(strcmp(handles.opt,'dependent variables'));
handles.opt{loc_tmp,2}=label;%把y赋值给handles.opt{}
% handles.opt
% Update handles structure
guidata(hObject, handles)

% --- Executes on button press in Run_Classification.
function [ MAE_best,R_best,CombinedPerformance_best,Predict_best]=...
    Run_Classification_Callback(hObject, eventdata, handles)
% hObject    handle to Run_Classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% name={
%     'num_fold'
%     'num_initialfeature'
%     'num_maxfeature'
%     'num_stepfeature'
%     'thred_p'
%     'machin_name'
%     'rfe_stepmethods'
%     'rfe_step'
%     'freq_feature'
%     'if_calcweight'
%     'if_viewperf'
%     'if_saveresults'
%     'standardization'
%     'dependent variables','Dependent varaibles for regression: load'};
set(handles.dependent_variables,'Visible','on');
%options
opt=handles.opt;
% save('hopt.mat','opt');
% transform string in OPT to double
if iscell(opt)
    for i=1:length(opt())
        if ~isnan(str2double(opt{i,2}))
            opt{i,2}=str2double(opt{i,2});
        end
    end
else
    warning('name is NOT a cell');
end
handles.opt=opt;
OPT.K=handles.opt{1,2};
OPT.Initial_FeatureQuantity=handles.opt{2,2};
OPT.Max_FeatureQuantity=handles.opt{3,2};
OPT.Step_FeatureQuantity=handles.opt{4,2};%uter opt.K fold.
OPT.P_threshold=handles.opt{5,2};% univariate feature filter.
OPT.learner=handles.opt{6,2};
OPT.stepmethod=handles.opt{7,2};
OPT.step=handles.opt{8,2};
OPT.percentage_consensus=handles.opt{9,2};%The most frequent voxels/features;range=(0,1];
OPT.weight=handles.opt{10,2};
OPT.viewperformance=handles.opt{11,2};
OPT.saveresults=handles.opt{12,2};
OPT.standard=handles.opt{13,2};
label=handles.opt{14,2};
%fixed options
OPT.min_scale=0;
OPT.max_scale=1;
OPT.permutation=0;
%% run
[ MAE_best,R_best,CombinedPerformance_best,Predict_best] =...
    SVMRegression_Kfold_RFE_beta(OPT,label);



function disp_dep_var1_Callback(hObject, eventdata, handles)
% hObject    handle to disp_dep_var1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of disp_dep_var1 as text
%        str2double(get(hObject,'String')) returns contents of disp_dep_var1 as a double
% --- Executes during object creation, after setting all properties.
