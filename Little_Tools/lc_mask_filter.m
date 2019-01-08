function varargout = lc_mask_filter(varargin)
% LC_MASK_FILTER MATLAB code for lc_mask_filter.fig
%      LC_MASK_FILTER, by itself, creates a new LC_MASK_FILTER or raises the existing
%      singleton*.
%
%      H = LC_MASK_FILTER returns the handle to a new LC_MASK_FILTER or the handle to
%      the existing singleton*.
%
%      LC_MASK_FILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_MASK_FILTER.M with the given input arguments.
%
%      LC_MASK_FILTER('Property','Value',...) creates a new LC_MASK_FILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lc_mask_filter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lc_mask_filter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lc_mask_filter

% Last Modified by GUIDE v2.5 15-Dec-2018 23:01:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lc_mask_filter_OpeningFcn, ...
                   'gui_OutputFcn',  @lc_mask_filter_OutputFcn, ...
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


% --- Executes just before lc_mask_filter is made visible.
function lc_mask_filter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lc_mask_filter (see VARARGIN)
handles.opt={...
    'img_path','D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\Data\test';...
    'img_path_name',{};...
    'mask_data',[];...
    'how_extract','keep_mask_in';...
    'save_folder','D:\WorkStation_2018\WorkStation_2018_11_machineLearning_Psychosi_ALFF\Data'...
            };
% Choose default command line output for lc_mask_filter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lc_mask_filter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lc_mask_filter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in image.
function image_Callback(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img_path=uigetdir('影像文件夹');
img_s=dir(img_path);
img_name={img_s.name};
img_name=img_name(3:end)';
fun=@(a) fullfile(img_path,a);
img_path_name=cellfun(fun,img_name, 'UniformOutput',false);

handles.opt.img_path_name=img_path_name;
% Update handles structure
guidata(hObject, handles)



% --- Executes on button press in mask.
function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mask_name,mask_path]=uigetfile('*.nii;*.img');
handles.opt.mask_data=y_Read(fullfile(mask_path,mask_name));
% 不等于0的为mask
handles.opt.mask_data=handles.opt.mask_data~=0;
% Update handles structure
guidata(hObject, handles)

% --- Executes on button press in save_folder.
function save_folder_Callback(hObject, eventdata, handles)
% hObject    handle to save_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_folder=uigetdir('save_folder');
handles.opt.save_folder=save_folder;
% Update handles structure
guidata(hObject, handles)

% --- Executes on selection change in how_extract.
function how_extract_Callback(hObject, eventdata, handles)
% hObject    handle to how_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opt_cell=get(handles.how_extract, 'String');
opt_value=get(handles.how_extract, 'Value');
% fprintf(opt_cell{opt_value});
handles.opt.how_extract=opt_cell{opt_value};
% Update handles structure
guidata(hObject, handles)
% how_extract
% Hints: contents = cellstr(get(hObject,'String')) returns how_extract contents as cell array
%        contents{get(hObject,'Value')} returns selected item from how_extract


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.opt
for i=1:length(handles.opt.img_path_name)
    fprintf('%d/%d\n',i,length(handles.opt.img_path_name))
    
    % mask filter
    [img,h]=y_Read(handles.opt.img_path_name{i});
    
    if strcmp(handles.opt.how_extract,'保留mask内的值')
        img_filter=img.*handles.opt.mask_data;
        
    elseif strcmp(handles.opt.how_extract,'排除mask内的值')
        img_filter=img.*handles.opt.mask_data==0;
        
    elseif strcmp(handles.opt.how_extract,'提取mask内的均值')
        img_filter=img.*handles.opt.mask_data;
        img_filter=mean(img_filter(:));
        
    else
        fprintf('设定的方法为%s,本程序没有添加此功能\n','handles.opt.how_extract')
        return 
    end
    %save
    [~,name]=fileparts(handles.opt.img_path_name{i});
    name=fullfile(handles.opt.save_folder,name);
    y_Write(img_filter,h,name)
end
fprintf('All done!\n')
