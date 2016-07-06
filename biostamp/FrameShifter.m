function FrameShifter(TDF,vargin)
%---FRAMESHIFTER---
% 
% Inputs:
%   TDF - struct with biostamp data formatted from AccelRead; may be imput
%         as a struct or a matlab file name 
% 
% options (options.xyz) [default]:
%   athreshold - Noise threshold of accelerometers 
%   wthreshold - Noise threshold of gyroscopes 
%   plotson - plotting of acceleration, gyros, and location [off]
%   vidon - video of biostamp movement in extrinsic frame [off]

% To Do:
%   * Support for TDF
%   * add integration, check errors on static files
%   * find reasonable thresholds for static moments
%   * Identify all "zero" points


% setting the default variables if not everything is set. May change this
% later to be just a vargin where you have to specify the variable name,
% yaknow?
athreshold = 4/2^15;
wthreshold = 2000/2^15;
plotson = 'off'


if ischar(TDF)
    try
        TDF = importfile(TDF);
    catch
        error('TDF file could not be imported. Check file and try again')
    end
end

if ~isfield(TDF,'valTDF') || ~isstruct(TDF)
    error('Input is not a valid TDF struct')
end


StatVector = StationaryFinder(TDF);
Location = SpaceFrameConverter(TDF,StatVector);




% Plotting the current roll, pitch and yaw from the body frame, and all of
% the initial plots of accel and gyros
if strcmp(plotson,'on')
    PlotRollPitchYaw(TDF)
    PlotInitData(TDF,labels)
end

% profile viewer

end


function PlotRollPitchYaw(Biostamp)
% does exactly what it says - plots the roll, pitch and yaw of the
% biostamp. Since it's just the first integral of the gyro, it doesn't
% really matter what frame it's in.
    figure
    subplot(1,3,1)
    plot(Biostamp.time(11:end,1),Biostamp.roll)
    title('corrected roll')
    xlabel('time (s)')
    ylabel('roll (deg)')
    axis([0 250 -90 90])
    axis square
    subplot(1,3,2)
    plot(Biostamp.time(11:end,1),Biostamp.pitch)
    title('corrected pitch')
    xlabel('time (s)')
    ylabel('pitch (deg)')
    axis([0 250 -90 90])
    axis square
    subplot(1,3,3)
    plot(Biostamp.time(11:end,1),Biostamp.yaw)
    title('corrected yaw')
    xlabel('time (s)')
    ylabel('yaw (deg)')
    axis([0 250 -90 90])
    axis square

end

function PlotInitData(Biostamp,labels)
% Quick function to plot all of the initial data from the inputs - linear
% acceleration and rotational velocity in terms of time.

figure

for i = 1:3
    subplot(2,3,i)
    plot(Biostamp.time,Biostamp.accel(:,i))
    title(labels(1,i+1))
    xlabel('time (s)')
    ylabel(labels(2,i+1))
    axis([0 250 -2 2])
    axis square
end

for i = 1:3
    subplot(2,3,i+3)
    plot(Biostamp.time,Biostamp.gyro(:,i))
    title(labels(1,i+4))
    xlabel('time (s)')
    ylabel(labels(2,i+4))
    axis([0 250 -400 400])
    axis square
end

end




function Location = SpaceFrameConverter(Biostamp,StartInd,RollVelMean,PitchVelMean,YawVelMean)
% ---SpaceFrameConverter---
% function to find the location of the biostamp in an extrinsic coordinate
% frame.
% 
% Inputs:
%   Biostamp = struct following the format of AccelRead
%   StartInd = index where extrinsic frame = intrinsic frame
%   AccelMean = vector of the magnitude of acceleration at all points
%   RollVelMean = average of the roll velocity - assumed to be a bias
%   PitchVelMean = average of the pitch velocity - " " " "
%   YawVelMean = average of the yaw velocity - " " " "


% extrinsic frame is assumed to have gravity in negative z direction, and x
% in the direction of the portions of i normal to the gravity vector.
% for keeping track of everything, here's the transformation matrix:
%   X_space = T * X_body
% 
%   T = | ix jx kx |
%       | iy jy ky |
%       | iz jz kz |

% --- initial T ---
theta = acos(Biostamp.accel(StartInd,1));
phi = acos(Biostamp.accel(StartInd,2));
rho  = acos(Biostamp.accel(StartInd,3));
iz = -(Biostamp.accel(StartInd,1))*sin(pi/2 - theta);
jz = -(Biostamp.accel(StartInd,2))*sin(pi/2 - phi);
kz = -(Biostamp.accel(StartInd,3))*sin(pi/2 - rho);

gix = Biostamp.accel(StartInd,1)*cos(pi/2 - theta);
gxyj = Biostamp.accel(StartInd,2)*cos(pi/2 - phi);
gxyk = Biostamp.accel(StartInd,3)*cos(pi/2 - rho);

function sys = mysys(gix,gxyj,gxyk,AG)
% AG = [sinalpha; singamma; cosalpha; cosgamma]
sys = [gix - gxyj*AG(4) + gxyk*AG(3), gxyj*AG(2) - gxyk*AG(1), ...
     AG(1)^2+AG(3)^2 - 1, AG(2)^2 + AG(4)^2 - 1];
end
S = fsolve(@mysys,[-1;-1;1;1]);



disp('finally!');
end

function StatVector = StationaryFinder(TDF)
% Finding indices of locations where magnitude of acceleration is under a
% certain threshold and ang vel is ~ 0

    if TDF.meta.AUnit == 'm/s' % acceleration units?
        grav = 9.8;
    else
        grav = 1;
    end
    AMinInd = uint16(find(abs(AccelMag-grav) < athreshold));
    WMinInd = uint16(find((TDF.gyro(:,1).^2 + TDF.gyro(:,2).^2 ...
        + TDF.gyro(:,3).^2)<wthreshold));
    AnotherIndVector = [];
    for i=1:length(AMinInd)
        if any(WMinInd==AMinInd(i))
            AnotherIndVector = [AnotherIndVector,AMinInd(i)];
        end
    end


end