function plot_states(states_struct)
% Plots output from 'compare_states'
%
% state_struct = 
%         states_struct.spike_struct = spike_struct;
%         states_struct.scatter_cell = scatter_cell;
%         states_struct.spike_means = spike_means;
%         states_struct.spikeguide = spikeguide;
%         states_struct.vel_maps = vel_maps;
%         states_struct.states = states;
%         states_struct.units = units;
%         states_struct.pds = pds;
%   `     states_struct.threshold = threshold;
%
%% To-Do
%
%-PLOTTING
%   -improve PD text placement on scatter plot
%   -add anti-PD rates to scatter?
%-ANALYSIS
%   -make sure the GLM PD's are theoretically rigorous with swap to
%   'binnedData' for input (ask Brian)
%   -look at posture stuff based on 'preferred location' (cut screen into
%   quads/octants and compare firing rate distribution in different
%   areas)... basically same as heat map but with position-x and position-y
%   instead of vel-x and vel-y
%   -looking systematically at individual neurons: check quality of sorting
%   in Offline Sorter, check PD (with tightness of tuning) in each state
%   and across entire data set
%   ...some kind of sinusoid that takes into account both speed and
%   direction (one for each of 8 directions? Hz as f(speed) or vice versa)
%   -simulate neurons?
%   -function for heat map: count/indicate which blocks have no data
%
%% Initialize variables from input struct fields
spike_struct = states_struct.spike_struct;
scatter_cell = states_struct.scatter_cell;
spike_means = states_struct.spike_means;
spikeguide = states_struct.spikeguide;
vel_maps = states_struct.vel_maps;
states = states_struct.states;
units = states_struct.units;
pds = states_struct.pds;
threshold = states_struct.threshold;
%add function that automatically runs through 'states_struct' and assigns
%each field to a non-struct-field variable (AKA: do what this cell does)?


%% Plot outputs of interest

%HISTOGRAM INITIALIZATION
    %-Initialize arrays
    if isfield(spike_struct,'spikerates')
        spikerates = spike_struct.spikerates;
        disp('Spike rates filtered for PD.');
        flt = 1;
    else
        spikerates = spike_struct.spike_wins;
        disp('All spike data counted, PDs ignored.');
        flt = 0;
    end
    %-Remove '-1' placeholders if data is already filtered for PD's; calc means
    if flt
        [M_states, P_states] = get_PD_idcs(spikerates,states);
    else
        M_states =  states;
        P_states = ~states;
    end
    %-Figure parameters
    bins = 0:(6+2/3):200;
    axesM = '[-10 150 0 0.3]';
    axesS = '[-10 150 0 0.3]';
    X  = 120;
    Ym = '0.3*0.9'; % x/y position on plot of text containing mean firing rate
    Ys = '0.3*0.9';
    disp(sprintf('Histogram mean spike rate threshold: %d Hz',threshold));

%SPEED SCATTER PLOT INITIALIZATION
%pull unit numbers out of cell array into matrix
    u_nums = zeros(size(scatter_cell,1),1);
    for i = 1:size(scatter_cell,1)
        u_nums(i) = scatter_cell{i,2};
    end
    u_nums = u_nums(find(u_nums));
    x_max = 50; %max x value (hard-coded into sd_speed_scatter as 'bin3')
    xt = 35; %x text location

%PLOT EVERYTHING
for i = 1:length(units)
        
    
    figure
    
    if size(M_states,2) > 1
        % if we have created a <<num_bins>> x <<num_units>> states matrix
        % storing classifier and PD state info...
        m_states = M_states(:,units(i));
        p_states = P_states(:,units(i));
    else
        % if we only have classifier state info...
        m_states = M_states;
        p_states = P_states;
    end

    %-histograms
    subplot(2,2,1)
    [histcount, binout] = hist(spikerates(m_states,units(i)),  bins);
    histcount = histcount/sum(histcount); %normalize
    bar(binout, histcount,1);
    textlabel = num2str(spike_means(units(i),1));
    text(X, eval(Ym), textlabel);
    axis(eval(axesM));
    title(strcat(['unit ' spikeguide(units(i),:)]));
    ylabel('movement');

    subplot(2,2,3)
    [histcount, binout] = hist(spikerates(p_states,units(i)), bins);
    histcount = histcount/sum(histcount); %normalize
    bar(binout, histcount,1);
    textlabel = num2str(spike_means(units(i),2));
    text(X, eval(Ys), textlabel);
    axis(eval(axesS));
    xlabel('spiking frequency');
    ylabel('posture');

    %-speed scatter plot
    idx = find(u_nums==units(i),1);
    if ~isempty(idx)
        this_unit = scatter_cell{idx,1}; % [ speed  firing_rate ]
        subplot(2,2,2)
        plot(this_unit(:,1),this_unit(:,2),'.');
        y_min = min(this_unit(:,2) - 10);
        y_max = max(this_unit(:,2) + 10);
        axis( [0 x_max y_min y_max] );
        yt = y_min + (y_max-y_min)*0.15; %y_min + 10;
        pd = round(pds(i)*100)/100;
        strlabel = strcat(['PD: ' num2str(pd)]);
        text(xt,yt,strlabel);
        xlabel('Speed along PD (cm/s)');
        ylabel('Firing rate (Hz)');
    else
        disp(strcat(['Unit ' spikeguide(units(i),:) ' not found.']));
    end

    %-firing rate vs. velocity heat map
    subplot(2,2,4)
    vmap = vel_maps{units(i)};
    xv = zeros(size(vmap,1),1);
    vmap = [vmap xv]; %#ok<AGROW>
    yv = zeros(1,size(vmap,2));
    vmap = [vmap; yv]; %#ok<AGROW>
    surf(vmap);
    view(0,90);
    colormap(gray);
    colorbar;
    axis( [1 21 1 21] ); % these values will have to change if binning is changed in 'create_vel_spikemaps'
    xlabel('x-velocity');
    ylabel('y-velocity');
        
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