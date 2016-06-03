function varargout = BuildModelGUI(varargin)
% BUILDMODELGUI M-file for BuildModelGUI.fig
%      BUILDMODELGUI, by itself, creates a new BUILDMODELGUI or raises the existing
%      singleton*.
%
%      H = BUILDMODELGUI returns the handle to a new BUILDMODELGUI or the handle to
%      the existing singleton*.
%
%      BUILDMODELGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUILDMODELGUI.M with the given input
%      arguments.
%
%      BUILDMODELGUI('Property','Value',...) creates a new BUILDMODELGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BuildModelGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BuildModelGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BuildModelGUI

% Last Modified by GUIDE v2.5 01-Oct-2012 17:06:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BuildModelGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BuildModelGUI_OutputFcn, ...
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


% --- Executes just before BuildModelGUI is made visible.
function BuildModelGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BuildModelGUI (see VARARGIN)

% Choose default command line output for BuildModelGUI
handles.output = hObject;
handles.binsize = 0.05;
handles.statelabels = [];

if nargin>3 handles.binsize = varargin{1}; end
if nargin>4 handles.statelabels = varargin{2}; end
handles.OK = 0;

% Update handles structure
guidata(hObject, handles);

set(handles.binsize_txt,'String',[ 'BinnedData binsize : ' num2str(handles.binsize*1000) ' ms' ]);
set(handles.States_popup,'String', [{'Don''t use State Dep'}; handles.statelabels]);

% UIWAIT makes BuildModelGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = BuildModelGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
        
    options = struct(...
    'PredEMGs', get(handles.EMG_cbx,'Value'),...
    'PredForce',get(handles.Force_cbx,'Value'),...
    'PredCursPos',get(handles.CursPos_cbx,'Value'),...
    'PredVeloc',get(handles.Veloc_cbx,'Value'),...
    'fillen',get(handles.fillen_txtbx,'Value'),...
    'UseAllInputs',get(handles.Inputs_popup,'Value')-1,...
    'PolynomialOrder',get(handles.Polyn_Order_txtbx,'Value'),...
    'numPCs',0,...
    'Use_Thresh',get(handles.useThresh_cbx,'Value'),...
    'Use_EMGs',get(handles.EMGsInputRadio,'Value'),...
    'Use_Ridge',get(handles.Ridge_popup,'Value')-1,...
    'Use_SD',get(handles.States_popup,'Value')-1 ...
    );
    
%     xval_flag = get(handles.mfxval_checkbox,'Value');
%     foldlength = get(handles.Fold_length_txtbx,'Value');

    if ~handles.OK
        options = [];
    end
    varargout = {options};
    close(handles.figure1);

% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    %Check that all parameters are valid
    if mod(round(1000*get(handles.fillen_txtbx,'Value')),round(1000*handles.binsize))
        %1- Check that filter length is a multiple of binsize
        errordlg('Filter Length must be a multiple of binsize','Stop farting around!');
    elseif get(handles.Polyn_Order_txtbx,'Value')>8 || get(handles.Polyn_Order_txtbx,'Value') <0
        %2- check that the polynomial order is within reasonable limits
        errordlg('Polynomial Order must be between 0 and 8','Stop farting around!');
    else
        handles.OK =1;
        % Update handles structure
        guidata(hObject, handles);
        uiresume(handles.figure1);
    end

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1); 
    
function fillen_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to fillen_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fillen_txtbx as text
%        str2double(get(hObject,'String')) returns contents of fillen_txtbx as a double
    set(handles.fillen_txtbx, 'value',str2double(get(hObject,'String'))/1000 );


% --- Executes during object creation, after setting all properties.
function fillen_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fillen_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
       
    
% --- Executes on selection change in Inputs_popup.
function Inputs_popup_Callback(hObject, eventdata, handles)
% hObject    handle to Inputs_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Inputs_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Inputs_popup

% selection = get(hObject,'String');
% if strcmp(selection,'Use All Inputs')
%     set(hObject,'Value',0);
% else
%     set(hObject,'Value',1);
% end
    


% --- Executes during object creation, after setting all properties.
function Inputs_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inputs_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Polyn_Order_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to Polyn_Order_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Polyn_Order_txtbx as text
%        str2double(get(hObject,'String')) returns contents of Polyn_Order_txtbx as a double
    set(handles.Polyn_Order_txtbx, 'value',str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function Polyn_Order_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Polyn_Order_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EMG_cbx.
function EMG_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to EMG_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EMG_cbx


% --- Executes on button press in Force_cbx.
function Force_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Force_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Force_cbx


% --- Executes on button press in CursPos_cbx.
function CursPos_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to CursPos_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CursPos_cbx

% --- Executes on button press in Veloc_cbx.
function Veloc_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Veloc_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Veloc_cbx


% --- Executes on button press in State_cbx.
function State_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to State_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of State_cbx


% --- Executes on selection change in States_popup.
function States_popup_Callback(hObject, eventdata, handles)
% hObject    handle to States_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns States_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from States_popup


% --- Executes during object creation, after setting all properties.
function States_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to States_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useThresh_cbx.
function useThresh_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to useThresh_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useThresh_cbx


% --------------------------------------------------------------------
function uipanel1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Ridge_popup_Callback(hObject, eventdata, handles)
% hObject    handle to Ridge_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Ridge_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Ridge_popup


% --- Executes during object creation, after setting all properties.
function Ridge_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ridge_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
