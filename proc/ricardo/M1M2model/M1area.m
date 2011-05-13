function m1 = M1area(time, emg)
%% function m1 = M1area(time, emg)
% Determines the metric for the magnitude of the M1 response (integral over
% normalized simulated EMG).
% 
% Inputs:
% time          - time vector [s]
% emg           - normalized and filtered EMG output from neural model [-]
%
% Returns:
% m1            - normalized magnitude of the M1 response [-]
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Background activity
% Background is defined as t<=0, stretch onset is on t=0.
bgwindow = [time(1), 0];
idxbg = (time >= bgwindow(1)) & (time <= bgwindow(2));

%% M1 activity
% M1 is defined as 20<=t<=50 [ms]
m1window = [0.020, 0.050];
idxwin = (time >= m1window(1)) & (time <= m1window(2));

%% Integrate
% Result is the normalized area under the EMG during the M1 window.
bg = mean(emg(idxbg));
m1 = mean(emg(idxwin)) / bg;