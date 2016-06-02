function m2 = M2area(time, emg)
%% function m2 = M2area(time, emg)
% Determines the metric for the magnitude of the M1 response (integral over
% normalized simulated EMG).
% 
% Inputs:
% time          - time vector [s]
% emg           - normalized and filtered EMG output from neural model [-]
%
% Returns:
% m2            - normalized magnitude of the M2 response [-]
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Background activity
% Background is defined as t<=0, stretch onset is on t=0.
bgwindow = [time(1), 0]; % Background window
idxbg = (time >= bgwindow(1)) & (time <= bgwindow(2));

%% M2 activity
% M2 is defined as 55<=t<=100 [ms]
m2window = [0.055, 0.100];
idxwin = (time >= m2window(1)) & (time <= m2window(2));

%% Integrate
% Result is the normalized area under the EMG during the M2 window.
bg = mean(emg(idxbg));
m2 = mean(emg(idxwin)) / bg;