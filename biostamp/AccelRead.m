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



% Setting up all of the labels for biostamp data in
labels(1,:) = {'Time','X Axis Acceleration','Y Axis Acceleration',...
    'Z Axis Acceleration','Roll Velocity','Pitch Velocity','Yaw Velocity'};
labels(2,:) = {'seconds' 'g' 'g' 'g' 'deg/s' 'deg/s' 'deg/s'};

% Read in all of the data, set up some data structures - Biostamp is
% everything read out, without any coordinate changes, Location is
% everything in terms of a space frame -> that's basically just the first
% point where accel = gravity;
data.num = xlsread(FileName,'','','basic');
Biostamp = struct('time',data.num(StartPoint:end,1),'accel',[],'gyro',[],'roll',[],'pitch',[],'yaw',[]);

% 2^16 -> 2000 deg/sec and 4G, correcting labels
Biostamp.accel = 4*(data.num(StartPoint:end,2:4))/2^15;
Biostamp.gyro = 2000*(data.num(StartPoint:end,5:7))/2^15;


end