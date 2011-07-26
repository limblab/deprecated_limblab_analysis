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

% Last Modified by GUIDE v2.5 26-Jul-2011 14:15:47

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
handles.binsize = varargin{1};
handles.statelabels = varargin{2};

% Update handles structure
guidata(hObject, handles);

set(handles.binsize_txt,'String',[ 'BinnedData binsize : ' num2str(handles.binsize*1000) ' ms' ]);
set(handles.States_popup,'String', [{'Don''t use State Dep'}; handles.statelabels]);

% --- Outputs from this function are returned to the command line.
function varargout = BuildModelGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

    % UIWAIT makes BuildModelGUI wait for user response (see UIRESUME)
    uiwait(handles.figure1);

    lagtime = get(handles.fillen_txtbx,'Value');
    Inputs = get(handles.Inputs_popup,'Value')-1;
    Polyn_Order = get(handles.Polyn_Order_txtbx,'Value');
    Pred_EMG = get(handles.EMG_cbx,'Value');
    Pred_Force = get(handles.Force_cbx,'Value');
    Pred_CursPos = get(handles.CursPos_cbx,'Value');
    Pred_Veloc = get(handles.Veloc_cbx,'Value');
    Use_State = get(handles.States_popup,'Value')-1;
    Use_Thresh = get(handles.useThresh_cbx,'Value');
    
%     xval_flag = get(handles.mfxval_checkbox,'Value');
%     foldlength = get(handles.Fold_length_txtbx,'Value');
     
%     varargout = {lagtime, Inputs, Polyn_Order, xval_flag, foldlength};
     varargout = {lagtime, Inputs, Polyn_Order,Pred_EMG,Pred_Force,Pred_CursPos,Pred_Veloc,Use_State,Use_Thresh};
      
    set(handles.figure1,'Visible','off');
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
        uiresume(handles.figure1);
    end

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


