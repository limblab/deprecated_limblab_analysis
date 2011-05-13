function ramp = createRamp(simSetting, velocity, amplitude, tacc)
%% function ramp = createRamp(simSetting, velocity, amplitude, tacc)
% Creates a ramp-shaped position disturbance.
% 
% Inputs:
% simSetting    - Structure containing simulation settings
%                 Fields:
%                   .dt   - sampling time [s]
%                   .T    - total simulation duration [s]
%                   .Tramp- onset time of ramp disturbance [s]
% velocity      - Velocity of rising phase of the ramp [rad/s]
% amplitude     - Amplitude of the ramp [rad]
% tacc          - Acceleration time [s]. This determines the time it takes
%                 the ramp to accelerate from v=0 to v=velocity.
%
% Returns:
% ramp          - Structure with ramp data
%                 Fields:
%                   .time       - time vector [s]
%                   .acc        - acceleration vector [rad/s^2]
%                   .vel        - velocity vector [rad/s]
%                   .pos        - angle vector [rad]
%                   .velocity   - scalar velocity of ramp [rad/s]
%                   .amplitude  - scalar amplitude of ramp [rad]
%                   .tacc       - scalar acceleration time of ramp [s]
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc

%% Define shorthand names
T       = simSetting.T;       % Total signal length [s]
dt      = simSetting.dt;      % Sampling time [s]
Tramp   = simSetting.Tramp;   % Start time of ramp [s]

%% Determine constant acceleration 
% Constant acceleration
if tacc <= 0 % Need positive acceleration time
    warning('createRamp:tacc',...
        'Illegal acceleration time tacc=%3.4f \n has been changed to tacc=dt=%3.4f', ...
        tacc, dt)
    tacc = dt;
end
a = velocity / tacc;
    
% Test if velocity can be reached before reaching amplitude, given the
% chosen acceleration time 'tacc'
xa = 0.5 * a * tacc^2;
if xa > (amplitude / 2)
    error(['Target amplitude is reached before target velocity is reached.\n', ...
        'Decrease acceleration time ''tacc'' or increase ''amplitude'''], 0)
end

%% Determine acceleration vector of ramp
% Duration of linear motion trajectory [s]
tlin = (amplitude - a * tacc^2) / velocity;  
% Total duration of ramp
ttot = 2 * tacc + tlin;
% Init vector
avec = zeros(ceil(ttot / dt), 1);
% Fill vector
Nacc = round(tacc / dt);
avec(1:Nacc) = a;
avec(end-Nacc+1:end) = -a;

%% Integrate accelerion to get velocity and position
vvec                     = cumsum(avec) * dt; % Velocity
xvec                     = cumsum(vvec) * dt; % Position

%% Insert ramp in vector with correct simulation length
% Make time vector. Start with extra long vector (for when ramp outlasts
% the simulation length).
outTime          = (0:dt:T)' - Tramp;

% Make velocity and position vectors
idxStart         = round(Tramp / dt);
Nsim             = round(T / dt);

outAcc = [zeros(idxStart + 1, 1); avec; zeros(Nsim-(idxStart-1)-length(avec)-1, 1)];
outVel = [zeros(idxStart + 1, 1); vvec; zeros(Nsim-(idxStart-1)-length(vvec)-1, 1)];
outPos = [zeros(idxStart + 1, 1); xvec; amplitude * ones(Nsim-(idxStart-1)-length(xvec)-1, 1)];

% Clip output vectors if they are longer than the simulation time
outAcc = outAcc(1:length(outTime));
outVel = outVel(1:length(outTime));
outPos = outPos(1:length(outTime));

% Create output structure
ramp.time        = outTime;
ramp.acc         = outAcc;
ramp.vel         = outVel;
ramp.pos         = outPos;
ramp.velocity    = velocity;
ramp.amplitude   = amplitude;
ramp.tacc        = tacc;