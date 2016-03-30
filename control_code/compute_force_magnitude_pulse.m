function [magForce,pulseamps,pulsewidths,calibForces,dirForce,stdForce,forceCloud] = single_costim(data_struct,calmat)

%% Determine which channels are the forces and extract data
numEMGs = sum(data_struct.emg_enable(1:15));
rawForces.forces = data_struct.data(:,numEMGs+1:numEMGs+6)*calmat;

%% Determine modulated parameters and their values
indAmp = find(data_struct.base_amp>0);
pulseamps = data_struct.base_amp(indAmp);
pulsewidths = data_struct.base_pw(indAmp);

%% Determine force magnitude for each parameter value
numsamples = size(rawForces.forces,1);
% Onsets ~0.17sec
bline_end = 0.10;
% Integration window for steady-state ~0.45-0.65sec
platON = 750;
platOFF = 1500;
calibForces = rawForces;

% Remove baseline from forces/moments
baseline = mean(rawForces.forces(1:bline_end*1000,:));
calibForces.forces = rawForces.forces - repmat(baseline,numsamples,1);

% Average steady-state force magnitude (x-y plane) during pulse train
fX = (calibForces.forces(platON:platOFF,1));
fY = (calibForces.forces(platON:platOFF,2));
magForce = mean(sqrt(fX.^2+fY.^2));
stdForce = std(sqrt(fX.^2+fY.^2));

% Average direction of steady-state force in x-y plane (positive Fx
% is to the right when facing rat, positive Fy is vertical)
dirForce = mean(atan(fY./fX));

forceCloud = [fX fY];
