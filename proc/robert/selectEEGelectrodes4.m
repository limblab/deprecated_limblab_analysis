function varargout = selectEEGelectrodes4(varargin)
% SELECTEEGELECTRODES4 M-file for selectEEGelectrodes4.fig
%      SELECTEEGELECTRODES4, by itself, creates a new SELECTEEGELECTRODES4 or raises the existing
%      singleton*.
%
%      H = SELECTEEGELECTRODES4 returns the handle to a new SELECTEEGELECTRODES4 or the handle to
%      the existing singleton*.
%
%      SELECTEEGELECTRODES4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTEEGELECTRODES4.M with the given input arguments.
%
%      SELECTEEGELECTRODES4('Property','Value',...) creates a new SELECTEEGELECTRODES4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectEEGelectrodes2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectEEGelectrodes4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help selectEEGelectrodes4

% Last Modified by GUIDE v2.5 18-Jun-2014 20:05:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectEEGelectrodes4_OpeningFcn, ...
                   'gui_OutputFcn',  @selectEEGelectrodes4_OutputFcn, ...
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


% --- Executes just before selectEEGelectrodes4 is made visible.
function selectEEGelectrodes4_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectEEGelectrodes4 (see VARARGIN)

% Choose default command line output for selectEEGelectrodes4
handles.output = '';

set(gcf,'Color',[1 1 1])
capPic=imread('E:\s1_analysis\proc\robert\TMSi_CA-106_electrodeMap.png','png');
image(capPic,'Parent',handles.axes3)
set(handles.axes3,'Visible','off')

[pathstr,junk,junk]=fileparts(get(handles.figure1,'FileName'));                 %#ok<*ASGLU,*NASGU>
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

included=setdiff(eventsIn,badEventList);
set(handles.eventsIncluded,'String',included);
numbered=unique(regexp(included,'[A-Z]+(?=[0-9])','match','once'));
numbered(cellfun(@isempty,numbered))=[];
refs=unique(regexp(included,'[A-Z]+(?=[a-z])','match','once'));
refs(cellfun(@isempty,refs))=[];
% add in even,odd designations.
numbers=regexp(included,'(?<=[A-Za-z]*)[0-9]+','match','once');
numbers(cellfun(@isempty,numbers))=[];
numbers=cellfun(@str2num,numbers);
inclGrpLabStr=unique([numbered, refs]);
if any(mod(numbers,2));
    inclGrpLabStr=[inclGrpLabStr, 'odd'];
end
if any(mod(numbers,2)==0);
    inclGrpLabStr=[inclGrpLabStr, 'even'];
end
set(handles.includedGroups_listBox,'String',inclGrpLabStr)

excluded=eventsIn(ismember(eventsIn,badEventList));
set(handles.eventsExcluded,'String',excluded);
numbered=unique(regexp(excluded,'[A-Z]+(?=[0-9])','match','once'));
numbered(cellfun(@isempty,numbered))=[];
refs=unique(regexp(excluded,'[A-Z]+(?=[a-z])','match','once'));
refs(cellfun(@isempty,refs))=[];
% add in even,odd designations.
numbers=regexp(excluded,'(?<=[A-Za-z]*)[0-9]+','match','once');
numbers(cellfun(@isempty,numbers))=[];
numbers=cellfun(@str2num,numbers);
exclGrpLabStr=unique([rowBoat(numbered); rowBoat(refs)]);
if any(mod(numbers,2));
    exclGrpLabStr=[exclGrpLabStr; 'odd'];
end
if any(mod(numbers,2)==0);
    exclGrpLabStr=[exclGrpLabStr; 'even'];
end
set(handles.excludedGroups_listBox,'String',exclGrpLabStr)

% handles.includedGroups_listBox
guidata(hObject, handles);

if ispc, set(handles.text3,'FontSize',8), set(handles.text4,'FontSize',8),
    colorVec=[0.702 0.702 0.702];
    set(gcf,'Color',colorVec), set(handles.text3,'BackgroundColor',colorVec),
    set(handles.text4,'BackgroundColor',colorVec)
end

% UIWAIT makes selectEEGelectrodes4 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectEEGelectrodes4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1)

% --- Executes on button press in addEvents.
function addEvents_Callback(hObject, eventdata, handles)                    %#ok<*DEFNU>
% hObject    handle to addEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eventAdd=get(handles.eventsExcluded,'Value');
excludedEventNames=get(handles.eventsExcluded,'String');
includedEventNames=sortrows([get(handles.eventsIncluded,'String'); ...
    excludedEventNames(eventAdd)]);
set(handles.eventsIncluded,'String',includedEventNames);
% also add in group name to existing group names included
grpToInclude=unique(regexp(excludedEventNames(eventAdd), ...
    '[A-Z]+(?=[a-z0-9])','match','once'));
includedGroups=unique([get(handles.includedGroups_listBox,'String'); ...
    grpToInclude]);
set(handles.includedGroups_listBox,'String',includedGroups,'Value',[])

% adjust excluded event list
excludedEventNames(eventAdd)=[];
set(handles.eventsExcluded,'Value',[]);
set(handles.eventsExcluded,'String',excludedEventNames);
% also, delete group name from existing group names excluded, if none left
excludedGroups=get(handles.excludedGroups_listBox,'String');
for n=1:length(grpToInclude)
    if ~nnz(strcmp(grpToInclude{n},...
        regexp(excludedEventNames,'[A-Z]+(?=[a-z0-9])','match','once')))
        excludedGroups=setdiff(excludedGroups,grpToInclude{n});
    end
end
set(handles.excludedGroups_listBox,'String',excludedGroups,'Value',[])

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
% also add in group name to existing group names excluded
grpToExclude=unique(regexp(includedEventNames(eventDelete), ...
    '[A-Z]+(?=[a-z0-9])','match','once'));
excludedGroups=unique([get(handles.excludedGroups_listBox,'String'); ...
    grpToExclude]);
set(handles.excludedGroups_listBox,'String',excludedGroups,'Value',[])

% adjust included event list
includedEventNames(eventDelete)=[];
set(handles.eventsIncluded,'Value',[]);
set(handles.eventsIncluded,'String',includedEventNames);
% also, delete group name from existing group names included, if none left.
includedGroups=get(handles.includedGroups_listBox,'String');
for n=1:length(grpToExclude)
    if ~nnz(strcmp(grpToExclude{n},...
        regexp(includedEventNames,'[A-Z]+(?=[a-z0-9])','match','once')))
        includedGroups=setdiff(includedGroups,grpToExclude{n});
    end
end
set(handles.includedGroups_listBox,'String',includedGroups,'Value',[])

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
function eventsExcluded_Callback(hObject, eventdata, handles)               %#ok<*INUSD>
% hObject    handle to eventsExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in eventsIncluded.
function eventsIncluded_Callback(hObject, eventdata, handles)
% hObject    handle to eventsIncluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on selection change in includedGroups_listBox.
function includedGroups_listBox_Callback(hObject, eventdata, handles)
% hObject    handle to includedGroups_listBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allGroups=cellstr(get(hObject,'String'));
selectedGroups=allGroups(get(hObject,'Value'));
% select everything in the eventsIncluded listbox that matches the pattern
% found in selectedGroups
allChannels=get(handles.eventsIncluded,'String');
regions=regexp(allChannels,'[A-Z]+(?=[a-z0-9])','match','once');
currentSet=find(ismember(regions,selectedGroups));
% account for selection of 'even' or 'odd'
numbered=regexp(allChannels,'(?<=[A-Za-z]+)[0-9]+','match','once');
odds=find(mod(cellfun(@str2double,numbered),2));
evens=find(mod(cellfun(@str2double,numbered),2)==0);
nonNumbered=find(isnan(mod(cellfun(@str2double,numbered),2)));
odds=setdiff(odds,nonNumbered);
evens=setdiff(evens,nonNumbered);
if nnz(cellfun(@isempty,regexp(selectedGroups,'odd'))==0)
    currentSet=unique([rowBoat(currentSet); rowBoat(odds)]);
end
if nnz(cellfun(@isempty,regexp(selectedGroups,'even'))==0)
    currentSet=unique([rowBoat(currentSet); rowBoat(evens)]);
end
set(handles.eventsIncluded,'Value',currentSet)


% --- Executes during object creation, after setting all properties.
function includedGroups_listBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to includedGroups_listBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in excludedGroups_listBox.
function excludedGroups_listBox_Callback(hObject, eventdata, handles)
% hObject    handle to excludedGroups_listBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allGroups=cellstr(get(hObject,'String'));
selectedGroups=allGroups(get(hObject,'Value'));
% select everything in the eventsExcluded listbox that matches the pattern
% found in selectedGroups
allChannels=get(handles.eventsExcluded,'String');
regions=regexp(allChannels,'[A-Z]+(?=[a-z0-9])','match','once');
currentSet=find(ismember(regions,selectedGroups));
% account for selection of 'even' or 'odd'
numbered=regexp(allChannels,'(?<=[A-Za-z]+)[0-9]+','match','once');
odds=find(mod(cellfun(@str2double,numbered),2));
evens=find(mod(cellfun(@str2double,numbered),2)==0);
nonNumbered=find(isnan(mod(cellfun(@str2double,numbered),2)));
odds=setdiff(odds,nonNumbered);
evens=setdiff(evens,nonNumbered);
if nnz(cellfun(@isempty,regexp(selectedGroups,'odd'))==0)
    currentSet=unique([rowBoat(currentSet); rowBoat(odds)]);
end
if nnz(cellfun(@isempty,regexp(selectedGroups,'even'))==0)
    currentSet=unique([rowBoat(currentSet); rowBoat(evens)]);
end
set(handles.eventsExcluded,'Value',currentSet)


% --- Executes during object creation, after setting all properties.
function excludedGroups_listBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excludedGroups_listBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuBar_toolsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to menuBar_toolsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuBar_tools_drawBox_Callback(hObject, eventdata, handles)
% hObject    handle to menuBar_tools_drawBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
origUnits=get(gcf,'Units');
set(gcf,'Units','normalized')
t=waitforbuttonpress;
finalRect=rbbox; disp(finalRect)
set(gcf,'Units',origUnits)


% --------------------------------------------------------------------
function menuBar_tools_showAxes_Callback(hObject, eventdata, handles)
% hObject    handle to menuBar_tools_showAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

origUnits=get(gcf,'Units');
set(gcf,'Units','normalized')
[elecCoords,elecNames,raw]= ...
    xlsread('E:\s1_analysis\proc\robert\TMSi_CA-106_electrodePositions.xlsx');
clear raw
chansIncluded=get(handles.eventsIncluded,'String');
[axIncluded,axInd,chanInd]=intersect(deblank(elecNames),chansIncluded);
% find & delete the previously shown set
existingAxHandles=findobj(gcf,'Type','Axes');
delete(existingAxHandles(cellfun(@isempty, ...
    regexp(get(existingAxHandles,'Tag'),'.*_electrodeAxis'))==0))
for n=1:numel(axInd)
    axHandles(n)=axes('OuterPosition', ...
        elecCoords(axInd(n),2:5)+[0.022 0.02 0.0075 0.01]);
    set(axHandles(n),'Position',get(axHandles(n),'OuterPosition'), ...
        'XTick',[],'YTick',[])    
end
set(gcf,'Units',origUnits)
disp('done')



