function varargout = PredOptionsGUI(varargin)
% PREDOPTIONSGUI M-file for PredOptionsGUI.fig
%      PREDOPTIONSGUI, by itself, creates a new PREDOPTIONSGUI or raises the existing
%      singleton*.
%
%      H = PREDOPTIONSGUI returns the handle to a new PREDOPTIONSGUI or the handle to
%      the existing singleton*.
%
%      PREDOPTIONSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREDOPTIONSGUI.M with the given input
%      arguments.
%
%      PREDOPTIONSGUI('Property','Value',...) creates a new PREDOPTIONSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PredOptionsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PredOptionsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PredOptionsGUI

% Last Modified by GUIDE v2.5 05-Apr-2010 10:01:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PredOptionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PredOptionsGUI_OutputFcn, ...
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


% --- Executes just before PredOptionsGUI is made visible.
function PredOptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PredOptionsGUI (see VARARGIN)

% Choose default command line output for PredOptionsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = PredOptionsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

    % UIWAIT makes PredOptionsGUI wait for user response (see UIRESUME)
    uiwait(handles.figure1);

    FiltPred = get(handles.Smooth_cbx,'Value');
    Adapt_Enable = get(handles.Adapt_cbx,'Value');

    varargout = {FiltPred,Adapt_Enable};
      
    set(handles.figure1,'Visible','off');
    close(handles.figure1);

% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        uiresume(handles.figure1);


% --- Executes on button press in Smooth_cbx.
function Smooth_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Smooth_cbx


% --- Executes on button press in Adapt_cbx.
function Adapt_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Adapt_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Adapt_cbx


% --- Executes on key release with focus on figure1 and no controls selected.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


