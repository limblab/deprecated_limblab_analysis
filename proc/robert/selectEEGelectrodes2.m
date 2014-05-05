function varargout = selectEEGelectrodes2(varargin)
% SELECTEEGELECTRODES2 M-file for selectEEGelectrodes2.fig
%      SELECTEEGELECTRODES2, by itself, creates a new SELECTEEGELECTRODES2 or raises the existing
%      singleton*.
%
%      H = SELECTEEGELECTRODES2 returns the handle to a new SELECTEEGELECTRODES2 or the handle to
%      the existing singleton*.
%
%      SELECTEEGELECTRODES2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTEEGELECTRODES2.M with the given input arguments.
%
%      SELECTEEGELECTRODES2('Property','Value',...) creates a new SELECTEEGELECTRODES2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectEEGelectrodes2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectEEGelectrodes2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help selectEEGelectrodes2

% Last Modified by GUIDE v2.5 06-Jan-2006 17:12:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectEEGelectrodes2_OpeningFcn, ...
                   'gui_OutputFcn',  @selectEEGelectrodes2_OutputFcn, ...
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


% --- Executes just before selectEEGelectrodes2 is made visible.
function selectEEGelectrodes2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectEEGelectrodes2 (see VARARGIN)

% Choose default command line output for selectEEGelectrodes2
handles.output = '';

set(gcf,'Color',[1 1 1])
capPic=imread('E:\s1_analysis\proc\robert\TMSi_CA-106_electrodeMap.png','png');
image(capPic,'Parent',handles.axes3)
set(handles.axes3,'Visible','off')

[pathstr,junk,junk]=fileparts(get(handles.figure1,'FileName'));
clear junk
arrowPic=imread([pathstr,filesep,'arrow.tif'],'tiff');
image(arrowPic(15:45,:,:),'Parent',handles.rightArrow)
set(handles.rightArrow,'Visible','off')
image(arrowPic(55:90,:,:),'Parent',handles.leftArrow)
set(handles.leftArrow,'Visible','off')

% badEventList=usuallyBadEvents;
if length(varargin)>1
	badEventList=rowBoat(varargin{2})';
end
eventsIn=varargin{1};
eventsIn(cellfun('isempty',eventsIn))=[];

set(handles.eventsExcluded,'String',eventsIn(ismember(eventsIn,badEventList)));
set(handles.eventsIncluded,'String',setdiff(eventsIn,badEventList));
guidata(hObject, handles);

if ispc, set(handles.text3,'FontSize',8), set(handles.text4,'FontSize',8),
    colorVec=[0.702 0.702 0.702];
    set(gcf,'Color',colorVec), set(handles.text3,'BackgroundColor',colorVec),
    set(handles.text4,'BackgroundColor',colorVec)
end

% UIWAIT makes selectEEGelectrodes2 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectEEGelectrodes2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1)

% --- Executes on button press in addEvents.
function addEvents_Callback(hObject, eventdata, handles)
% hObject    handle to addEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eventAdd=get(handles.eventsExcluded,'Value');
excludedEventNames=get(handles.eventsExcluded,'String');
includedEventNames=sortrows([get(handles.eventsIncluded,'String'); ...
    excludedEventNames(eventAdd)]);
set(handles.eventsIncluded,'String',includedEventNames);
excludedEventNames(eventAdd)=[];
set(handles.eventsExcluded,'Value',[]);
set(handles.eventsExcluded,'String',excludedEventNames);
handles.output=get(handles.eventsIncluded,'String');
guidata(hObject,handles)

% --- Executes on button press in deleteEvents.
function deleteEvents_Callback(hObject, eventdata, handles)
% hObject    handle to deleteEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eventDelete=get(handles.eventsIncluded,'Value');
includedEventNames=get(handles.eventsIncluded,'String');
excludedEventNames=sortrows([get(handles.eventsExcluded,'String'); ...
    includedEventNames(eventDelete)]);
set(handles.eventsExcluded,'String',excludedEventNames);
includedEventNames(eventDelete)=[];
set(handles.eventsIncluded,'Value',[]);
set(handles.eventsIncluded,'String',includedEventNames);
handles.output=get(handles.eventsIncluded,'String');
guidata(hObject,handles)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=get(handles.eventsIncluded,'String');
guidata(hObject,handles)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% --- Executes on selection change in eventsExcluded.
function eventsExcluded_Callback(hObject, eventdata, handles)
% hObject    handle to eventsExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns eventsExcluded contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventsExcluded

% --- Executes on selection change in eventsIncluded.
function eventsIncluded_Callback(hObject, eventdata, handles)
% hObject    handle to eventsIncluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns eventsIncluded contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventsIncluded

% --- Executes during object creation, after setting all properties.
function eventsExcluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventsExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function eventsIncluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventsIncluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end