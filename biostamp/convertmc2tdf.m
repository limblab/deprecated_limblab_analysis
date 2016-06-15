function tdf = convertmc2tdf(accel,gyro,options)
% Converts accelerometer and gyroscope data from MC10 into tdf struct; also
% filters the data and gets rid of any bias on the gyros. This code assumes
% the file is long enough that the DC 
% 
% Inputs:
%     accel - csv file or matrix with accelerometer values.
%     gyro - csv file or matrix with gyroscope values.
% 
% options (import as struct):
%     LPF -     low pass frequency 3db cutoff [30 Hz]
%     GBias -   on/off remove bias for gyroscope [on]
%     AUnit -   accelerometer output units [m/s]
%     GUnit -   gyroscope output units [rad/s]
%     AUnitIn - accelerometer input units [g]
%     GUnitIn - Gyroscope input units [deg/s]
%     TUnitIn - Time unit in [ms]



%% Read in accel and gyro files 
if ischar(accel) == 1
    try
        a = importdata(accel);
        accel(:,2:4) = a.data(:,2:4);
        accel(:,1) = a.data(:,1) - a.data(1,1);
    catch
        error(['Could not read from ' accel])
    end
end

if ischar(gyro) == 1
    try
        g = importdata(accel);
        gyro(:,2:4) = g.data(:,2:4);
        gyro(:,1) = g.data(:,1) - g.data(1,1);
    catch
        error(['Could not read from ' gyro])
    end
end


%% Defaults
if ~isstruct(options) == 1
    options = struct();
end

if ~isfield(options.LPF) == 1
    options.LPF = 30;
end
if ~isfield(options.GBias) == 1
    options.GBias = 'on';
end
if ~isfield(options.AUnit) == 1
    options.AUnit = 'm/s';
end
if ~isfield(options.GUnit) == 1
    options.GUnit = 'rad/s';
end
if ~isfield(options.AUnitIn) == 1
    options.AUnitIn = 'g';
end
if ~isfield(options.AUnitIn) == 1
    options.GUnitIn = 'deg/s'
end
if ~isfield(options.TUnitIn) == 1
    options.TUnitIn = 'ms'
end


%% Filtering and removing bias

RollAverage = mean(gyro(:,2)); % Average roll - assume it's a bias error
PitchAverage = mean(gyro(:,3));
YawAverage = mean(gyro(:,4));

gyro(:,2) = gyro(:,2) - RollAverage;
gyro(:,3) = gyro(:,3) - PitchAverage;
gyro(:,4) = gyro(:,4) - YawAverage;


% Build filter
sampfreq = 1/(ceiling(((gyro(11,1)-gyro(10,1))+(gyro(15,1)-gyro(14,1)))/2)); %sampling freq
if strcomp(options.TUnitIn,'ms') == 1
    sampfreq = sampfreq * 10^-3; % sampling frequency if timescale is ms
end
LPF = options.LPF*pi/sampfreq; % calculate the normalized LPF frequency

blp = fir1(15,LPF);
freqz(blp)






end