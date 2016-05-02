function Biostamp = AccelRead(FileName,varargin)
% % AccelRead(FileName,{...PARAM1,VAL1,PARAM2,VAL2...})
% ----Accelerometer Reader----
% Reads in data from the biostamp reader, and puts it in the correct format
% for FrameShifter, which takes care of doing all of the extrinsic frame
% transformations etc.
% 
% ---Requred Inputs---
%   FileName = name of csv file with Biostamp data.
%   
% ---Optional Inputs---
% These must be declared with a string and value pair
% eg. AccelRead(FileName,'StartPoint',10)
%
%   StartPoint = number of points to skip at the beginning of the data, if 
%                there is some garbage at the beginning to ignore

if nargin>1
    if mod(nargin-1,2) ~= 0
        disp('Optional inputs must be entered in a string-value set')
        exit
    end

    for i=1:2:length(varargin)
        fields = varargin(i);
        values = varargin(i+1);
    end
    OptArgs = struct(fields,values);

    switch fields
        case 'StartPoint'
            StartPoint = OptArgs.StartPoint;
    end
    
else
    StartPoint = 1;
end



%% Creating a UI to input the files etc.
Read_in = figure('ToolBar','none','Visible','off','Position',[360,500,200,285],'Name','Biostamp File Importer');
Read_in.Units = 'normalized';
Ac_name = uicontrol('Style','text','String','Acceleration File','Position',[15,240,300,15]);
Ac_Br = uicontrol('Style','pushbutton','String','Browse','Position',[350,245,70,25],'Callback',{@Ac_Br_callback});
Gy_name = uicontrol('Style','text','String','Gyro File','Position',[15,200,300,15]);
Gy_Br = uicontrol('Style','pushbutton','String','Browse','Position',[350,205,70,25],'Callback',{@Gy_Br_callback});


Ac_name.Units = 'normalized';
Ac_Br.Units = 'normalized';
Gy_name.Units = 'normalized';
Gy_Br.Units = 'normalized';

% Read_in.Name = 'Biostamp File Importer';
movegui(Read_in,'center')

Read_in.Visible = 'on';


%%
% Setting up all of the labels for biostamp data in
labels(1,:) = {'Time','X Axis Acceleration','Y Axis Acceleration',...
    'Z Axis Acceleration','Roll Velocity','Pitch Velocity','Yaw Velocity'};
labels(2,:) = {'seconds' 'g' 'g' 'g' 'deg/s' 'deg/s' 'deg/s'};

% Read in all of the data, set up some data structures - Biostamp is
% everything read out, without any coordinate changes, Location is
% everything in terms of a space frame -> that's basically just the first
% point where accel = gravity;
import = importdata(FileName);
Biostamp = struct('time',import.data(StartPoint:end,1),'accel',[],'gyro',[]);

% It looks like this section is no longer important, since the new
% "investigator portal" takes care of converting everything into deg/s and
% Gs
% % 2^16 -> 2000 deg/sec and 4G, correcting labels
% Biostamp.accel = 9.8*import.data(StartPoint:end,2:4);
% Biostamp.gyro = (pi/180)*import.data(StartPoint:end,5:7);


end

function Ac_Br_callback(source,eventdata)
    
end

function Gy_Br_callback(source,eventdata)
    
end

function Ac_File_callback(source,eventdata)
    
end

function Gy_File_callback(source,eventdata)
    
end