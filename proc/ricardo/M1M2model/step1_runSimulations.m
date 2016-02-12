%% Main file that runs the simulations with RAMPMODEL.M
% This script is the main file of the M1-M2 simulations.
% It performs the neural simulations for all applied ramp-and-hold
% stretches. Results are saved to file: 'simResults.mat'.
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Cleanup
clear, clc

%% Simulation settings
rand('state', 0)  % Set seed of random generator to ensure reproducible results
randn('state', 0) % Set seed of random generator to ensure reproducible results
sim.dt          = 0.001;  % Fixme % Sampling time [s]
sim.Tramp       = 1.000;  % Startup behavior avoidance time
sim.T           = 1.2;    % Simulation length

%% Ramp profile settings
% Choose experimental conditions: stretch velocities and stretch
% amplitudes.
velocities = [1.5000    2.0000    3.0000    5.0000]; % [rad/s]
amplitudes = [0.0600    0.1000    0.1400];           % [rad]

%% Input settings
% Ia
inputs.Iacount = 120;   % Fiber count
inputs.Iadelay = 0.030; % Transport delay [s]

% Tonic descending excitation
inputs.g        = 47;      % Tonic descending excitation
inputs.TDEcount = 96;      % Fiber count

%% Neuron pool settings
pool.N          = 300;                  % Number of neurons
pool.EK         = -10;                  % Resting potassium potential               [mV]
pool.TMEM       = 5e-3;                 % Membrane time constant                    [s]
pool.TH0_min    = 10;                   % Initial threshold (lowest value for recruitment)[mV]
pool.TH0_max    = 10;                   % Initial threshold (highest value for recruitment)[mV]
pool.C          = 0.6;                  % Threshold sensitivity                     [-]
pool.TTH        = 25e-3;                % Accomodation time constant                [s]
pool.B          = 3.41;                 % Sensitivity to potassium conductance        [-]
pool.TGK        = 20e-3;                % Refractory time constant                  [ms]
pool.TG         = 1e-3;                 % Time constant synaptic action (Ia, II, TDE)  [ms]
pool.EQ         = 70;                   % Synapse equilibrium potential [mV]
pool.STR        = [0.01, 0.03]';        % Synapse strength (Ia, II, TDE)

%% Run simulations
% Loops through the combinations of stretch amplitude and velocity and runs
% a simulation using 'RampModel.m'.

% Init output variables
out = cell(length(velocities), length(amplitudes));
ramp = cell(length(velocities), length(amplitudes));

% Run simulations
for ii = 1:length(velocities)
    for jj = 1:length(amplitudes)
        disp(['Vel: ', num2str(ii), ', Amp: ', num2str(jj)])

        % Generate a ramp-and-hold signal. for info, see the help of
        % 'createRamp.m'
        velocity    = velocities(ii);
        amplitude   = amplitudes(jj);
        tacc        = 0.001;
        ramp{ii,jj} = createRamp(sim, velocity, amplitude, tacc);
        
        % Create spindle output
        % Runs a Simulink file with the spindle model of Mileusnic et al
        % (2006) to determine the Ia afferent output given the
        % rmap-and-hold stretch.
        SetSpindleConstants;                            % Spindle model constants (Mileusnic et al)
        g_dyn = (50) * ones(size(ramp{ii,jj}.time));    % Gamma dynamic [sp/s]
        g_stat = (50) * ones(size(ramp{ii,jj}.time));	% Gamma static [sp/s]
        Iafreq = runspindle(ramp{ii,jj}.time, ramp{ii,jj}.pos * 12.4 / 158.5 + 1, g_dyn, g_stat);
        
        % Run model
        out{ii,jj} = RampModel(sim, ramp{ii,jj}, pool, inputs, Iafreq);
    end
end

%% Save output to file
save('simResult',...
    'out',...
    'velocities',...
    'amplitudes',...
    'sim',...
    'inputs',...
    'pool',...
    'ramp');