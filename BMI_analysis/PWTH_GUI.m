function varargout = PWTH_GUI(varargin)
% PWTH_GUI M-file for PWTH_GUI.fig
%      PWTH_GUI, by itself, creates a new PWTH_GUI or raises the existing
%      singleton*.
%
%      H = PWTH_GUI returns the handle to a new PWTH_GUI or the handle to
%      the existing singleton*.
%
%      PWTH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PWTH_GUI.M with the given input arguments.
%
%      PWTH_GUI('Property','Value',...) creates a new PWTH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PWTH_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PWTH_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PWTH_GUI

% Last Modified by GUIDE v2.5 15-Apr-2009 13:50:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PWTH_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PWTH_GUI_OutputFcn, ...
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


% --- Executes just before PWTH_GUI is made visible.
function PWTH_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PWTH_GUI (see VARARGIN)

% Choose default command line output for PWTH_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PWTH_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PWTH_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


    TimeBefore = get(handles.startTime_txtbx, 'Value');
    TimeAfter = get(handles.stopTime_txtbx, 'Value');
    varargout = {TimeBefore TimeAfter};

    close(handles.figure1);


% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);

function startTime_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to startTime_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startTime_txtbx as text
%        str2double(get(hObject,'String')) returns contents of startTime_txtbx as a double
   set(handles.startTime_txtbx, 'value', str2double(get(hObject,'String')) );

% --- Executes during object creation, after setting all properties.
function startTime_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTime_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stopTime_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to stopTime_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopTime_txtbx as text
%        str2double(get(hObject,'String')) returns contents of stopTime_txtbx as a double
    set(handles.stopTime_txtbx, 'value', str2double(get(hObject,'String')) );
        

% --- Executes during object creation, after setting all properties.
function stopTime_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopTime_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

   

