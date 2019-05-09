function varargout = lc_fmriToolbox(varargin)
% 此代码用来对影像数据标准化
% LC_FMRITOOLBOX MATLAB code for lc_fmriToolbox.fig
%      LC_FMRITOOLBOX, by itself, creates a new LC_FMRITOOLBOX or raises the existing
%      singleton*.
%
%      H = LC_FMRITOOLBOX returns the handle to a new LC_FMRITOOLBOX or the handle to
%      the existing singleton*.
%
%      LC_FMRITOOLBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_FMRITOOLBOX.M with the given input arguments.
%
%      LC_FMRITOOLBOX('Property','Value',...) creates a new LC_FMRITOOLBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lc_fmriToolbox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lc_fmriToolbox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lc_fmriToolbox

% Last Modified by GUIDE v2.5 17-Apr-2019 19:46:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lc_fmriToolbox_OpeningFcn, ...
                   'gui_OutputFcn',  @lc_fmriToolbox_OutputFcn, ...
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


% --- Executes just before lc_fmriToolbox is made visible.
function lc_fmriToolbox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lc_fmriToolbox (see VARARGIN)
handles.opt.img_path=pwd;
handles.opt.img_path_name={};
handles.opt.mask_data=0;
handles.opt.how_stand='Z标准化';
handles.opt.save_fold=pwd;
% Choose default command line output for lc_fmriToolbox
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lc_fmriToolbox wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lc_fmriToolbox_OutputFcn(hObject, eventdata, handles) 
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
img_path=uigetdir('原始影像数据');
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

% --- Executes on selection change in how_stand.
function how_stand_Callback(hObject, eventdata, handles)
% hObject    handle to how_stand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opt_cell=get(handles.how_stand, 'String');
opt_value=get(handles.how_stand, 'Value');
% fprintf(opt_cell{opt_value});
handles.opt.how_extract=opt_cell{opt_value};
% Update handles structure
guidata(hObject, handles)
% how_stand
% Hints: contents = cellstr(get(hObject,'String')) returns how_stand contents as cell array
%        contents{get(hObject,'Value')} returns selected item from how_stand


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.opt
len_img = length(handles.opt.img_path_name);
for i=1:len_img
    fprintf('%d/%d\n',i,len_img)
    [img,h]=y_Read(handles.opt.img_path_name{i});
    
    if strcmp(handles.opt.how_stand,'Z标准化')
        if handles.opt.mask_data
         img_inmask=img.*handles.opt.mask_data;
        else
           img_inmask=img; 
        end
         mean_inmask=mean(img_inmask(:));
         mystd=std(img_inmask(:));
         zvalues=(img_inmask-mean_inmask)/mystd;
         zvalues(~handles.opt.mask_data)=0;
        %save
        [~,name]=fileparts(handles.opt.img_path_name{i});
        name=fullfile(handles.opt.save_folder,name);
        y_Write(zvalues,h,name) % to nii
        
    elseif strcmp(handles.opt.how_stand,'归一化([-1,1])')
        svalues=zeros(size(img));
        if handles.opt.mask_data
            svalues(handles.opt.mask_data)=mapminmax(img(handles.opt.mask_data), -1, 1);
        else
            svalues=mapminmax(img, -1, 1);
        end
        %save
        [~,name]=fileparts(handles.opt.img_path_name{i});
        name=fullfile(handles.opt.save_folder,name);
        y_Write(svalues,h,name) % to nii
        
    elseif strcmp(handles.opt.how_stand,'Fisher-Z transformation')
        fisherzvalue=0.5*log((1+img)./(1-img));
        if handles.opt.mask_data
            fisherzvalue(~handles.opt.mask_data)=0;
        end
        %save
        [~,name]=fileparts(handles.opt.img_path_name{i});
        name=fullfile(handles.opt.save_folder,name);
        y_Write(fisherzvalue,h,name) % to nii
        
    elseif strcmp(handles.opt.how_stand,'除均值化（除以均值）')
        if handles.opt.mask_data
            img_inmask=img.*handles.opt.mask_data;
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask(:));
        divmean_values=img_inmask/mean_inmask;
        divmean_values(~handles.opt.mask_data)=0;
        %save
        [~,name]=fileparts(handles.opt.img_path_name{i});
        name=fullfile(handles.opt.save_folder,name);
        y_Write(divmean_values,h,name) % to nii
        
    elseif strcmp(handles.opt.how_stand,'去均值化（减去均值）')
        if handles.opt.mask_data
            img_inmask=img.*handles.opt.mask_data;
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask(:));
        demean_values=img_inmask-mean_inmask;
        demean_values(~handles.opt.mask_data)=0;
        %save
        [~,name]=fileparts(handles.opt.img_path_name{i});
        name=fullfile(handles.opt.save_folder,name);
        y_Write(demean_values,h,name) % to nii
    else
        fprintf('设定的方法为%s,本程序没有添加此功能\n','handles.opt.how_extract')
        return 
    end
end
fprintf('All done!\n')
