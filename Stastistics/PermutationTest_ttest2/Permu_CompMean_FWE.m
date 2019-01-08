function varargout = Permu_CompMean_FWE(varargin)
% PERMU_COMPMEAN_FWE MATLAB code for Permu_CompMean_FWE.fig
%      PERMU_COMPMEAN_FWE, by itself, creates a new PERMU_COMPMEAN_FWE or raises the existing
%      singleton*.
%
%      H = PERMU_COMPMEAN_FWE returns the handle to a new PERMU_COMPMEAN_FWE or the handle to
%      the existing singleton*.
%
%      PERMU_COMPMEAN_FWE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PERMU_COMPMEAN_FWE.M with the given input arguments.
%
%      PERMU_COMPMEAN_FWE('Property','Value',...) creates a new PERMU_COMPMEAN_FWE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Permu_CompMean_FWE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Permu_CompMean_FWE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Permu_CompMean_FWE

% Last Modified by GUIDE v2.5 08-Feb-2018 16:13:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Permu_CompMean_FWE_OpeningFcn, ...
                   'gui_OutputFcn',  @Permu_CompMean_FWE_OutputFcn, ...
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


% --- Executes just before Permu_CompMean_FWE is made visible.
function Permu_CompMean_FWE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Permu_CompMean_FWE (see VARARGIN)

% Choose default command line output for Permu_CompMean_FWE
handles.opt={...
    'times','5000';....
    'tail','双尾';...
    'cov','不加协变量';...
    'correct','不校正';....
    'idt_colrow','每一行一个被试' };
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Permu_CompMean_FWE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Permu_CompMean_FWE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in tail.
function tail_Callback(hObject, eventdata, handles)
% hObject    handle to tail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tail contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tail
%        contents{get(hObject,'Value')} returns selected item from RFE_StepMethod
opt_cell=get(handles.tail, 'String');
opt_value=get(handles.tail, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'tail'));
handles.opt{loc_tmp,2}=opt_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tail_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cov.
function cov_Callback(hObject, eventdata, handles)
% hObject    handle to cov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cov contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cov
opt_cell=get(handles.cov, 'String');
opt_value=get(handles.cov, 'Value');
try
    opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'cov'));
handles.opt{loc_tmp,2}=opt_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function times_Callback(hObject, eventdata, handles)
% hObject    handle to times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of times as text
%        str2double(get(hObject,'String')) returns contents of times as a double
opt_cell=get(handles.times, 'String');
% opt_value=get(handles.times, 'Value');
opt_string=opt_cell;
loc_tmp=find(strcmp(handles.opt,'times'));
handles.opt{loc_tmp,2}=opt_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function times_CreateFcn(hObject, eventdata, handles)
% hObject    handle to times (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in correct.
function correct_Callback(hObject, eventdata, handles)
% hObject    handle to correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns correct contents as cell array
%        contents{get(hObject,'Value')} returns selected item from correct
opt_cell=get(handles.correct, 'String');
opt_value=get(handles.correct, 'Value');
try
   opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'correct'));
handles.opt{loc_tmp,2}=opt_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function correct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
% Run
 permu_compmean_fwe_lowlayer(opt{1,2},opt{3,2},opt{5,2})
% permu_t_test(times,alpha,tail,cov,correct)


% --- Executes on selection change in idt_colrow.
function idt_colrow_Callback(hObject, eventdata, handles)
% hObject    handle to idt_colrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns idt_colrow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from idt_colrow
opt_cell=get(handles.idt_colrow, 'String');
opt_value=get(handles.idt_colrow, 'Value');
try
   opt_string=opt_cell{opt_value};
catch
    opt_string=opt_cell;
end
loc_tmp=find(strcmp(handles.opt,'idt_colrow'));
handles.opt{loc_tmp,2}=opt_string;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function idt_colrow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idt_colrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
