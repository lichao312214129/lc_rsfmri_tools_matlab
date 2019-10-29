function varargout = lc_suit_gui(varargin)
% 此代码用来对影像数据标准化
% LC_SUIT_GUI MATLAB code for lc_suit_gui.fig
%      LC_SUIT_GUI, by itself, creates a new LC_SUIT_GUI or raises the existing
%      singleton*.
%
%      H = LC_SUIT_GUI returns the handle to a new LC_SUIT_GUI or the handle to
%      the existing singleton*.
%
%      LC_SUIT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_SUIT_GUI.M with the given input arguments.
%
%      LC_SUIT_GUI('Property','Value',...) creates a new LC_SUIT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lc_suit_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lc_suit_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lc_suit_gui

% Last Modified by GUIDE v2.5 29-Oct-2019 18:58:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @lc_suit_gui_OpeningFcn, ...
    'gui_OutputFcn',  @lc_suit_gui_OutputFcn, ...
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


% --- Executes just before lc_suit_gui is made visible.
function lc_suit_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lc_suit_gui (see VARARGIN)
handles.issort = 0;
handles.save_folder=pwd;
% Choose default command line output for lc_suit_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lc_suit_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lc_suit_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in sortimg.
function sortimg_Callback(hObject, eventdata, handles)
% hObject    handle to sortimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.issort ~= -1
    [file,path] = uigetfile('*.nii;*.img;*.nii.gz','Select source data',pwd,'MultiSelect','on');
    try
        fun=@(a) fullfile(path,a);
        img_path_name = cellfun(fun,file, 'UniformOutput',false);
    catch
        img_path_name = fullfile(path,file);
    end
    % handles.img_path_name=img_path_name;
    set(handles.sourcefile,'string',img_path_name);
    if iscell(img_path_name)
        nf = length(img_path_name);
    else
        img_path_name = {img_path_name};
        nf = 1;
    end
    set(handles.sortimg,'string',cat(2,'Selected Source Data (',num2str(nf),')'));
    handles.img_path_name = img_path_name;
    
    % Update handles structure
    handles.issort = 1;
end
guidata(hObject, handles)


% --- Executes on button press in selectfolder.
function selectfolder_Callback(hObject, eventdata, handles)
% hObject    handle to selectfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
root=uigetdir('Root dir');
handles.root=root;

sub = dir(root);
name = {sub.name};
name = name(3:end);
sub = fullfile(root,name);
nf = length(sub);
img_path_name = cell(1,nf);
for i = 1:nf
   img = dir(sub{i});
   imgname = {img.name};
   imgname = imgname(3:end);
   img_path_name(1,i) = fullfile(sub(i),imgname);
end
handles.img_path_name = img_path_name;
set(handles.filesinfolder,'string',img_path_name);
set(handles.selectfolder,'string','Selected Source file');
handles.issort = 0;
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


% --- Executes on selection change in filesinfolder.
function filesinfolder_Callback(hObject, eventdata, handles)
% hObject    handle to filesinfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filesinfolder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filesinfolder


% --- Executes during object creation, after setting all properties.
function filesinfolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesinfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.opt


% Sort img arroding with sudo BIDS
% img_path_name_now = cell(nf,1);
% for i = 1: nf
%     img = handles.img_path_name{i};
%     [path, name,suffix] = fileparts(img);
%     subfolder = fullfile(path,'workstation',name);
%     if ~(exist(subfolder,'dir') == 7)
%         mkdir(subfolder);
%     else
%         fprintf('%s exist\n',subfolder);
%     end
%     try
%         movefile(img,subfolder);
%     catch
%         fprintf('%s already moved or not exist\n',img);
%     end
%     img_path_name_now{i} = fullfile(subfolder,[name,suffix]) ;
% end
% Main function

% Sort img arroding with sudo BIDS
if handles.issort == 1
    if iscell(handles.img_path_name)
        nf = length(handles.img_path_name);
    else
        handles.img_path_name = {handles.img_path_name};
        nf = 1;
    end
    img_path_name_now = cell(nf,1);
    for i = 1: nf
        img = handles.img_path_name{i};
        [path, name,suffix] = fileparts(img);
        path = fullfile(path,'workstation',name);
        if ~(exist(path,'dir') == 7)
            mkdir(path);
        else
            fprintf('%s exist\n',path);
        end
        try
            movefile(img,path);
        catch
            fprintf('%s already moved or not exist\n',img);
        end
        img_path_name_now{i} = fullfile(path,[name,suffix]) ;
    end
    handles.img_path_name_now = img_path_name_now;
    set(handles.sourcefile,'string',img_path_name_now);
    set(handles.sortimg,'string','Back to orignal format');
    handles.issort = -1;
    % Update handles structure
    guidata(hObject, handles)
    
% back to orginal format
elseif handles.issort == -1
    if iscell(handles.img_path_name_now)
        nf = length(handles.img_path_name_now);
    else
        handles.img_path_name_now = {handles.img_path_name_now};
        nf = 1;
    end
    img_path_name = cell(nf,1);
    for i = 1: nf
        img = handles.img_path_name_now{i};
        [path, name,suffix] = fileparts(handles.img_path_name{i});
        if ~(exist(path,'dir') == 7)
            mkdir(path);
        else
            fprintf('%s exist\n',path);
        end
        try
            movefile(img,path);
        catch
            fprintf('%s already moved or not exist\n',img);
        end
        img_path_name{i} = fullfile(path,[name,suffix]) ;
    end
    set(handles.sourcefile,'string',img_path_name);
    set(handles.sortimg,'string','Sort imgages to BIDS format');
    handles.issort = 1;
    deldir = fullfile(path,'workstation');
    rmdir (deldir, 's');
    % Update handles structure
    guidata(hObject, handles)
else
    lc_suit(handles.img_path_name,handles.save_folder);
end

