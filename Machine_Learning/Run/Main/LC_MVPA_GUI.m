function varargout = LC_MVPA_GUI(varargin)
% LC_MVPA_GUI MATLAB code for LC_MVPA_GUI.fig
%      LC_MVPA_GUI, by itself, creates a new LC_MVPA_GUI or raises the existing
%      singleton*.
%
%      H = LC_MVPA_GUI returns the handle to a new LC_MVPA_GUI or the handle to
%      the existing singleton*.
%
%      LC_MVPA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LC_MVPA_GUI.M with the given input arguments.
%
%      LC_MVPA_GUI('Property','Value',...) creates a new LC_MVPA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LC_MVPA_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LC_MVPA_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LC_MVPA_GUI

% Last Modified by GUIDE v2.5 01-Nov-2017 19:14:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LC_MVPA_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LC_MVPA_GUI_OutputFcn, ...
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


% --- Executes just before LC_MVPA_GUI is made visible.
function LC_MVPA_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LC_MVPA_GUI (see VARARGIN)

% Choose default command line output for LC_MVPA_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LC_MVPA_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LC_MVPA_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Classification.
function Classification_Callback(hObject, eventdata, handles)
% hObject    handle to Classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MVPA_Classification_GUI

% --- Executes on button press in Regression.
function Regression_Callback(hObject, eventdata, handles)
% hObject    handle to Regression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MVPA_Regression_GUI

% --- Executes on button press in Statistical_analysis.
function Statistical_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Statistical_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
