function varargout = lc_DataStandardization(varargin)
% 此代码用来对影像数据标准化
% LC_DATASTANDARDIZATION MATLAB code for lc_DataStandardization.fig
%      LC_DATASTANDARDIZATION, by itself, creates a new LC_DATASTANDARDIZATION or raises the existing
%      singleton*.
%
%      H = LC_DATASTANDARDIZATION returns the handle to a new LC_DATASTANDARDIZATION or the handle to
%      the existing singleton*.
%
%      LC_DATASTANDARDIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_DATASTANDARDIZATION.M with the given input arguments.
%
%      LC_DATASTANDARDIZATION('Property','Value',...) creates a new LC_DATASTANDARDIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lc_DataStandardization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lc_DataStandardization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lc_DataStandardization

% Last Modified by GUIDE v2.5 27-Oct-2019 21:27:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @lc_DataStandardization_OpeningFcn, ...
    'gui_OutputFcn',  @lc_DataStandardization_OutputFcn, ...
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


% --- Executes just before lc_DataStandardization is made visible.
function lc_DataStandardization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lc_DataStandardization (see VARARGIN)
handles.img_path=pwd;
handles.img_path_name={};
handles.mask_data=[];
handles.save_folder=pwd;
handles.howStand = 'Zstandard';
% Choose default command line output for lc_DataStandardization
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lc_DataStandardization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lc_DataStandardization_OutputFcn(hObject, eventdata, handles)
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
handles.img_path_name=img_path_name;
set(handles.sourcefile,'string',img_path_name);
if iscell(img_path_name)
    ns = numel(img_path_name);
else
    ns = 1;
end
set(handles.image,'string',cat(2,'Selected Source Data (',num2str(ns),')'));
% Update handles structure
guidata(hObject, handles)



% --- Executes on button press in mask.
function mask_Callback(hObject, eventdata, handles)
% hObject    handle to mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mask_name,mask_path]=uigetfile('*.nii;*.img;*.nii.gz');
if mask_path
    handles.mask_data=y_Read(fullfile(mask_path,mask_name));
    set(handles.maskfile,'string',fullfile(mask_path,mask_name));
    handles.mask_data=handles.mask_data~=0;
end
% Update handles structure
guidata(hObject, handles)

% --- Executes on button press in save_folder.
function save_folder_Callback(hObject, eventdata, handles)
% hObject    handle to save_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_folder=uigetdir('save_folder');
handles.save_folder=save_folder;
set(handles.outdirfile,'string',save_folder);
% Update handles structure
guidata(hObject, handles)

% --- Executes on selection change in how_stand.
function how_stand_Callback(hObject, eventdata, handles)

% hObject    handle to how_stand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = get(handles.how_stand,'string');
v = get(handles.how_stand,'value');
handles.howStand = s{v};
% opt_cell=get(handles.how_stand, 'String')
% opt_value=get(handles.how_stand, 'Value');
% fprintf(opt_cell{opt_value});
% handles.how_stand=opt_cell{opt_value};
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
if iscell(handles.img_path_name)
    len_img = length(handles.img_path_name);
else
    len_img = 1;
end
for i=1:len_img
    fprintf('%d/%d\n',i,len_img)
    %     [img,h]=y_Read(handles.img_path_name{i});
    if iscell(handles.img_path_name)
        [~,name,suffix]=fileparts(handles.img_path_name{i});
        img_strut = load_nii(handles.img_path_name{i});
    else
        [~,name,suffix]=fileparts(handles.img_path_name);
        img_strut = load_nii(handles.img_path_name);
    end
    img = double(img_strut.img);
    
    if strcmp(handles.howStand,'Zstandard')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask(:));  % mask sure result is an 1 d arry
        mystd=std(img_inmask(:));
        zvalues=(img_inmask-mean_inmask)./mystd;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            zvalues(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('z_', name, suffix));
        %         y_Write(zvalues,h,name)
        img_strut.img = zvalues;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.howStand,'scale to ([-1,1])')
        svalues=zeros(size(img));
        if  ~isempty(handles.mask_data)
            % Note that: MATLAB have BUG of mapminmax, I fix the BUG
            % directly using the Algorithms (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            img_inmask = img(handles.mask_data);
            xmax = max(img_inmask);
            xmin = min(img_inmask);
            ymin = -1;
            ymax = 1;
            svalues(handles.mask_data) = (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            svalues(~ handles.mask_data) = 0;  % make sure out mask data is zeros
        else
            xmax = max(img(:));
            xmin = min(img(:));
            ymin = -1;
            ymax = 1;
            svalues = (ymax-ymin)*(img-xmin)/(xmax-xmin) + ymin;
        end
        %save
        name=fullfile(handles.save_folder,strcat('scale_', name, suffix));
        %         y_Write(svalues,h,name)
        img_strut.img = svalues;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.howStand,'Fisher-Z transformation')
        fisherzvalue=0.5*log((1+img)./(1-img));
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            fisherzvalue(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('fisherz_', name, suffix));
        %         y_Write(fisherzvalue,h,name)
        img_strut.img = fisherzvalue;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.howStand,'divmean')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask(:));
        divmean_values=img./mean_inmask;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            divmean_values(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('divmean_', name, suffix));
        %         y_Write(divmean_values,h,name);
        img_strut.img = divmean_values;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.howStand,'demean')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask(:));
        demean_values=img-mean_inmask;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeross
            demean_values(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('demean_', name,suffix));
        %         y_Write(demean_values,h,name)
        img_strut.img = demean_values;
        save_nii(img_strut,name);
        
    else
        fprintf('This standardization method: %s not supported\n',handles.howStand)
        return
    end
end
fprintf('All done!\n')
