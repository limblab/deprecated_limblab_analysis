function [Ia, II, dL, ddL] = runspindle(t, L, g_dyn, g_stat)
%% function [Ia, II, dL, ddL] = runspindle(t, L, g_dyn, g_stat)
% Runs a simulation of the muscle spindle model of Mileusnic et al (2006)
% for a specified stretch trajectory.
%
% Inputs:
% t         - Time vector [s]
% L         - Normalized fascicle length vector (size of 't') [-]
% g_dyn     - Gamma dynamic activation (size of 't') [sp/s]
% g_stat    - Gamma static activation  (size of 't') [sp/s]
%
% Returns:
% Ia        - Ia fiber spike rate [sp/s]
% II        - II fibder spike rate [sp/s]
% dL        - Normalized stretch velocity [-/s]
% ddL       - Normalized stretch acceleration [-/s^2]
%
% NOTES:
% In order to run, this function needs 'spindle_mileusnic.mdl' and
% 'SetSpindleConstants.m'.
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Generate velocity and accelertion: dL and ddL
% Determine sample time
if std(diff(t)) > 10*eps
    error('Constant sample rate required (input t)');
else
    dt = t(2)-t(1);
end

% Check input size
[m,n] = size(t);
if m < n
    error('Input t must be a column vector')
end

dL = [0; diff(L) / dt];
ddL = [0; diff(dL) / dt];

%% Run model
% Runs the Mileusnic model in Simulink
[dummy, dummy, modout] = sim('spindle_mileusnic', t, [], [t g_dyn g_stat L dL ddL]);

%% Return output
Ia = modout(:,1);
II = modout(:,2);