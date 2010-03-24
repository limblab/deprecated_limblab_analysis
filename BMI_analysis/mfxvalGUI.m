function varargout = mfxvalGUI(varargin)
% MFXVALGUI M-file for mfxvalGUI.fig
%      MFXVALGUI, by itself, creates a new MFXVALGUI or raises the existing
%      singleton*.
%
%      H = MFXVALGUI returns the handle to a new MFXVALGUI or the handle to
%      the existing singleton*.
%
%      MFXVALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MFXVALGUI.M with the given input
%      arguments.
%
%      MFXVALGUI('Property','Value',...) creates a new MFXVALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mfxvalGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mfxvalGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mfxvalGUI

% Last Modified by GUIDE v2.5 17-Sep-2009 11:00:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mfxvalGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mfxvalGUI_OutputFcn, ...
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


% --- Executes just before mfxvalGUI is made visible.
function mfxvalGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mfxvalGUI (see VARARGIN)

% Choose default command line output for mfxvalGUI
handles.output = hObject;
handles.binsize = varargin{1};

% Update handles structure
guidata(hObject, handles);

set(handles.binsize_txt,'String',[ 'BinnedData binsize : ' num2str(handles.binsize*1000) ' ms' ]);



% --- Outputs from this function are returned to the command line.
function varargout = mfxvalGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

    % UIWAIT makes mfxvalGUI wait for user response (see UIRESUME)
    uiwait(handles.figure1);

    lagtime = get(handles.fillen_txtbx,'Value');
    Inputs = get(handles.Inputs_popup,'Value')-1;
    Polyn_Order = get(handles.Polyn_Order_txtbx,'Value');
    foldlength = get(handles.fold_length_txtbx,'Value');
    PredEMGs = get(handles.PredEMG_cbx, 'Value');
    PredForce = get(handles.PredForce_cbx, 'Value');
    PredCurs = get(handles.PredCurs_cbx, 'Value');
    Use_Thresh = get(handles.Thresh_cbx, 'Value');
     
%     varargout = {lagtime, Inputs, Polyn_Order, xval_flag, foldlength};
     varargout = {lagtime, Inputs, Polyn_Order, foldlength, PredEMGs, PredForce, PredCurs, Use_Thresh};
      
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
    elseif get(handles.Polyn_Order_txtbx,'Value')>4 || get(handles.Polyn_Order_txtbx,'Value') <1
        %2- check that the polynomial order is within reasonable limits
        errordlg('Polynomial Order must be between 1 and 4','Stop farting around!');
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



function fold_length_txtbx_Callback(hObject, eventdata, handles)
% hObject    handle to fold_length_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fold_length_txtbx as text
%        str2double(get(hObject,'String')) returns contents of fold_length_txtbx as a double
set(handles.fold_length_txtbx, 'value',str2double(get(hObject,'String')) );

% --- Executes during object creation, after setting all properties.
function fold_length_txtbx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fold_length_txtbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PredEMG_cbx.
function PredEMG_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to PredEMG_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PredEMG_cbx


% --- Executes on button press in PredForce_cbx.
function PredForce_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to PredForce_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PredForce_cbx


% --- Executes on button press in PredCurs_cbx.
function PredCurs_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to PredCurs_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PredCurs_cbx


% --- Executes on button press in Thresh_cbx.
function Thresh_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to Thresh_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Thresh_cbx


