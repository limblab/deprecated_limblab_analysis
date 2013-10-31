function varargout = test_sort(varargin)
% TEST_SORT MATLAB code for test_sort.fig
%      TEST_SORT, by itself, creates a new TEST_SORT or raises the existing
%      singleton*.
%
%      H = TEST_SORT returns the handle to a new TEST_SORT or the handle to
%      the existing singleton*.
%
%      TEST_SORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_SORT.M with the given input arguments.
%
%      TEST_SORT('Property','Value',...) creates a new TEST_SORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_sort_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_sort_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_sort

% Last Modified by GUIDE v2.5 06-Sep-2013 15:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_sort_OpeningFcn, ...
                   'gui_OutputFcn',  @test_sort_OutputFcn, ...
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

end
% --- Executes just before test_sort is made visible.
function test_sort_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to test_sort (see VARARGIN)

    % Choose default command line output for test_sort
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes test_sort wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

end
% --- Outputs from this function are returned to the command line.
function varargout = test_sort_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

end
% --- Executes on button press in AddCluster_pushbutton.
function AddCluster_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to AddCluster_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in DeleteCluster_pushbutton.
function DeleteCluster_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to DeleteCluster_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in RemoveFromCluster_pushbutton.
function RemoveFromCluster_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to RemoveFromCluster_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in AddToCluster_pushbutton.
function AddToCluster_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to AddToCluster_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in InvalidateSPikes_pushbutton.
function InvalidateSPikes_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to InvalidateSPikes_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in DeleteSpikes_pushbutton.
function DeleteSpikes_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to DeleteSpikes_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in LoadFile_pushbutton.
function LoadFile_pushbutton_Callback(hObject, eventdata, handles)
    % hObject    handle to LoadFile_pushbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    %have user select file
        [FileName,PathName,FilterIndex] = uigetfile('*','Select File');
        disp(strcat('Now loading selected file: ',PathName,FileName))
    %load into NEVNSx object
        handles.NEVNSx=load_NEVNSX_object([PathName,FileName]);
        
        %clear any old values:
        mask=[];
            handles.Waveform_data=[];
            handles.PC=[];
            handles.peak=[];
            handles.valley=[];
            %handles.Nonlinear_energy=[]
            handles.Timestamp=[];
        
        
    %compute clustering data (PC, peak-valley etc.)
        %get number of unique electrodes:
        handles.Channel_numbers=unique(handles.NEVNSx.NEV.Data.Spikes.Electrode);
        
        for i=1:length(handles.Channel_numbers)
            mask=find(handles.NEVNSx.NEV.Data.Spikes.Electrode==handles.Channel_numbers(i));
            handles.Waveform_data=double(handles.NEVNSx.NEV.Data.Spikes.Waveform(:,mask));
            handles.PC{i}=pca(handles.Waveform_data');
            handles.Peak{i}=max(handles.Waveform_data,[],1);
            handles.Valley{i}=min(handles.Waveform_data,[],1);
            %handles.Nonlinear_energy{i}=
            handles.Timestamp{i}=handles.NEVNSx.NEV.Data.Spikes.TimeStamp(mask);
        end
        guidata(hObject,handles)
    %populate local copies of data for editing and working 
        disp('Done loading file. Now setting the channel and populating current variables')
        Channel_selection_Callback(handles.Channel_selection, eventdata, handles)
    % Save the handles structure.
        guidata(hObject,handles)
end
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
    % hObject    handle to listbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listbox1

end
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end
% --- Executes on selection change in Axis1_popupmenu.
function outdata=Axis1_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to Axis1_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns Axis1_popupmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from Axis1_popupmenu
    
    %get the data we are populating and the channel we are working with
        str = get(handles.Axis1_popupmenu, 'String');
        val = get(handles.Axis1_popupmenu,'Value');
        disp(strcat('Axis1 data set to: ',str{val},'. updating'))
        handles.Cluster_Xdata=set_local_axis_data(str{val},handles);

    % Save the handles structure.
        guidata(hObject,handles)
    %since direct saves of handles won't work when this function is nested return the
    %data as well
        outdata= handles.Cluster_Xdata; 
    %if all the axes are populated
    if isfield(handles,'Cluster_Xdata') && isfield(handles,'Cluster_Ydata') && isfield(handles,'Cluster_Zdata' )
        %and if the calling object is the popup menu:
        if hObject==handles.Axis1_popupmenu
            refresh_plots(hObject,eventdata,handles)
        end
    end
end
% --- Executes during object creation, after setting all properties.
function Axis1_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Axis1_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end
% --- Executes on selection change in popupmenu2.
function outdata=Axis2_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu2
    
  
    %get the data we are populating and the channel we are working with
        str = get(handles.Axis2_popupmenu, 'String');
        val = get(handles.Axis2_popupmenu,'Value');
        disp(strcat('Axis2 data set to: ',str{val},'. updating'))
        handles.Cluster_Ydata=set_local_axis_data(str{val},handles);
    
    % Save the handles structure.
        guidata(hObject,handles)
    %since direct saves of handles won't work when this function is nested return the
    %data as well
        outdata= handles.Cluster_Ydata;  
    %update the plots
    if isfield(handles,'Cluster_Xdata') && isfield(handles,'Cluster_Ydata') && isfield(handles,'Cluster_Zdata' )
        %and if the calling object is the popup menu:
        if hObject==handles.Axis2_popupmenu
            refresh_plots(hObject,eventdata,handles)
        end
    end
end
% --- Executes during object creation, after setting all properties.
function Axis2_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end
% --- Executes on selection change in Axis3_popupmenu.
function outdata=Axis3_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to Axis3_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns Axis3_popupmenu contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from Axis3_popupmenu
    
    %get the data we are populating and the channel we are working with
        str = get(handles.Axis3_popupmenu, 'String');
        val = get(handles.Axis3_popupmenu,'Value');
        disp(strcat('Axis3 data set to: ',str{val},'. updating'))
        handles.Cluster_Zdata=set_local_axis_data(str{val},handles);

    % Save the handles structure.
        guidata(hObject,handles)
     
    %since direct saves of handles won't work when this function is nested return the
    %data as well
        outdata= handles.Cluster_Zdata;
    %update the plots
    if isfield(handles,'Cluster_Xdata') && isfield(handles,'Cluster_Ydata') && isfield(handles,'Cluster_Zdata' )
        %and if the calling object is the popup menu:
        if hObject==handles.Axis3_popupmenu
            refresh_plots(hObject,eventdata,handles)
        end
    end  
end
% --- Executes during object creation, after setting all properties.
function Axis3_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Axis3_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function refresh_plots(hObject,eventdata,handles)
    % hObject    handle to calling control (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    %re-draw waveform plot
    plot(handles.Waveform,handles.Waveform_data,'-')
    %re-draw cluster plot
    %cla()
    plot3(handles.Cluster,handles.Cluster_Xdata,handles.Cluster_Ydata,handles.Cluster_Zdata,'*');
    
end

function Channel_selection_Callback(hObject, eventdata, handles)
    % hObject    handle to Channel_selection (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of Channel_selection as text
    %        str2double(get(hObject,'String')) returns contents of Channel_selection as a double

    %get the current channel number
        channel_num=str2num(get(handles.Channel_selection,'String'));
        if isempty(channel_num)
            channel_num=1;
            set(hObject,'String','1')
        end
    
    %use callback for setting display data in pop-up menus
        handles.Cluster_Xdata=Axis1_popupmenu_Callback(hObject, eventdata, handles);
        handles.Cluster_Ydata=Axis2_popupmenu_Callback(hObject, eventdata, handles);
        handles.Cluster_Zdata=Axis3_popupmenu_Callback(hObject, eventdata, handles);

        mask=find(handles.NEVNSx.NEV.Data.Spikes.Electrode==channel_num);
        handles.Waveform_data=handles.NEVNSx.NEV.Data.Spikes.Waveform(:,mask);
        handles.Cluster_number=handles.NEVNSx.NEV.Data.Spikes.Unit(:,mask);
    
        
    % Save the handles structure.
        guidata(hObject,handles)
    
    %update the plots
        refresh_plots(hObject,eventdata,handles)
         
    %update the number of waves counter:
    set(handles.NumWaves_text,'String',strcat(num2str(length(handles.Waveform_data(1,:))),' Waveforms'));
end
% --- Executes during object creation, after setting all properties.
function Channel_selection_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Channel_selection (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function outdata=set_local_axis_data(selection,handles)
    %assigns local axis data based on passed parameters. Single function to
    %avoid code duplication across multiple buttons. called by the callback
    %functions for the buttons setting the data displayed on each axis of 
    %the cluster plot
        channel_num=str2num(get(handles.Channel_selection,'String'));
    if isempty(channel_num)
        channel_num=1;
    end

    % Set current data to the selected data set.
    switch selection;
        case 'PC1' 
           outdata=handles.PC{channel_num}(:,1);
        case 'PC2' 
           outdata=handles.PC{channel_num}(:,2);
        case 'PC3' 
           outdata=handles.PC{channel_num}(:,3);
        case 'Peak' 
           outdata=handles.Peak{channel_num};
        case 'Valley' 
           outdata=handles.Valley{channel_num};
        case 'Time'
            outdata=handles.Timestamp{channel_num};
        case 'Nonlinear_energy'
            outdata=handles.Nonlinear_energy{channel_num};
    end
end

% --- Executes on button press in Rotate_checkbox.
function Rotate_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rotate_checkbox
    val = get(hObject,'Value');
    if val
        rotate3d(handles.Cluster,'on')
    else
        rotate3d(handles.Cluster,'off')
    end
end

% --- Executes on button press in NextChannel_pushbutton.
function NextChannel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to NextChannel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %get the current channel:
    channel_num=str2num(get(handles.Channel_selection,'String'));
    if isempty(channel_num)
        Channel_selection_Callback(hObject, eventdata, handles);
    end
    %index the channel number by 1:
        channel_num=channel_num+1;
    %check against highest channel number and update if appropriate
    if channel_num<=max(handles.Channel_numbers)
        set(handles.Channel_selection,'String',num2str(channel_num));
        Channel_selection_Callback(hObject, eventdata, handles);
    end
    
end

% --- Executes on button press in PreviousChannel_pushbutton.
function PreviousChannel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousChannel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %get the current channel:
    channel_num=str2num(get(handles.Channel_selection,'String'));
    if isempty(channel_num)
        Channel_selection_Callback(hObject, eventdata, handles);
    end
    %index the channel number by 1:
        channel_num=channel_num-1;
    %check against lowest channel number and update if appropriate
    if channel_num>=min(handles.Channel_numbers)
        set(handles.Channel_selection,'String',num2str(channel_num));
        Channel_selection_Callback(hObject, eventdata, handles);
    end
end

function NumWaves_Callback(hObject, eventdata, handles)
    % hObject    handle to NumWaves (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of NumWaves as text
    %        str2double(get(hObject,'String')) returns contents of NumWaves as a double
    
end

% --- Executes during object creation, after setting all properties.
function NumWaves_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to NumWaves (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in DrawBoundary_pushbutton.
function DrawBoundary_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DrawBoundary_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.Waveform,'buttondownfcn',{@start_draw,handles})
    set(handles.Cluster,'buttondownfcn',{@start_draw,handles})
end

function start_draw(hObject, eventdata, handles)
    handles.draw_axes=hObject;    
    set(handles.draw_axes,'XLimMode','manual')
    set(handles.draw_axes,'YLimMode','manual')
    %set(handles.draw_axes,'ZLimMode','manual')

    P=get(handles.draw_axes,'currentpoint');
    if isfield(handles,'user_line')
        set(handles.user_line,'xdata',[],'ydata',[]);
    end
    handles.user_line=line(P(1,1,1),P(1,2,1),'color',[0 .5 1],'LineWidth',2,'hittest','off');

    set(handles.figure1,'windowbuttonmotionfcn',{@continue_draw,handles})
    set(handles.figure1,'windowbuttonupfcn',{@end_draw,handles})
    
    set(handles.Waveform,'buttondownfcn','')
    set(handles.Cluster,'buttondownfcn','')
    
    % Update handles structure
    guidata(hObject, handles);
end
function continue_draw(hObject, eventdata, handles)
    P=get(handles.draw_axes,'currentpoint');
    X=get(handles.user_line,'xdata');
    Y=get(handles.user_line,'ydata');
    X=[X P(1,1,1)];
    Y=[Y P(1,2,1)];
    set(handles.user_line,'xdata',X,'ydata',Y);
end
function end_draw(hObject, eventdata, handles)

    set(handles.figure1,'windowbuttonmotionfcn','')
    set(handles.figure1,'windowbuttonupfcn','')
    set(handles.draw_axes,'XLimMode','auto')
    set(handles.draw_axes,'YLimMode','auto')
    %set(handles.draw_axes,'ZLimMode','auto')
    P=[get(handles.user_line,'xdata');get(handles.user_line,'ydata')]';
    size(P)
    P=close_polygon(P);
    set(handles.user_line,'xdata',P(:,1),'ydata',P(:,2));
        
end
