% PDSim.m
%
% Simulates neurons responding to center out movements/bumps and calculates
% thier PDs

%%% Define simulation parameters
nTrials = 100;
nTargets = 8;
window = .3; % 0.3s = 300ms

% tuning curve params
mu = 20;    % baseline firing rate
phi = pi/2; % 90 degrees (up)
A = 15;     % amplitude of tuning curve

%%% Simulate a bunch of trials

% start by block randomizing target directions
targets = [];
while length(targets) < nTrials
    targets = [targets randperm(nTargets)];
end
targets = targets(1:nTrials); % truncate off any extra trials at the end

% find the direction of each target
theta = 2*pi*targets/nTargets;

% get the actual firing rate (in Hz) for each trial
r = mu + A * cos(theta - phi);
lambda = r * window; % convert to poisson rates: E(# spikes)

% get number of spikes for each trial
s = poissrnd(lambda);

%%% Find PD

% Now that we have the directions of each bump (theta) and the number of
% spikes in the observation window (s) we can calculate the PD. Note that
% the actual method starts here and you would normally just have these two
% lists of numbers. Everything up to this point has been to simulate a
% cosine tunded neuron.

x = s .* cos(theta);
y = s .* sin(theta);

PD = atan2(mean(y), mean(x));


