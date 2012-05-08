function states_struct = compare_states(binnedData)
% Utilizes multiple functions/steps of functions to analyze binned,
% classified data for looking at the hypothesis of posture vs. movement
% neural states and collects the various sub-plots into a single plot
%
% There may be (IS) some redundancy in the processing, but we can take care
% of that later
%
% The fields of 'states_struct' will be the outputs of the individual
% functions called through this:
%   states_struct = ...
%             states_struct.spike_struct = spike_struct (from 'pre_kin_windows')
%             states_struct.scatter_cell = scatter_cell (from 'sd_speed_scatter')
%             states_struct.spike_means = spike_means   (from 'get_unit_states')
%             states_struct.spikeguide = spikeguide     (directly from 'binnedData')
%             states_struct.vel_maps = vel_maps         (from 'create_vel_spikemaps')
%             states_struct.states = states             (directly from 'binnedData')
%             states_struct.units = units               (from 'get_unit_states')
%             states_struct.threshold = threshold       (simply for future reference)
%

%% Calculate outputs of interest
%-Initialize
bin_size = 4; % cm/s - bin size for 'create_vel_spikemaps'
threshold = 0; % spike rate difference between states above which we will plot
states = binnedData.states(:,1);
spikeguide = binnedData.spikeguide; % channel names/unit numbers

%-Calculate firing rates for windows covering t = -250ms => -100ms (t = 0
% defined by kinematics timepoint)
%THIS IS CALLED BY 'create_vel_spikemaps', so is not actually needed here
%spike_struct = pre_kin_windows(binnedData);

%-Calculate x-/y-velocity heat maps showing firing rates
[spike_struct, vel_maps] = create_vel_spikemaps(binnedData,bin_size);

%-Calculate mean firing rates for each speed bin while cursor is moving
% along PD
[scatter_cell, pds] = sd_speed_scatter(binnedData);

%-Find units to look at
[units, spike_means] = get_unit_states(spike_struct, threshold);

%-Output
disp(sprintf('Histogram mean spike rate threshold: %d Hz',threshold));
states_struct.spike_struct = spike_struct;
states_struct.scatter_cell = scatter_cell;
states_struct.spike_means = spike_means;
states_struct.spikeguide = spikeguide;
states_struct.vel_maps = vel_maps;
states_struct.states = states;
states_struct.units = units;
states_struct.pds = pds;
states_struct.threshold = threshold; % only for future reference;



