function varargout = Staircase_setup_gui(varargin)
% STAIRCASE_SETUP_GUI M-file for Staircase_setup_gui.fig
%      STAIRCASE_SETUP_GUI, by itself, creates a new STAIRCASE_SETUP_GUI or raises the existing
%      singleton*.
%
%      H = STAIRCASE_SETUP_GUI returns the handle to a new STAIRCASE_SETUP_GUI or the handle to
%      the existing singleton*.
%
%      STAIRCASE_SETUP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STAIRCASE_SETUP_GUI.M with the given input arguments.
%
%      STAIRCASE_SETUP_GUI('Property','Value',...) creates a new STAIRCASE_SETUP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Staircase_setup_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Staircase_setup_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Staircase_setup_gui

% Last Modified by GUIDE v2.5 22-Oct-2010 12:14:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Staircase_setup_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Staircase_setup_gui_OutputFcn, ...
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


% --- Executes just before Staircase_setup_gui is made visible.
function Staircase_setup_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Staircase_setup_gui (see VARARGIN)

% Choose default command line output for Staircase_setup_gui
handles.output = hObject;
handles.EMG_labels = varargin{1};
handles.EMG_enable = varargin{2};

% Update handles structure
guidata(hObject, handles);

% set lables and enables from varargin:
set(handles.EMG_ch0,'String',handles.EMG_labels{1});
set(handles.EMG_ch1,'String',handles.EMG_labels{2});
set(handles.EMG_ch2,'String',handles.EMG_labels{3});
set(handles.EMG_ch3,'String',handles.EMG_labels{4});
set(handles.EMG_ch4,'String',handles.EMG_labels{5});
set(handles.EMG_ch5,'String',handles.EMG_labels{6});
set(handles.EMG_ch6,'String',handles.EMG_labels{7});
set(handles.EMG_ch7,'String',handles.EMG_labels{8});
set(handles.EMG_ch8,'String',handles.EMG_labels{9});
set(handles.EMG_ch9,'String',handles.EMG_labels{10});
set(handles.EMG_ch10,'String',handles.EMG_labels{11});
set(handles.EMG_ch11,'String',handles.EMG_labels{12});
set(handles.EMG_ch12,'String',handles.EMG_labels{13});
set(handles.EMG_ch13,'String',handles.EMG_labels{14});
set(handles.EMG_ch14,'String',handles.EMG_labels{15});
set(handles.EMG_ch15,'String',handles.EMG_labels{16});
set(handles.EMG_ch16,'String',handles.EMG_labels{17});
set(handles.EMG_ch17,'String',handles.EMG_labels{18});
set(handles.EMG_ch18,'String',handles.EMG_labels{19});
set(handles.EMG_ch19,'String',handles.EMG_labels{20});
set(handles.EMG_ch20,'String',handles.EMG_labels{21});
set(handles.EMG_ch21,'String',handles.EMG_labels{22});

set(handles.enable_ch0,'Value',handles.EMG_enable(1));
set(handles.enable_ch1,'Value',handles.EMG_enable(2));
set(handles.enable_ch2,'Value',handles.EMG_enable(3));
set(handles.enable_ch3,'Value',handles.EMG_enable(4));
set(handles.enable_ch4,'Value',handles.EMG_enable(5));
set(handles.enable_ch5,'Value',handles.EMG_enable(6));
set(handles.enable_ch6,'Value',handles.EMG_enable(7));
set(handles.enable_ch7,'Value',handles.EMG_enable(8));
set(handles.enable_ch8,'Value',handles.EMG_enable(9));
set(handles.enable_ch9,'Value',handles.EMG_enable(10));
set(handles.enable_ch10,'Value',handles.EMG_enable(11));
set(handles.enable_ch11,'Value',handles.EMG_enable(12));
set(handles.enable_ch12,'Value',handles.EMG_enable(13));
set(handles.enable_ch13,'Value',handles.EMG_enable(14));
set(handles.enable_ch14,'Value',handles.EMG_enable(15));
set(handles.enable_ch15,'Value',handles.EMG_enable(16));
set(handles.enable_ch16,'Value',handles.EMG_enable(17));
set(handles.enable_ch17,'Value',handles.EMG_enable(18));
set(handles.enable_ch18,'Value',handles.EMG_enable(19));
set(handles.enable_ch19,'Value',handles.EMG_enable(20));
set(handles.enable_ch20,'Value',handles.EMG_enable(21));
set(handles.enable_ch21,'Value',handles.EMG_enable(22));

% UIWAIT makes Staircase_setup_gui wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Staircase_setup_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set arg out according to current state of labels and enables.
EMG_enable = logical([get(handles.enable_ch0, 'Value')...
              get(handles.enable_ch1, 'Value')...
              get(handles.enable_ch2, 'Value')...
              get(handles.enable_ch3, 'Value')...
              get(handles.enable_ch4, 'Value')...
              get(handles.enable_ch5, 'Value')...
              get(handles.enable_ch6, 'Value')...
              get(handles.enable_ch7, 'Value')...
              get(handles.enable_ch8, 'Value')...
              get(handles.enable_ch9, 'Value')...
              get(handles.enable_ch10, 'Value')...
              get(handles.enable_ch11, 'Value')...
              get(handles.enable_ch12, 'Value')...
              get(handles.enable_ch13, 'Value')...
              get(handles.enable_ch14, 'Value')...
              get(handles.enable_ch15, 'Value')...
              get(handles.enable_ch16, 'Value')...
              get(handles.enable_ch17, 'Value')...
              get(handles.enable_ch18, 'Value')...
              get(handles.enable_ch19, 'Value')...
              get(handles.enable_ch20, 'Value')...
              get(handles.enable_ch21, 'Value')]);
EMG_labels = {get(handles.EMG_ch0, 'String') ...
              get(handles.EMG_ch1, 'String') ...
              get(handles.EMG_ch2, 'String') ...
              get(handles.EMG_ch3, 'String') ...
              get(handles.EMG_ch4, 'String') ...
              get(handles.EMG_ch5, 'String') ...
              get(handles.EMG_ch6, 'String') ...
              get(handles.EMG_ch7, 'String') ...
              get(handles.EMG_ch8, 'String') ...
              get(handles.EMG_ch9, 'String') ...
              get(handles.EMG_ch10, 'String') ...
              get(handles.EMG_ch11, 'String') ...
              get(handles.EMG_ch12, 'String') ...
              get(handles.EMG_ch13, 'String') ...
              get(handles.EMG_ch14, 'String') ...
              get(handles.EMG_ch15, 'String') ...
              get(handles.EMG_ch16, 'String') ...
              get(handles.EMG_ch17, 'String') ...
              get(handles.EMG_ch18, 'String') ...
              get(handles.EMG_ch19, 'String') ...
              get(handles.EMG_ch20, 'String') ...
              get(handles.EMG_ch21, 'String')};
varargout = {EMG_labels EMG_enable};
close(handles.figure1);



function EMG_ch0_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch0 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch0 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch1_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch1 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch1 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch2_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch2 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch2 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch3_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch3 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch3 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch4_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch4 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch4 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch5_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch5 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch5 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch6_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch6 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch6 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch7_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch7 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch7 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch8_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch8 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch8 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch9_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch9 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch9 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch10_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch10 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch10 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMG_ch11_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch11 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch11 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch12_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch11 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch11 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch13_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch13 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch13 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch14_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch14 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch14 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch15_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch15 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch15 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch16_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch16 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch16 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch17_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch17 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch17 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch18_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch18 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch18 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch19_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch19 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch19 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function EMG_ch20_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch20 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch20 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMG_ch21_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_ch21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EMG_ch21 as text
%        str2double(get(hObject,'String')) returns contents of EMG_ch21 as a double


% --- Executes during object creation, after setting all properties.
function EMG_ch21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EMG_ch21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in enable_ch0.
function enable_ch0_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch0


% --- Executes on button press in enable_ch1.
function enable_ch1_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch1


% --- Executes on button press in enable_ch2.
function enable_ch2_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch2


% --- Executes on button press in enable_ch3.
function enable_ch3_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch3



% --- Executes on button press in enable_ch4.
function enable_ch4_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch4



% --- Executes on button press in enable_ch5.
function enable_ch5_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch5


% --- Executes on button press in enable_ch6.
function enable_ch6_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch6


% --- Executes on button press in enable_ch7.
function enable_ch7_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch7


% --- Executes on button press in enable_ch8.
function enable_ch8_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch8


% --- Executes on button press in enable_ch9.
function enable_ch9_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch9


% --- Executes on button press in enable_ch10.
function enable_ch10_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch10


% --- Executes on button press in enable_ch11.
function enable_ch11_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch11



% --- Executes on button press in enable_ch12.
function enable_ch12_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch12



% --- Executes on button press in enable_ch13.
function enable_ch13_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch13



% --- Executes on button press in enable_ch14.
function enable_ch14_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch14



% --- Executes on button press in enable_ch15.
function enable_ch15_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch15



% --- Executes on button press in enable_ch16.
function enable_ch16_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch16



% --- Executes on button press in enable_ch17.
function enable_ch17_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch17



% --- Executes on button press in enable_ch18.
function enable_ch18_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch18



% --- Executes on button press in enable_ch19.
function enable_ch19_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch19



% --- Executes on button press in enable_ch20.
function enable_ch20_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch20



% --- Executes on button press in enable_ch21.
function enable_ch21_Callback(hObject, eventdata, handles)
% hObject    handle to enable_ch21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_ch21



% --- Executes on button press in OK_button.
function OK_button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
