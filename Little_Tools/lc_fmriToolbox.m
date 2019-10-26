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

% Last Modified by GUIDE v2.5 26-Oct-2019 23:00:23

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
handles.img_path=pwd;
handles.img_path_name={};
handles.mask_data=[];
handles.howStand='Zstandard';
handles.save_folder=pwd;
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
[file,path] = uigetfile('*.nii;*.img;*.nii.gz','Select source data',pwd,'MultiSelect','on');
try
    fun=@(a) fullfile(path,a);
    img_path_name = cellfun(fun,file, 'UniformOutput',false);
catch
    img_path_name = fullfile(path,file);
end
handles.opt.img_path_name=img_path_name;
% Update handles structure
guidata(hObject, handles)



% --- Executes on button press in mask.
function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mask_name,mask_path]=uigetfile('*.nii;*.img;*.nii.gz');
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

% --- Executes on selection change in howStand.
function howStand_Callback(hObject, eventdata, handles)
% hObject    handle to howStand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.howStand,'value')
% opt_cell=get(handles.howStand, 'String')
% opt_value=get(handles.howStand, 'Value');
% fprintf(opt_cell{opt_value});
handles.opt.how_stand=opt_cell{opt_value};
% Update handles structure
guidata(hObject, handles)
% howStand
% Hints: contents = cellstr(get(hObject,'String')) returns howStand contents as cell array
%        contents{get(hObject,'Value')} returns selected item from howStand


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.opt
if iscell(handles.opt.img_path_name)
    len_img = length(handles.opt.img_path_name);
else
    len_img = 1;
end
for i=1:len_img
    fprintf('%d/%d\n',i,len_img)
    %     [img,h]=y_Read(handles.opt.img_path_name{i});
    if iscell(handles.opt.img_path_name)
        [~,name,suffix]=fileparts(handles.opt.img_path_name{i});
        img_strut = load_nii(handles.opt.img_path_name{i});
    else
        [~,name,suffix]=fileparts(handles.opt.img_path_name);
        img_strut = load_nii(handles.opt.img_path_name);
    end
    img = img_strut.img;
    
    if strcmp(handles.opt.how_stand,'Zstandard')
        if  ~isempty(handles.opt.mask_data)
            disp('Have Mask');
            img_inmask=img(handles.opt.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        mystd=std(img_inmask);
        zvalues=(img_inmask-mean_inmask)./mystd;
        if  ~isempty(handles.opt.mask_data)  % make sure out mask data is zeros
            zvalues(~handles.opt.mask_data)=0;
        end
        %save
        name=fullfile(handles.opt.save_folder,strcat('z_', name, suffix));
        %         y_Write(zvalues,h,name)
        img_strut.img = zvalues;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.opt.how_stand,'scale to ([-1,1])')
        svalues=zeros(size(img));
        if  ~isempty(handles.opt.mask_data)
            % Note that: MATLAB have BUG of mapminmax, I fix the BUG
            % directly using the Algorithms (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            img_inmask = img(handles.opt.mask_data);
            xmax = max(img_inmask);
            xmin = min(img_inmask);
            ymin = -1;
            ymax = 1;
            svalues(handles.opt.mask_data) = (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            svalues(~ handles.opt.mask_data) = 0;  % make sure out mask data is zeros
        else
            xmax = max(img(:));
            xmin = min(img(:));
            ymin = -1;
            ymax = 1;
            svalues = (ymax-ymin)*(img-xmin)/(xmax-xmin) + ymin;
        end
        %save
        name=fullfile(handles.opt.save_folder,strcat('scale_', name, suffix));
        %         y_Write(svalues,h,name)
        img_strut.img = svalues;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.opt.how_stand,'Fisher-Z transformation')
        fisherzvalue=0.5*log((1+img)./(1-img));
        if  ~isempty(handles.opt.mask_data)  % make sure out mask data is zeros
            fisherzvalue(~handles.opt.mask_data)=0;
        end
        %save
        name=fullfile(handles.opt.save_folder,strcat('fisherz_', name, suffix));
        %         y_Write(fisherzvalue,h,name)
        img_strut.img = fisherzvalue;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.opt.how_stand,'divmean')
        if  ~isempty(handles.opt.mask_data)
            img_inmask=img(handles.opt.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        divmean_values=img./mean_inmask;
        if  ~isempty(handles.opt.mask_data)  % make sure out mask data is zeros
            divmean_values(~handles.opt.mask_data)=0;
        end
        %save
        name=fullfile(handles.opt.save_folder,strcat('divmean_', name, suffix));
        %         y_Write(divmean_values,h,name);
        img_strut.img = divmean_values;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.opt.how_stand,'demean')
        if  ~isempty(handles.opt.mask_data)
            img_inmask=img(handles.opt.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        demean_values=img-mean_inmask;
        if  ~isempty(handles.opt.mask_data)  % make sure out mask data is zeross
            demean_values(~handles.opt.mask_data)=0;
        end
        %save
        name=fullfile(handles.opt.save_folder,strcat('demean_', name,suffix));
        %         y_Write(demean_values,h,name)
        img_strut.img = demean_values;
        save_nii(img_strut,name);
        
    else
        fprintf('This standardization method: %s not supported\n',handles.opt.how_stand)
        return
    end
end
fprintf('All done!\n')
