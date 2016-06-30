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

% Last Modified by GUIDE v2.5 01-Jun-2016 14:26:13

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



%%All of the important code happens here, when you hit "Run": 
% Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get inputs from gui: 
channels = {get(handles.checkbox1, 'Value'), get(handles.checkbox2, 'Value'), get(handles.checkbox3, 'Value'), get(handles.checkbox4, 'Value'), ...
    get(handles.checkbox5, 'Value'), get(handles.checkbox6, 'Value'), get(handles.checkbox7, 'Value'), get(handles.checkbox8, 'Value'), get(handles.checkbox9, 'Value'), get(handles.checkbox10, 'Value')};
muscles = {get(handles.muscle1, 'String'), get(handles.muscle2, 'String'), get(handles.muscle3, 'String'), get(handles.muscle4, 'String'),...
    get(handles.muscle5, 'String'), get(handles.muscle6, 'String'), get(handles.muscle7, 'String'), get(handles.muscle8, 'String'), get(handles.muscle9, 'String'), get(handles.muscle10, 'String')}; %must use cell array or strings get concatenated
amps = {str2double(get(handles.amp1, 'String')), str2double(get(handles.amp2, 'String')), str2double(get(handles.amp3, 'String')), str2double(get(handles.amp4, 'String')), ...
    str2double(get(handles.amp5, 'String')), str2double(get(handles.amp6, 'String')), str2double(get(handles.amp7, 'String')), str2double(get(handles.amp8, 'String')), str2double(get(handles.amp9, 'String')), str2double(get(handles.amp10, 'String'))};
pws = {str2double(get(handles.pw1, 'String')), str2double(get(handles.pw2, 'String')), str2double(get(handles.pw3, 'String')), str2double(get(handles.pw4, 'String')), ...
    str2double(get(handles.pw5, 'String')), str2double(get(handles.pw6, 'String')), str2double(get(handles.pw7, 'String')), str2double(get(handles.pw8, 'String')), str2double(get(handles.pw9, 'String')), str2double(get(handles.pw10, 'String'))};
tls = {str2double(get(handles.tl1, 'String')), str2double(get(handles.tl2, 'String')), str2double(get(handles.tl3, 'String')), str2double(get(handles.tl4, 'String')), ...
    str2double(get(handles.tl5, 'String')), str2double(get(handles.tl6, 'String')), str2double(get(handles.tl7, 'String')), str2double(get(handles.tl8, 'String')), str2double(get(handles.tl9, 'String')), str2double(get(handles.tl10, 'String'))};
starts = {str2double(get(handles.start1, 'String')), str2double(get(handles.start2, 'String')), str2double(get(handles.start3, 'String')), str2double(get(handles.start4, 'String')), ...
    str2double(get(handles.start5, 'String')), str2double(get(handles.start6, 'String')), str2double(get(handles.start7, 'String')), str2double(get(handles.start8, 'String')), str2double(get(handles.start9, 'String')), str2double(get(handles.start10, 'String'))};


%check which channels are supposed to be stimulated
index = [];
for i=1:length(channels)
    if channels{i}==true
        index(end+1) = i; 
    end
end

%start time for each is stored in starts{index(element)}
%tl for each is in tls{index(element)}
cycle_del = str2double(get(handles.cycdelay, 'String')); %get cycle delay in ms
num_cycles = str2double(get(handles.numcyc, 'String')); %number of cycles
freq = str2double(get(handles.freq, 'String')); %Hz


current_arr = cell(1, length(index)); 
%get array of values to stimulate
for i=1:length(index) %for all channels that are supposed to be stimulated
    %get zero values before the stimulation starts
    initial_zeros = zeros(1, starts{i}*freq/1000); 
    %get values during stimulation
    stim_values = amps{i}*ones(1, tls{i}*freq/1000);     
    %get zero values after stimulation
    end_zeros = zeros(1, cycle_del*freq/1000); 
    current_arr{i} = [initial_zeros, stim_values, end_zeros]; 
end

%get zero values so all channels are the same length

plot(current_arr); 



%TODO: delete all of this - tds are taken care of in array_stim
%TODO: add serial port chooser to the gui
%find length of time needed to pause so stimulation can complete a cycle: 


disp('done stimulating'); 
%TODO: cleanup. 




%% And here are all the default fxns created by GUIDE. 
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


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9



function muscle9_Callback(hObject, eventdata, handles)
% hObject    handle to muscle9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle9 as text
%        str2double(get(hObject,'String')) returns contents of muscle9 as a double


% --- Executes during object creation, after setting all properties.
function muscle9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp9_Callback(hObject, eventdata, handles)
% hObject    handle to amp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp9 as text
%        str2double(get(hObject,'String')) returns contents of amp9 as a double


% --- Executes during object creation, after setting all properties.
function amp9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw9_Callback(hObject, eventdata, handles)
% hObject    handle to pw9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw9 as text
%        str2double(get(hObject,'String')) returns contents of pw9 as a double


% --- Executes during object creation, after setting all properties.
function pw9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl9_Callback(hObject, eventdata, handles)
% hObject    handle to tl9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl9 as text
%        str2double(get(hObject,'String')) returns contents of tl9 as a double


% --- Executes during object creation, after setting all properties.
function tl9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start9_Callback(hObject, eventdata, handles)
% hObject    handle to start9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start9 as text
%        str2double(get(hObject,'String')) returns contents of start9 as a double


% --- Executes during object creation, after setting all properties.
function start9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muscle10_Callback(hObject, eventdata, handles)
% hObject    handle to muscle10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muscle10 as text
%        str2double(get(hObject,'String')) returns contents of muscle10 as a double


% --- Executes during object creation, after setting all properties.
function muscle10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muscle10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amp10_Callback(hObject, eventdata, handles)
% hObject    handle to amp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amp10 as text
%        str2double(get(hObject,'String')) returns contents of amp10 as a double


% --- Executes during object creation, after setting all properties.
function amp10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pw10_Callback(hObject, eventdata, handles)
% hObject    handle to pw10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pw10 as text
%        str2double(get(hObject,'String')) returns contents of pw10 as a double


% --- Executes during object creation, after setting all properties.
function pw10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pw10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tl10_Callback(hObject, eventdata, handles)
% hObject    handle to tl10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tl10 as text
%        str2double(get(hObject,'String')) returns contents of tl10 as a double


% --- Executes during object creation, after setting all properties.
function tl10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tl10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start10_Callback(hObject, eventdata, handles)
% hObject    handle to start10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start10 as text
%        str2double(get(hObject,'String')) returns contents of start10 as a double


% --- Executes during object creation, after setting all properties.
function start10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
