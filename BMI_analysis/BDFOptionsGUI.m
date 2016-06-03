function varargout = BDFOptionsGUI(varargin)
% BDFOPTIONSGUI MATLAB code for BDFOptionsGUI.fig
%      BDFOPTIONSGUI, by itself, creates a new BDFOPTIONSGUI or raises the existing
%      singleton*.
%
%      H = BDFOPTIONSGUI returns the handle to a new BDFOPTIONSGUI or the handle to
%      the existing singleton*.
%
%      BDFOPTIONSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BDFOPTIONSGUI.M with the given input arguments.
%
%      BDFOPTIONSGUI('Property','Value',...) creates a new BDFOPTIONSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BDFOptionsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BDFOptionsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BDFOptionsGUI

% Last Modified by GUIDE v2.5 01-Jun-2015 17:23:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BDFOptionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BDFOptionsGUI_OutputFcn, ...
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


% --- Executes just before BDFOptionsGUI is made visible.
function BDFOptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BDFOptionsGUI (see VARARGIN)

% Choose default command line output for BDFOptionsGUI
handles.output = hObject;
handles.OK = 0;
% handles.labnumberedit = 1;
% handles.rotatehandlecheckbox = 0;
% handles.ignore_jumps_chkbox = 1;

if nargin > 3
    BDF_opts = varargin{1};
    set(handles.labnumberedit,'String',num2str(BDF_opts.labnum));
    set(handles.labnumberedit,'Value',BDF_opts.labnum);
    set(handles.rotatehandlecheckbox,'Value',BDF_opts.rothandle);
    set(handles.ignore_jumps_chkbox,'Value',BDF_opts.ignore_jumps);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BDFOptionsGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BDFOptionsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if handles.OK
        out_struct = struct(...
                    'labnum',       get(handles.labnumberedit,'Value'),...
                    'rothandle',    get(handles.rotatehandlecheckbox, 'Value'),...
                    'ignore_jumps', get(handles.ignore_jumps_chkbox, 'Value'));
    else
        out_struct = [];
    end
    
    varargout = {out_struct};
    close(handles.figure1);
    drawnow;


% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OK = 1;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);



function labnumberedit_Callback(hObject, eventdata, handles)
% hObject    handle to labnumberedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.labnumberedit, 'value',str2double(get(hObject,'String')));
% Hints: get(hObject,'String') returns contents of labnumberedit as text
%        str2double(get(hObject,'String')) returns contents of labnumberedit as a double


% --- Executes during object creation, after setting all properties.
function labnumberedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labnumberedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotatehandlecheckbox.
function rotatehandlecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to rotatehandlecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rotatehandlecheckbox, 'value',(get(hObject,'Value')));
% Hint: get(hObject,'Value') returns toggle state of rotatehandlecheckbox


% --- Executes on button press in ignore_jumps_chkbox.
function ignore_jumps_chkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ignore_jumps_chkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ignore_jumps_chkbox, 'value',(get(hObject,'Value')));
% Hint: get(hObject,'Value') returns toggle state of ignore_jumps_chkbox
