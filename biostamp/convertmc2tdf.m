function TDF = convertmc2tdf(accel,gyro,options)
% TDF = convertmc2tdf(accel,gyro,{options})
% 
% Converts accelerometer and gyroscope data from MC10 into TDF struct; also
% filters the data and gets rid of any bias on the gyros. This code assumes
% the file is long enough that the DC rotation should be ~0. Output is in
% TDF (Tracker Data Format)
% 
% Inputs:
%     accel - csv file or matrix with accelerometer values.
%     gyro - csv file or matrix with gyroscope values.
% 
% 
% options (options.xyz) [default]:
%     LPF - low pass frequency 3db cutoff [30 Hz]
%     GBias - on/off remove bias for gyroscope [on]
%     AUnit - accelerometer output units [m/s]
%     GUnit - gyroscope output units [rad/s]
%     AUnitIn - accelerometer input units [g]
%     GUnitIn - gyroscope input units [deg/s]
%     TUnitIn - Time unit in [ms]
%     sampleskip - number of samples to skip [10]
%     plotflag - plots the bode and phase of the filter [on]
%     filter - on/off LPF data [on] 
% 
% 
% output (TDF.xyz):
%     meta - meta data about the struct
%       meta.date - date and time the file was converted
%       meta.LPF - low pass filter frequency
%       meta.AUnit - Acceleration units
%       meta.GUnit - Gyro Units
%       meta.timeinit - initial time in standardized units
%       meta.sampleskip - # of samples skipped at beginning of file
% 
%     bias - information about the gyroscope bias
%       bias.Roll - Roll bias that was subtracted
%       bias.Pitch - Pitch bias that was subtracted
%       bias.Yaw - Yaw bias that was subtracted
% 
%     accel - filtered accelerometer data; units from AUnit
%     gyro - filtered gyro data; units from GUnit
%     time - time elapsed from beginning of file (ms)
%     valTDF - check to make sure it's a valid structure between scripts


%% Read in accel and gyro files 
if ischar(accel) == 1
    try
        a = importdata(accel);
        accel = a.data;
    catch
        error(['Could not read from ' accel])
    end
end

if ischar(gyro) == 1
    try
        g = importdata(gyro);
        gyro = g.data;
    catch
        error(['Could not read from ' gyro])
    end
end


%% Define options values

[default_options,default_names] = convertMC2tdfDefaultNames(); %defaults
if exist('options','var')
   for i=1:length(default_names)
       if ~isfield(options,default_names{i}) %non defined fields = defaults
           options.(default_names{i}) = default_options.(default_names{i});
       end
   end    
else
    options = default_options; %options set to default
end


%% TDF struct - defining fields etc

TDF = struct('meta','','accel',[],'gyro',[],'time',[]);
TDF.meta.date = date;
TDF.meta.AUnit = options.AUnit;
TDF.meta.GUnit = options.GUnit;


%% Filtering and removing bias

% Average roll - assume it's a bias error
TDF.bias.Roll = mean(gyro(options.sampleskip:end,2));
TDF.bias.Pitch = mean(gyro(options.sampleskip:end,3));
TDF.bias.Yaw = mean(gyro(options.sampleskip:end,4));

gyro(options.sampleskip:end,2) = gyro(options.sampleskip:end,2) - TDF.bias.Roll;
gyro(options.sampleskip:end,3) = gyro(options.sampleskip:end,3) - TDF.bias.Pitch;
gyro(options.sampleskip:end,4) = gyro(options.sampleskip:end,4) - TDF.bias.Yaw;

TDF.meta.timeinit = gyro(options.sampleskip,1);
TDF.meta.sampleskip = options.sampleskip;
TDF.time = gyro(options.sampleskip:end,1) - TDF.meta.timeinit;


% Build filter
sampfreq = 1/(ceil(((TDF.time(11)-TDF.time(10))+(TDF.time(end)-TDF.time(end-1)))/2)); %sampling freq
if strcmp(options.TUnitIn,'ms') == 1
    sampfreq = sampfreq * 10^3; % sampling frequency if timescale is ms
end
LPF = options.LPF*pi/sampfreq; % calculate the normalized LPF frequency
TDF.meta.LPF = options.LPF;
blp = fir1(15,LPF);

if strcmp(options.plotflag,'on')
    freqz(blp)
end

% Outputs after the filter at LPF hz
if strcmp(options.filter,'on')
    TDF.gyro(:,1) = deg2rad(filter(blp,1,gyro(options.sampleskip:end,2)));
    TDF.gyro(:,2) = deg2rad(filter(blp,1,gyro(options.sampleskip:end,3)));
    TDF.gyro(:,3) = deg2rad(filter(blp,1,gyro(options.sampleskip:end,4)));
    TDF.accel(:,1) = 9.81*filter(blp,1,accel(options.sampleskip:end,2));
    TDF.accel(:,2) = 9.81*filter(blp,1,accel(options.sampleskip:end,3));
    TDF.accel(:,3) = 9.81*filter(blp,1,accel(options.sampleskip:end,4));
else
    TDF.gyro(:,1:3) = deg2rad(gyro(options.sampleskip:end,2:4));
    TDF.accel(:,1:3) = accel(options.sampleskip:end,2:4)*9.81;
end

TDF.valTDF = 1;

end


function [default_options,default_names] = convertMC2tdfDefaultNames()
% default fields and values for options

default_names = {'LPF','GBias','AUnit','GUnit','AUnitIn',...
    'GUnitIn','TUnitIn','sampleskip','plotflag','filter'};
default_options = struct('LPF',30,'GBias','on','AUnit',...
    'm/s','GUnit','rad/s','AUnitIn','g','GUnitIn','deg/s',...
    'TUnitIn','ms','sampleskip',10,'plotflag','on','filter','on');

end