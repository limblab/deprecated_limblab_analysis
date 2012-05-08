function [units, spike_means] = get_unit_states(spike_struct, threshold)
% Does not actually return whether each unit is an M-class or S-delta
% neuron, though that is a future functionality that could be added
%
% ACTUAL FUNCTION: Selects which units to plot/analyze based on 'threshold'
%     threshold = abs( mean(spikerates(M_state)) - mean(spikerates(P_state)) )
%
% INPUT:
%   -'spike_struct': struct created by 'pre_kin_windows' or
%   'sd_pd_filt'
%   -'threshold': number denoting which units to list
%   (set threshold=0 to get all units)
%
%% Initialization

%-Initialize arrays
if isfield(spike_struct,'spikerates')
    spikerates = spike_struct.spikerates;
    disp('Spike rates filtered for PD.');
    flt = 1;
else
    spikerates = spike_struct.spike_wins;
    disp('Counting all spike data. PDs ignored.');
    flt = 0;
end

states = spike_struct.states(:,1);

%% Remove '-1' placeholders if data is already filtered for PD's; calc means
if flt
    [M_states, P_states] = get_PD_idcs(spikerates,states);
    spike_means = calc_spike_means(spikerates,M_states,P_states);
else
    M_states =  states;
    P_states = ~states;
    spike_means = calc_spike_means(spikerates,M_states,P_states);
end


%% Pass index of unit if the difference between means is above 'threshold'

mn_diffs = abs( spike_means(:,1)-spike_means(:,2) );
units = zeros(size((mn_diffs>=threshold),1),1);
u_name = 0;
for unit=1:size(spikerates,2)
    % Only pass index if the difference between the mean firing rates is above
    % threshold
    if mn_diffs(unit) >= threshold
        u_name = u_name+1;
        units(u_name) = unit;    
    end
end

units = units(find(units));

%% Internal functions

function [M_states, P_states] = get_PD_idcs(spikerates,states)
% how do I want to do this? what all do I want it to do? well, to start:
%   -instead of actually paring down 'spikerates', why not create two
%   different states: an 'M_state' and a 'P_state', where both ignore any
%   values of -1. Yes, I think I like that.

M_states = zeros(size(spikerates));
P_states = zeros(size(spikerates));
disp('Finding non-negative values');
for unit = 1:size(spikerates,2)
    
    spikes = spikerates(:,unit);
    in_PD = zeros(size(spikes,1),1);
    in_PD(spikes>=0) = in_PD(spikes>=0)+1;
    in_PD = logical(in_PD);
    M_states(:,unit) = in_PD &  states;
    P_states(:,unit) = in_PD & ~states;
    
end

M_states = logical(M_states);
P_states = logical(P_states);


function spike_means = calc_spike_means(spikerates,M_states,P_states)
% Calculate mean spiking rate for each unit
% OUTPUT: [ M_state_mean P_state_mean ]

disp('Calculating mean firing rates...');

spike_means = zeros(size(spikerates,2),2);
for unit=1:size(spikerates,2)

    if size(M_states,2) > 1
        % if we have created a <<num_bins>> x <<num_units>> states matrix
        % storing classifier and PD state info...
        m_states = M_states(:,unit);
        p_states = P_states(:,unit);
    else
        % if we only have classifier state info...
        m_states = M_states;
        p_states = P_states;
    end
    
    mn_M = mean(spikerates(m_states,unit));
    mn_P = mean(spikerates(p_states,unit));
    spike_means(unit,:) = round([ mn_M mn_P ]);

end
