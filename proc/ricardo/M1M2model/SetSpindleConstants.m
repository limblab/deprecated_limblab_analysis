%% Initialize model constants
% This file sets all the Mileusnic et al (2006) muscle spindle constants.
% Constants are adopted without change, except for the (artificial) mass to
% improve numerical stability.
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Set model constants
Ksr     = [10.4549; 10.4649; 10.4649];
Kpr     = [0.15; 0.15; 0.15];
M       = [0.0002; 0.0002; 0.0002];
beta0   = [0.0605; 0.0822; 0.0822];
beta1   = [0.2592; nan; nan];
beta2   = [nan; -0.0460; -0.0690];
Gamma1  = [0.0289; nan; nan];
Gamma2  = [nan; 0.0636; 0.0954];
Cl      = [1; 1; 1];
Cs      = [0.42; 0.42; 0.42];
X       = [nan; 0.7; 0.7];
Lnsr    = [0.0423; 0.0423; 0.0423];
Lnpr    = [nan; 0.89; 0.89];
Gprim   = [20000; 10000; 10000];
Gsec    = [nan; 7250; 7250];
a       = [0.3; 0.3; 0.3];
R       = [0.46; 0.46; 0.46];
L0sr    = [0.04; 0.04; 0.04];
L0pr    = [0.76; 0.76; 0.76];
Lsec    = [nan; 0.04; 0.04];
tau     = [0.0149; 0.205; nan];
freq    = [60; 60; 90];
p       = [2; 2; 2];
S       = 0.156;

% Mass correction.
M = M/100;