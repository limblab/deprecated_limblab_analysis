function varargout = stim_gui(varargin)
% STIM_GUI MATLAB code for stim_gui.fig
%      STIM_GUI, by itself, creates a new STIM_GUI or raises the existing
%      singleton*.
%
%      H = STIM_GUI returns the handle to a new STIM_GUI or the handle to
%      the existing singleton*.
%
%      STIM_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIM_GUI.M with the given input arguments.
%
%      STIM_GUI('Property','Value',...) creates a new STIM_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stim_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stim_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stim_gui

% Last Modified by GUIDE v2.5 09-May-2016 09:54:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stim_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @stim_gui_OutputFcn, ...
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


% --- Executes just before stim_gui is made visible.
function stim_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stim_gui (see VARARGIN)

% Choose default command line output for stim_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stim_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stim_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox2.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox2.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox6.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox6.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6



function muscle1_Callback(hObject, eventdata, handles)
% hObject    handle to muscle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle1 as text
%        str2double(get(hObject,'String')) returns contents of muscle1 as a double


% --- Executes during object creation, after setting all properties.
function muscle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle2_Callback(hObject, eventdata, handles)
% hObject    handle to muscle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle2 as text
%        str2double(get(hObject,'String')) returns contents of muscle2 as a double


% --- Executes during object creation, after setting all properties.
function muscle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle3_Callback(hObject, eventdata, handles)
% hObject    handle to muscle3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle3 as text
%        str2double(get(hObject,'String')) returns contents of muscle3 as a double


% --- Executes during object creation, after setting all properties.
function muscle3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle4_Callback(hObject, eventdata, handles)
% hObject    handle to muscle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle4 as text
%        str2double(get(hObject,'String')) returns contents of muscle4 as a double


% --- Executes during object creation, after setting all properties.
function muscle4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle5_Callback(hObject, eventdata, handles)
% hObject    handle to muscle5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle5 as text
%        str2double(get(hObject,'String')) returns contents of muscle5 as a double


% --- Executes during object creation, after setting all properties.
function muscle5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle6_Callback(hObject, eventdata, handles)
% hObject    handle to muscle6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle6 as text
%        str2double(get(hObject,'String')) returns contents of muscle6 as a double


% --- Executes during object creation, after setting all properties.
function muscle6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle7_Callback(hObject, eventdata, handles)
% hObject    handle to muscle7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle7 as text
%        str2double(get(hObject,'String')) returns contents of muscle7 as a double


% --- Executes during object creation, after setting all properties.
function muscle7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle8_Callback(hObject, eventdata, handles)
% hObject    handle to muscle8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle8 as text
%        str2double(get(hObject,'String')) returns contents of muscle8 as a double


% --- Executes during object creation, after setting all properties.
function muscle8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp1_Callback(hObject, eventdata, handles)
% hObject    handle to amp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp1 as text
%        str2double(get(hObject,'String')) returns contents of amp1 as a double


% --- Executes during object creation, after setting all properties.
function amp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp2_Callback(hObject, eventdata, handles)
% hObject    handle to amp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp2 as text
%        str2double(get(hObject,'String')) returns contents of amp2 as a double


% --- Executes during object creation, after setting all properties.
function amp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp3_Callback(hObject, eventdata, handles)
% hObject    handle to amp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp3 as text
%        str2double(get(hObject,'String')) returns contents of amp3 as a double


% --- Executes during object creation, after setting all properties.
function amp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp4_Callback(hObject, eventdata, handles)
% hObject    handle to amp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp4 as text
%        str2double(get(hObject,'String')) returns contents of amp4 as a double


% --- Executes during object creation, after setting all properties.
function amp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp5_Callback(hObject, eventdata, handles)
% hObject    handle to amp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp5 as text
%        str2double(get(hObject,'String')) returns contents of amp5 as a double


% --- Executes during object creation, after setting all properties.
function amp5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp6_Callback(hObject, eventdata, handles)
% hObject    handle to amp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp6 as text
%        str2double(get(hObject,'String')) returns contents of amp6 as a double


% --- Executes during object creation, after setting all properties.
function amp6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp7_Callback(hObject, eventdata, handles)
% hObject    handle to amp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp7 as text
%        str2double(get(hObject,'String')) returns contents of amp7 as a double


% --- Executes during object creation, after setting all properties.
function amp7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp8_Callback(hObject, eventdata, handles)
% hObject    handle to amp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp8 as text
%        str2double(get(hObject,'String')) returns contents of amp8 as a double


% --- Executes during object creation, after setting all properties.
function amp8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw1_Callback(hObject, eventdata, handles)
% hObject    handle to pw1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw1 as text
%        str2double(get(hObject,'String')) returns contents of pw1 as a double


% --- Executes during object creation, after setting all properties.
function pw1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw2_Callback(hObject, eventdata, handles)
% hObject    handle to pw2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw2 as text
%        str2double(get(hObject,'String')) returns contents of pw2 as a double


% --- Executes during object creation, after setting all properties.
function pw2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw3_Callback(hObject, eventdata, handles)
% hObject    handle to pw3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw3 as text
%        str2double(get(hObject,'String')) returns contents of pw3 as a double


% --- Executes during object creation, after setting all properties.
function pw3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw4_Callback(hObject, eventdata, handles)
% hObject    handle to pw4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw4 as text
%        str2double(get(hObject,'String')) returns contents of pw4 as a double


% --- Executes during object creation, after setting all properties.
function pw4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw5_Callback(hObject, eventdata, handles)
% hObject    handle to pw5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw5 as text
%        str2double(get(hObject,'String')) returns contents of pw5 as a double


% --- Executes during object creation, after setting all properties.
function pw5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw6_Callback(hObject, eventdata, handles)
% hObject    handle to pw6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw6 as text
%        str2double(get(hObject,'String')) returns contents of pw6 as a double


% --- Executes during object creation, after setting all properties.
function pw6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw7_Callback(hObject, eventdata, handles)
% hObject    handle to pw7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw7 as text
%        str2double(get(hObject,'String')) returns contents of pw7 as a double


% --- Executes during object creation, after setting all properties.
function pw7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw8_Callback(hObject, eventdata, handles)
% hObject    handle to pw8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw8 as text
%        str2double(get(hObject,'String')) returns contents of pw8 as a double


% --- Executes during object creation, after setting all properties.
function pw8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl1_Callback(hObject, eventdata, handles)
% hObject    handle to tl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl1 as text
%        str2double(get(hObject,'String')) returns contents of tl1 as a double


% --- Executes during object creation, after setting all properties.
function tl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl2_Callback(hObject, eventdata, handles)
% hObject    handle to tl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl2 as text
%        str2double(get(hObject,'String')) returns contents of tl2 as a double


% --- Executes during object creation, after setting all properties.
function tl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl3_Callback(hObject, eventdata, handles)
% hObject    handle to tl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl3 as text
%        str2double(get(hObject,'String')) returns contents of tl3 as a double


% --- Executes during object creation, after setting all properties.
function tl3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl4_Callback(hObject, eventdata, handles)
% hObject    handle to tl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl4 as text
%        str2double(get(hObject,'String')) returns contents of tl4 as a double


% --- Executes during object creation, after setting all properties.
function tl4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl5_Callback(hObject, eventdata, handles)
% hObject    handle to tl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl5 as text
%        str2double(get(hObject,'String')) returns contents of tl5 as a double


% --- Executes during object creation, after setting all properties.
function tl5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl6_Callback(hObject, eventdata, handles)
% hObject    handle to tl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl6 as text
%        str2double(get(hObject,'String')) returns contents of tl6 as a double


% --- Executes during object creation, after setting all properties.
function tl6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl7_Callback(hObject, eventdata, handles)
% hObject    handle to tl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl7 as text
%        str2double(get(hObject,'String')) returns contents of tl7 as a double


% --- Executes during object creation, after setting all properties.
function tl7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl8_Callback(hObject, eventdata, handles)
% hObject    handle to tl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl8 as text
%        str2double(get(hObject,'String')) returns contents of tl8 as a double


% --- Executes during object creation, after setting all properties.
function tl8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start1_Callback(hObject, eventdata, handles)
% hObject    handle to start1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start1 as text
%        str2double(get(hObject,'String')) returns contents of start1 as a double


% --- Executes during object creation, after setting all properties.
function start1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start2_Callback(hObject, eventdata, handles)
% hObject    handle to start2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start2 as text
%        str2double(get(hObject,'String')) returns contents of start2 as a double


% --- Executes during object creation, after setting all properties.
function start2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start3_Callback(hObject, eventdata, handles)
% hObject    handle to start3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start3 as text
%        str2double(get(hObject,'String')) returns contents of start3 as a double


% --- Executes during object creation, after setting all properties.
function start3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start4_Callback(hObject, eventdata, handles)
% hObject    handle to start4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start4 as text
%        str2double(get(hObject,'String')) returns contents of start4 as a double


% --- Executes during object creation, after setting all properties.
function start4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start5_Callback(hObject, eventdata, handles)
% hObject    handle to start5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start5 as text
%        str2double(get(hObject,'String')) returns contents of start5 as a double


% --- Executes during object creation, after setting all properties.
function start5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start6_Callback(hObject, eventdata, handles)
% hObject    handle to start6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start6 as text
%        str2double(get(hObject,'String')) returns contents of start6 as a double


% --- Executes during object creation, after setting all properties.
function start6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start7_Callback(hObject, eventdata, handles)
% hObject    handle to start7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start7 as text
%        str2double(get(hObject,'String')) returns contents of start7 as a double


% --- Executes during object creation, after setting all properties.
function start7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start8_Callback(hObject, eventdata, handles)
% hObject    handle to start8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start8 as text
%        str2double(get(hObject,'String')) returns contents of start8 as a double


% --- Executes during object creation, after setting all properties.
function start8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save


function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double


% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq as text
%        str2double(get(hObject,'String')) returns contents of freq as a double


% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numcyc_Callback(hObject, eventdata, handles)
% hObject    handle to numcyc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numcyc as text
%        str2double(get(hObject,'String')) returns contents of numcyc as a double


% --- Executes during object creation, after setting all properties.
function numcyc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numcyc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cycdelay_Callback(hObject, eventdata, handles)
% hObject    handle to cycdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cycdelay as text
%        str2double(get(hObject,'String')) returns contents of cycdelay as a double


% --- Executes during object creation, after setting all properties.
function cycdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cycdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%All of the important code happens here, when you hit "Run": 
% Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get inputs from gui: 
channels = {get(handles.checkbox1, 'Value'), get(handles.checkbox2, 'Value'), get(handles.checkbox3, 'Value'), get(handles.checkbox4, 'Value'), ...
    get(handles.checkbox5, 'Value'), get(handles.checkbox6, 'Value'), get(handles.checkbox7, 'Value'), get(handles.checkbox8, 'Value')};
muscles = {get(handles.muscle1, 'String'), get(handles.muscle2, 'String'), get(handles.muscle3, 'String'), get(handles.muscle4, 'String'),...
    get(handles.muscle5, 'String'), get(handles.muscle6, 'String'), get(handles.muscle7, 'String'), get(handles.muscle8, 'String')}; %must use cell array or strings get concatenated
amps = {str2double(get(handles.amp1, 'String')), str2double(get(handles.amp2, 'String')), str2double(get(handles.amp3, 'String')), str2double(get(handles.amp4, 'String')), ...
    str2double(get(handles.amp5, 'String')), str2double(get(handles.amp6, 'String')), str2double(get(handles.amp7, 'String')), str2double(get(handles.amp8, 'String'))};
pws = {str2double(get(handles.pw1, 'String')), str2double(get(handles.pw2, 'String')), str2double(get(handles.pw3, 'String')), str2double(get(handles.pw4, 'String')), ...
    str2double(get(handles.pw5, 'String')), str2double(get(handles.pw6, 'String')), str2double(get(handles.pw7, 'String')), str2double(get(handles.pw8, 'String'))};
tls = {str2double(get(handles.tl1, 'String')), str2double(get(handles.tl2, 'String')), str2double(get(handles.tl3, 'String')), str2double(get(handles.tl4, 'String')), ...
    str2double(get(handles.tl5, 'String')), str2double(get(handles.tl6, 'String')), str2double(get(handles.tl7, 'String')), str2double(get(handles.tl8, 'String'))};
starts = {str2double(get(handles.start1, 'String')), str2double(get(handles.start2, 'String')), str2double(get(handles.start3, 'String')), str2double(get(handles.start4, 'String')), ...
    str2double(get(handles.start5, 'String')), str2double(get(handles.start6, 'String')), str2double(get(handles.start7, 'String')), str2double(get(handles.start8, 'String'))};


%check which channels are supposed to be stimulated
index = [];
for i=1:length(channels)
    if channels{i}==true
        index(end+1) = i; %#ok<AGROW>
    end
end

%sort the channels by start time so train stagger is grouped by channels
%stimulated together
[sorted_starts, ind] = sort(cell2mat(starts)); 
tds = {0, 0, 0, 0, 0, 0, 0, 0};
j=0; 

%for each channel that will be stimulated, make a train delay variable
for i=1:length(sorted_starts)
    if ismember(ind(i), index) %check if the channel is stimulated
        j = j+1; %inc arbitrary var that determines the stagger amt
        
        %make the train delay variable: 50 us minimum, stagger channels
        tds{ind(i)} = 50 + 500*j + sorted_starts(i)*1000; %tds are in us
    end
end

%if saving, write all of these cells to a .mat file: 
save_path = fileparts(mfilename('fullpath')); 
if get(handles.save, 'Value')
    file_name = get(handles.filename, 'String'); %must make a new file name every time
    disp(file_name)
    %file_name = file_name{1}
    if exist(fullfile(save_path, strcat('data_files/', file_name, '.mat')), 'file')
        overwrite = questdlg('This file already exists. Are you sure you want to overwrite it?', ...
            'Choices', 'Okay', 'Cancel', 'Cancel'); 
        switch overwrite
            case 'Okay'
                disp(['Overwriting file ', file_name]);
            case 'Cancel'
                disp('Canceled operation, rename variable file')
                return; 
        end
    end
    save(fullfile(save_path, strcat('data_files/', file_name)), 'muscles', 'channels', 'amps', 'pws', 'tls', 'tds'); 
end


%if the stimulator object doesn't exist yet, set it up: 
if ~exist('ws', 'var')
    serial_string = 'COM6'; %this is different via mac and windows; use instrfind to check location
    ws = wireless_stim(serial_string, 1); %the number has to do with verbosity of running feedback
    ws.init(1, ws.comm_timeout_disable);
end

%get commands for every channel being used and set up the 
for element=1:length(index)
    ch = index(element); 
    tl = tls{ch}; % ms
    freq = str2double(get(handles.freq, 'String')); %Hz
    pw = pws{ch}*1000; % us, converted from input in ms
    amp = amps{ch}*1000; %input in mA, gets programmed in uA
    td = tds{ch}; %us
    
    %Can add parameters for train delay (TD) and polarity (PL; 1 is
    %cathodic first)
    command{1} = struct('TL', tl, ...%ms
        'TD', td, ... % us; this includes both stim stagger and delayed start 
        'Freq', freq, ...        % Hz
        'CathDur', pw, ...    % us
        'AnodDur', pw, ...    % us
        'CathAmp', amp+32768, ... % uA
        'AnodAmp', 32768-amp, ... % uA
        'Run', ws.run_once ... % Single train mode
        );
    ws.set_stim(command, ch); 
end


%start time for each is stored in starts{index(element)}
%tl for each is in tls{index(element)}
cycle_del = str2double(get(handles.cycdelay, 'String')); %get cycle delay in ms
num_cycles = str2double(get(handles.numcyc, 'String')); %number of cycles

%add delay so the code pauses until stim is completed for a cycle

%find length of time needed to pause so stimulation can complete a cycle: 
stim_lens = zeros([1 length(tds)]); 
for i=1:length(tds)
    stim_lens(i) = tds{i} + tls{i}*1000; 
end
time_to_stim = max(stim_lens)/1000; % this val is returned in ms 

%run everything as many times as specified, with appropriate delays in the
%cycle
for i=1:num_cycles
    command{1} = struct('Run', ws.run_once_go); 
    ws.set_stim(command, index); %run stimulation commands for all muscles being used
    pause((time_to_stim+cycle_del)/1000) %pause until time for next step cycle
end

disp('done stimulating'); 
%TODO: cleanup. 
