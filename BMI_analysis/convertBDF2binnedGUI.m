function varargout = convertBDF2binnedGUI(varargin)
% CONVERTBDF2BINNEDGUI M-file for convertBDF2binnedGUI.fig
%      CONVERTBDF2BINNEDGUI, by itself, creates a new CONVERTBDF2BINNEDGUI or raises the existing
%      singleton*.
%
%      H = CONVERTBDF2BINNEDGUI returns the handle to a new CONVERTBDF2BINNEDGUI or the handle to
%      the existing singleton*.
%
%      CONVERTBDF2BINNEDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONVERTBDF2BINNEDGUI.M with the given input arguments.
%
%      CONVERTBDF2BINNEDGUI('Property','Value',...) creates a new CONVERTBDF2BINNEDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before convertBDF2binnedGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to convertBDF2binnedGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help convertBDF2binnedGUI

% Last Modified by GUIDE v2.5 02-Oct-2012 11:11:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @convertBDF2binnedGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @convertBDF2binnedGUI_OutputFcn, ...
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


% --- Executes just before convertBDF2binnedGUI is made visible.
function convertBDF2binnedGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to convertBDF2binnedGUI (see VARARGIN)

% Choose default command line output for convertBDF2binnedGUI
handles.output = hObject;
handles.OK = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes convertBDF2binnedGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = convertBDF2binnedGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

    if handles.OK
        binsize = get(handles.binsize_txtbx,'Value');
        startTime = get(handles.startTime_txtbx, 'Value');
        stopTime = get(handles.stopTime_txtbx, 'Value');
        HP = get(handles.HP_txtbx, 'Value');
        LP = get(handles.LP_txtbx, 'Value');
        MFR = get(handles.MFR_txtbx, 'Value');
        NormData = get(handles.Normalize_cbx,'Value');
        FindStates = get(handles.State_cbx,'Value');
        Unsorted = get(handles.Unsorted_cbx,'Value');
        TriKernel = get(handles.Triangle_cbx,'Value');
        sig = get(handles.Sigma_txtbx, 'Value');
        varargout = {binsize startTime stopTime HP LP MFR NormData FindStates Unsorted TriKernel sig};
    else
        for i=1:nargout
            varargout{i} = [];
        end
    end
    
    close(handles.figure1);



function binsize_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to binsize_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binsize_txtbx as text
%        str2double(get(hObject,'String')) returns contents of binsize_txtbx as a double
    set(handles.binsize_txtbx, 'value',str2double(get(hObject,'String'))/1000 );


% --- Executes during object creation, after setting all properties.
function binsize_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binsize_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.OK = 1;
    % Update handles structure
    guidata(hObject, handles);
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
    val = str2double(get(handles.stopTime_txtbx, 'String'));
    if isnumeric(val) && val>get(handles.binsize_txtbx,'Value')/1000
        set(handles.stopTime_txtbx, 'Value', val);
    elseif strcmp(val, 'end')
        set(handles.stopTime_txtbx, 'Value', 0.0)
    else
        disp('Invalid value for ''Stop Time''');
        set(handles.stopTime_txtbx, 'Value', 0.0);
        set(handles.stopTime_txtbx, 'String', 'end');
    end
        

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


function HP_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to HP_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HP_txtbx as text
%        str2double(get(hObject,'String')) returns contents of HP_txtbx as a double
     set(handles.HP_txtbx, 'Value', str2double(get(hObject,'String')) );

% --- Executes during object creation, after setting all properties.
function HP_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HP_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LP_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to LP_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LP_txtbx as text
%        str2double(get(hObject,'String')) returns contents of LP_txtbx as a double
     set(handles.LP_txtbx, 'Value', str2double(get(hObject,'String')) );
      
% --- Executes during object creation, after setting all properties.
function LP_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LP_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
   

function MFR_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to MFR_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MFR_txtbx as text
%        str2double(get(hObject,'String')) returns contents of MFR_txtbx as a double
    set(handles.MFR_txtbx, 'Value', str2double(get(hObject,'String')) );

% --- Executes during object creation, after setting all properties.
function MFR_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MFR_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Normalize_cbx.
function Normalize_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Normalize_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Normalize_cbx


% --- Executes on button press in State_cbx.
function State_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to State_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of State_cbx



function Sigma_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to Sigma_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sigma_txtbx as text
%        str2double(get(hObject,'String')) returns contents of Sigma_txtbx as a double
set(handles.Sigma_txtbx, 'Value', str2double(get(hObject,'String')) );


% --- Executes during object creation, after setting all properties.
function Sigma_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sigma_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Triangle_cbx.
function Triangle_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Triangle_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Triangle_cbx
get(hObject,'Value');


% --- Executes on button press in Unsorted_cbx.
function Unsorted_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Unsorted_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Unsorted_cbx
get(hObject,'Value');


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
