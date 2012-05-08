function spike_struct = pre_kin_windows(binnedData)
% Creates larger bins for spiking in windows preceding a kinematic
% timepoint by 'win_lag' seconds

%-Initialize
win_lag    = 0.25; % lag in sec (how far behind kinematics timepoint we will look at spiking activity)
win_length = 0.15; % in sec
states     = binnedData.states;
spikerates = binnedData.spikeratedata;

bin_size   = binnedData.timeframe(2) - binnedData.timeframe(1);
win_start  = round(win_lag/bin_size); % convert to bins
win_bins   = round(win_length/bin_size); % convert to bins

spike_wins = zeros(size(spikerates));
%% To-Do
% -interested also in width of distribution? (stddev/whatever)


%% Count spikes in designated window for each channel

% CONVERT FREQUENCIES TO SPIKES PER BIN (was spikes/second)
spikerates = spikerates*bin_size;

% SUM SPIKES INTO WINDOWS (i.e. BIGGER BINS)
for x = win_start+1:length(spike_wins)
    init = x - win_start; % tmp variable for 'spikerates' sum start index
    spike_wins(x,:) = sum(spikerates(init:init+win_bins, :), 1);
end

% CONVERT WINDOWED SPIKE COUNTS INTO Hz
spike_wins = spike_wins/win_length;

%% compile spiking means for each channel

%MAYBE CALCULATE THIS ONLY IN 'plot_spike_windows'? OR WHERE? EITHER WAY,
%IT HAS TO HAPPEN POST-PD-FILTERING
spike_means = zeros(size(spike_wins,2),2);
for x=1:size(spike_wins,2)

    mnM = mean(spike_wins( states(:,1),x));
    mnP = mean(spike_wins(~states(:,1),x));
    mnM = round(mnM);
    mnP = round(mnP);
    spike_means(x,:) = [ mnM mnP ]; %[ mean(movementState) mean(postureState) ]

end

spike_struct.states = states;
spike_struct.spikeguide  = binnedData.spikeguide;
spike_struct.spike_means = spike_means;
spike_struct.spike_wins  = round(spike_wins);


