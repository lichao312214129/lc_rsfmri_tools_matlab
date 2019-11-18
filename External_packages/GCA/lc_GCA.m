function varargout = lc_GCA(varargin)
% LC_GCA MATLAB code for lc_GCA.fig
%      LC_GCA, by itself, creates a new LC_GCA or raises the existing
%      singleton*.
%
%      H = LC_GCA returns the handle to a new LC_GCA or the handle to
%      the existing singleton*.
%
%      LC_GCA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_GCA.M with the given input arguments.
%
%      LC_GCA('Property','Value',...) creates a new LC_GCA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lc_GCA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lc_GCA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lc_GCA

% Last Modified by GUIDE v2.5 18-Nov-2019 17:10:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @lc_GCA_OpeningFcn, ...
    'gui_OutputFcn',  @lc_GCA_OutputFcn, ...
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


% --- Executes just before lc_GCA is made visible.
function lc_GCA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lc_GCA (see VARARGIN)
handles.issort = 0;
handles.save_folder=pwd;
% Choose default command line output for lc_GCA
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lc_GCA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lc_GCA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in selectfolder.
function selectfolder_Callback(hObject, eventdata, handles)
% hObject    handle to selectfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('','MultiSelect','on','Select ROI signals');
filepath = fullfile(path, file)';
nf = length(filepath);
img_path_name = cell(1,nf);
handles.img_path_name = filepath;
set(handles.filesinfolder,'string',filepath);
set(handles.selectfolder,'string','Selected Signals file');
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
lc_gca_bivariate_coefficient(handles.img_path_name,handles.save_folder,1,[]);

