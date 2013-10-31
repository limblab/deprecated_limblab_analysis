function varargout = test_drawing(varargin)
% TEST_DRAWING MATLAB code for test_drawing.fig
%      TEST_DRAWING, by itself, creates a new TEST_DRAWING or raises the existing
%      singleton*.
%
%      H = TEST_DRAWING returns the handle to a new TEST_DRAWING or the handle to
%      the existing singleton*.
%
%      TEST_DRAWING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_DRAWING.M with the given input arguments.
%
%      TEST_DRAWING('Property','Value',...) creates a new TEST_DRAWING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_drawing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_drawing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_drawing

% Last Modified by GUIDE v2.5 06-Sep-2013 17:04:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_drawing_OpeningFcn, ...
                   'gui_OutputFcn',  @test_drawing_OutputFcn, ...
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

% --- Executes just before test_drawing is made visible.
function test_drawing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_drawing (see VARARGIN)

% Choose default command line output for test_drawing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_drawing wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end
% --- Outputs from this function are returned to the command line.
function varargout = test_drawing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end


    function start_draw(hObject, eventdata, handles)
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
        set(handles.draw_axes,'buttondownfcn','')
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.draw_axes,'buttondownfcn',{@start_draw,handles})
    x=rand(10);
    y=rand(10);
    z=rand(10);
    plot3(handles.draw_axes,x,y,z,'*')
    % Update handles structure
        guidata(hObject, handles);
end
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
end


% --- Executes on mouse press over axes background.
function draw_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to draw_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('poke')
end
