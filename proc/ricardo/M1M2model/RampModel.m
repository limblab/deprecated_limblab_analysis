function [out] = RampModel(sim, ramp, pool, inputs, Iafreq)
%% function [out] = RampModel(sim, ramp, pool, inputs, Iafreq)
% Runs a single simulation of the spinal response to a muscle stretch.
% 
% Inputs:
% sim           - Structure containing simulation settings
%                 Fields:
%                   .dt   - sampling time [s]
%                   .T    - total simulation duration [s]
%                   .Tramp- onset time of ramp disturbance [s]
% ramp          - Structure with ramp data, generated with 'createRamp.m'.
%                 Fields:
%                   .time       - time vector [s]
%                   .acc        - acceleration vector [rad/s^2]
%                   .vel        - velocity vector [rad/s]
%                   .pos        - angle vector [rad]
%                   .velocity   - scalar velocity of ramp [rad/s]
%                   .amplitude  - scalar amplitude of ramp [rad]
%                   .tacc       - scalar acceleration time of ramp [s]
% pool          - Strcuture with motoneuron pools settings. Parameterized
%                 according to Bashor (1998).
%                 Fields:
%                   .N          - Number of neurons
%                   .EK         - Resting potassium potential [mV]
%                   .TMEM       - Membrane time constant [s]
%                   .TH0_min    - Initial threshold (lowest value for linear recruitment) [mV]
%                   .TH0_max    - Initial threshold (highest value for linear recruitment) [mV]
%                   .C          - Threshold sensitivity [-]
%                   .TTH        - Accomodation time constant [s]
%                   .B          - Sensitivity to potassium conductance [-]
%                   .TGK        - Refractory time constant [ms]
%                   .TG         - Time constant synaptic action [ms]
%                   .EQ         - Synapse equilibrium potential [mV]
%                   .STR        - Synapse strength [Ia; II; TDE] [-]
% inputs        - Structure with afferent and supraspinal parameters
%                 Fields:
%                   .Iacount    - Number of Ia afferent fibers [-]
%                   .Iadelay    - Ia afferent transport delay [s]
%                   .g          - Tonic descending excitation rate [sp/s/fiber]
%                   .TDEcount   - Number of descending fibers [-]
% Iafreq        - Vector of Ia afferent spike rates [sp/s] determined with
%                 spindle_mileusnic.mdl (Mileusnic et al, 2006). Must have
%                 same number of samples as the stretch signal.
%
% Returns:
% out           - Structure with model output.
%                 Fields:
%                   .time        - Time vector [s]
%                   .nrn.S       - Summed mototneuron pool output [-]
%                   .nrn.Sdetail - Matrix with individual spikes of MNs {0,1}
%                   .inputs.rIa  - Copy of Ia afferent rate [sp/s]
%                   .inputs.rTDE - Copy of tonic descending rate [sp/s]
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Create shorthand names
dt          = sim.dt;
t           = ramp.time;
g           = inputs.g;
nrFibersIa  = inputs.Iacount;
nrFibersTDE = inputs.TDEcount;

%% Initialize delay buffer of Ia afferent
IaDelaySteps = round(inputs.Iadelay / sim.dt);

%% Initialize neuronal model
% Pool size
N       = pool.N;       % Number of neurons

% Neuron constants
EK      = pool.EK;      % Resting potassium potential                 [mV]
TMEM    = pool.TMEM;    % Membrane time constant                      [s]
TH0_min = pool.TH0_min; % Initial threshold (lowest in recruitment order) [mV]
TH0_max = pool.TH0_max; % Initial threshold (highest in recruitment order) [mV]
C       = pool.C;       % Threshold sensitivity                       [-]
TTH     = pool.TTH;     % Accomodation time constant                  [s]
B       = pool.B;       % Sensitivity to potassium conductance        [-]
TGK     = pool.TGK;     % Refractory time constant                    [ms]
TG      = pool.TG;      % Time constant synaptic action (Ia, II, TDE) [ms]
EQ      = pool.EQ;      % Synapse equilibrium potential [mV]
STR     = pool.STR;     % Synapse strength (Ia, II, TDE)

% Make threshold vector, linear distribution between TH0_min and TH0_max
TH0 = TH0_min + (0:1/(N-1):1)' * (TH0_max - TH0_min);

% Initial neuronal states
TH      = TH0 .* ones(N, 1);         % Threshold
E       = TH0 .* rand(N, 1);         % Membrane potential
GK      = zeros(N, 1);               % Potassium conductance
G       = zeros(N, 1);               % Synaptic conductance (Ia, II, TDE)
S       = false(N, 1);               % Spike {0,1}

% Initialize output
outS        = zeros(size(t,1), 1);
outSdetail  = zeros(size(t,1), N);
outrIa      = zeros(size(t,1), 1);
outrII      = zeros(size(t,1), 1);
outrTDE     = zeros(size(t,1), 1);
nrDone      = 0;

%% Simulate
for k = 1:length(t)
    
    % Determine Ia afferent spike rate. Hold the initial value of Ia
    % afferent spike rate until delay buffer is filled.
    if k > IaDelaySteps
        rIa = max(0, Iafreq(k-IaDelaySteps));
    else
        rIa = max(0, Iafreq(1));
    end
    
    % Determine tonic excitation spike rate
    rTDE = g;
    
    % Store input rates
    outrIa(k)  = rIa;
    outrTDE(k) = rTDE;

    % Determine poissoin spike train of inputs
    inIa = poissrnd(rIa * nrFibersIa * sim.dt, N, 1);
    inTDE= poissrnd(rTDE * nrFibersTDE * sim.dt, N, 1);
    
    % Update neuron states
    G       = G * exp(-dt / TG) + [inIa, inTDE] * STR;
    GK      = GK * exp(-dt / TGK) + B * S;
    GTOT    = 1 + GK + G;
    E       = E .* exp(-GTOT * dt / TMEM) + (G*EQ + GK*EK) .* (1 - exp(-GTOT * dt / TMEM)) ./ GTOT;
    TH      = TH0 + (TH - TH0) * exp(-dt / TTH) + C * E * (1 - exp(-dt / TTH));
    S       = (E >= TH);

    % Save output
    outS(k) = sum(S);
    outSdetail(k, :) = S';
    
    % Show progress on screen
    if mod(k, (length(t)-1)/10) < 1
            nrDone = nrDone + 1;
        if nrDone > 1
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b')
        end
        fprintf(['[', char(46*ones(1,nrDone)), char(32*ones(1,10-nrDone)), ']'])
    end  
end
fprintf('\n')

%% Fill output structure
out.time         = t;
out.nrn.S        = outS;
out.nrn.Sdetail  = outSdetail;
out.inputs.rIa   = outrIa;
out.inputs.rII   = outrII;
out.inputs.rTDE   = outrTDE;