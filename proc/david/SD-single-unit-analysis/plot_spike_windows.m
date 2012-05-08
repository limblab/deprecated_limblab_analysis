function units_plotted = plot_spike_windows(spike_struct, threshold)
% Plots output from 'spike_window_histograms.m'
% INPUT:
%   -'spike_struct': struct created by 'spike_window_histograms' or
%   'sd_pd_filt'
%   -'threshold': number denoting which units to plot... plots unit if
%   abs(mean(spike_rate[posture]) - mean(spike_rate[movement])) > threshold
%   (set threshold=0 to plot all units)
%% To-Do
% So, I don't particularly like how I'm doing this right now, but it's a
% quick and dirty way to get some plots out quickly

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
spikeguide  = spike_struct.spikeguide;
states      = spike_struct.states(:,1);

%% Remove '-1' placeholders if data is already filtered for PD's; calc means
if flt
    [M_states, P_states] = get_PD_idcs(spikerates,states);
    spike_means = calc_spike_means(spikerates,M_states,P_states);
else
    M_states =  states;
    P_states = ~states;
    spike_means = calc_spike_means(spikerates,M_states,P_states);
end


%% Plot histograms
%-Initialize plot parameters/options
bins = 0:(6+2/3):200;
axesM = '[-10 200 0 sum(m_states)/3]';
axesS = '[-10 200 0 sum(p_states)/3]';
X  = 150;
Ym = '0.9*sum(m_states)/3'; % x/y position on plot of text containing mean firing rate
Ys = '0.9*sum(p_states)/3';

mn_diffs = abs( spike_means(:,1)-spike_means(:,2) );
units_plotted = zeros(size((mn_diffs>=threshold),1),1);
u_name = 0;
%-Plot histograms
for unit=1:size(spikerates,2)
    % Only plot if the difference between the mean firing rates is above
    % threshold
    if mn_diffs(unit) >= threshold
        u_name = u_name+1;
        units_plotted(u_name) = unit;
        figure
        
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
        
        subplot(2,1,1)
        [histcount, binout] = hist(spikerates(m_states,unit),  bins);
        bar(binout, histcount,1)
        textlabel = num2str(spike_means(unit,1));
        text(X, eval(Ym), textlabel)
        axis(eval(axesM))
        title(spikeguide(unit,:))
        ylabel('movement')

        subplot(2,1,2)
        [histcount, binout] = hist(spikerates(p_states,unit), bins);
        bar(binout, histcount,1)
        textlabel = num2str(spike_means(unit,2));
        text(X, eval(Ys), textlabel)
        axis(eval(axesS))
        xlabel('spiking frequency')
        ylabel('posture')
    
    end
end

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
