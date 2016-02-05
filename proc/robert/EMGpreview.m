function varargout = EMGpreview(varargin)
% EMGPREVIEW M-file for EMGpreview.fig
%      EMGPREVIEW, by itself, creates a new EMGPREVIEW or raises the existing
%      singleton*.
%
%      H = EMGPREVIEW returns the handle to a new EMGPREVIEW or the handle to
%      the existing singleton*.
%
%      EMGPREVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMGPREVIEW.M with the given input arguments.
%
%      EMGPREVIEW('Property','Value',...) creates a new EMGPREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EMGpreview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EMGpreview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EMGpreview

% Last Modified by GUIDE v2.5 15-Apr-2011 09:43:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EMGpreview_OpeningFcn, ...
                   'gui_OutputFcn',  @EMGpreview_OutputFcn, ...
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


% --- Executes just before EMGpreview is made visible.
function EMGpreview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EMGpreview (see VARARGIN)

% Choose default command line output for EMGpreview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EMGpreview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EMGpreview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fileList.
function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileList

allFileList=cellstr(get(hObject,'String'));
selectedFile=fullfile(handles.PathName,[allFileList{get(hObject,'Value')},'EMGonly.mat']);
fprintf(1,'plotting %s\n',allFileList{get(hObject,'Value')})
if exist(selectedFile,'file')~=0
    load(selectedFile)
else
    fprintf(1,'error: %s does not exist\n',selectedFile)
end
% clear out previous axes
delete(findobj(gcf,'Type','axes'))
% plot EMGs
for n=1:4
    axes('Parent',gcf,'Position',[0.25 1-n*0.25+0.03 0.73 0.17])
    plot(bdfEMGonly.emg.data(:,1),bdfEMGonly.emg.data(:,1+n))
    ylabel(bdfEMGonly.emg.emgnames{n})
end

disp('done')

% --------------------------------------------------------------------
function menubar_file_selectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to menubar_file_selectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\', ...
    'select folder with data files');
Files=dir(handles.PathName);
Files(1:2)=[];
FileNames={Files.name};
EMGpreviewFiles=FileNames(cellfun(@isempty,regexp(FileNames,'EMGonly'))==0);
for n=1:length(EMGpreviewFiles)
    EMGpreviewFiles{n}=EMGpreviewFiles{n}(1:regexp(EMGpreviewFiles{n},'EMGonly')-1);
end
set(handles.fileList,'String',EMGpreviewFiles)
set(handles.fileList,'Value',[])
guidata(handles.figure1,handles)


% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menubar_file_Callback(hObject, eventdata, handles)
% hObject    handle to menubar_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
