function varargout = TrainClassGUI(varargin)
% TRAINCLASSGUI M-file for TrainClassGUI.fig
%      TRAINCLASSGUI, by itself, creates a new TRAINCLASSGUI or raises the existing
%      singleton*.
%
%      H = TRAINCLASSGUI returns the handle to a new TRAINCLASSGUI or the handle to
%      the existing singleton*.
%
%      TRAINCLASSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAINCLASSGUI.M with the given input
%      arguments.
%
%      TRAINCLASSGUI('Property','Value',...) creates a new TRAINCLASSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrainClassGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrainClassGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrainClassGUI

% Last Modified by GUIDE v2.5 19-Apr-2011 20:58:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrainClassGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TrainClassGUI_OutputFcn, ...
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


% --- Executes just before TrainClassGUI is made visible.
function TrainClassGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrainClassGUI (see VARARGIN)

% Choose default command line output for TrainClassGUI
handles.output = hObject;

handles.classMethodsLabels = varargin{1};
handles.classMethod = varargin{2};

% Update handles structure
guidata(hObject, handles);
set(handles.Class_popup,'String', handles.classMethodsLabels);
set(handles.Class_popup,'Value', handles.classMethod);

% --- Outputs from this function are returned to the command line.
function varargout = TrainClassGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

    % UIWAIT makes TrainClassGUI wait for user response (see UIRESUME)
    uiwait(handles.figure1);

    ClassMethod = get(handles.Class_popup,'Value');
    
%     varargout = {lagtime, Inputs, Polyn_Order, xval_flag, foldlength};
     varargout = {ClassMethod};
      
    set(handles.figure1,'Visible','off');
    close(handles.figure1);

% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
uiresume(handles.figure1);

% --- Executes on selection change in Class_popup.
function Class_popup_Callback(hObject, eventdata, handles)
% hObject    handle to Class_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Class_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Class_popup


% --- Executes during object creation, after setting all properties.
function Class_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Class_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


