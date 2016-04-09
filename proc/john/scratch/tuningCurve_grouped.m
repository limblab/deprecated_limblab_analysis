function [firingRates,std_spike_count,std_error,modulation] = tuningCurve(bdf, tt, stimCycle, varargin)
% TUNINGCURVE - Plot a tuning curve from a bdf, split into time sections
% based on 'stimCycle'.
%
% INPUT: 'stimCycle': [Off1Start Off1End On1Start On1End Off2Start etc.]
%        (times, not indices - minutes)
%        'tt_label': 4 is GOCue based on Ricardo's DCO_trial_table function
%

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS; %#ok<*UNRCH>

    show_plot = 1;
    tt_label  = 4;
    bin = .3;
    neurons   = [];
    stdError  = 0;
            
END_DEFINE_CONSTANTS;


%% Sorted units and time stamps
sorted_units = get_sorted_units(bdf);

% Analyze all sorted units if user has not supplied 'neurons'
if length(neurons) == 0
    n_neurons = length(sorted_units);
    neurons = 1:n_neurons;
else
    n_neurons = length(neurons);
end

% Time stamps of each cue (each time is new trial)
cue_times = tt(:, tt_label);

% Find indices of cue_times of stimulations on and off
n_states = 2; %(OFF & ON)
stimIdxs = cell(1,n_states);

stimOn = 0; % Stimulation starts off
% Group trials into stimulation ON or OFF
for iBlock = 1:2:length(stimCycle)
    botEnd = find(cue_times/60 >= stimCycle(iBlock),1,'first');
    topEnd = find(stimCycle(iBlock+1) >= cue_times/60,1,'last');
    stimIdxs{stimOn+1} = [stimIdxs{stimOn+1} botEnd:topEnd];
    stimOn = 1 - stimOn;
end
% Number of time blocks
n_blocks = length(stimCycle)/2;

% Target directions
directions = unique(tt(:,12));
dirDegrees = directions*(180/pi);
n_dirs     = length(directions);


mean_spike_count = zeros(n_dirs,n_states,n_neurons);
std_spike_count  = zeros(n_dirs,n_states,n_neurons);
std_error        = zeros(n_dirs,n_states,n_neurons);
modulation       = zeros(n_states,n_neurons);

%%
% Repeat for each specified neuron

for iNeuron = neurons
    one_neuron = sorted_units{iNeuron};
    
    if show_plot
        figure
        colors = colormap(lines);
        hold on
    end
        % Separate based on stimulation block (OFF/ON/Off, etc.)
    iBlock = 1;
    stimOn = 0; % Assume that stimulation starts OFF
    for iStateIdx = 1:n_states
        
        trialRange = stimIdxs{stimOn+1};
        
        
        % Spikes within 'bin' of cue
        spikesInWindow  = bsxfun(@ge, one_neuron, cue_times') & bsxfun(@le, one_neuron, (cue_times + bin)');

        
        % Count the number of spikes for each trial in each direction
        for iDir = 1:length(directions)
            trialsInDirection = find(tt(trialRange,12) == directions(iDir));
            n_trials = length(trialsInDirection);
            % Spike indices within time window of cue, that occured on trials in current direction
            iSpikes = spikesInWindow(:,trialsInDirection);

% Make sure there is at least one trial in current direction
            if n_trials > 0
                mean_spike_count(iDir,stimOn + 1,iNeuron) = sum(sum(iSpikes))/n_trials;
                std_spike_count(iDir,stimOn + 1,iNeuron)  = std(sum(iSpikes));
                std_error(iDir,stimOn + 1,iNeuron)        = std(sum(iSpikes))/sqrt(n_trials);
            else
                msg='0 trials for direction %d. Adding NaN to mean and std';
                warning(msg,iDir)
                mean_spike_count(iDir,stimOn + 1,iNeuron) = NaN;
                std_spike_count(iDir,stimOn + 1,iNeuron)  = NaN;
            end
            
            
        end
        
        firingRates = mean_spike_count/bin;
        modulation(stimOn + 1,iNeuron) = range(firingRates(:,stimOn + 1,iNeuron));

       
            % Change color based on stimulation block
            if stimOn
                color = 'r';
                legend_entries(iStateIdx,:) = 'ON ';
            else
                color = 'k';
                legend_entries(iStateIdx,:) = 'OFF';
            end
            
        %% Plotting
        if show_plot
            color = colors(stimOn + 1,:);
            % Plot firing rate vs. target direction
            plot(dirDegrees,firingRates(:,stimOn + 1,iNeuron),'Color', color,'LineWidth',2)
            
            % Error bars
            if stdError == 0
                error_bars = std_spike_count;
                errorBars = 'Std. Dev.';
            else
                error_bars = std_error;
                errorBars = 'Std. Error';
            end
            patch([dirDegrees' fliplr(dirDegrees')],[(firingRates(:,stimOn + 1,iNeuron)'+error_bars(:,stimOn + 1,iNeuron)'), ...
                fliplr(firingRates(:,stimOn + 1,iNeuron)'-error_bars(:,stimOn + 1,iNeuron)')],color,'FaceAlpha',0.25,'EdgeAlpha',0);
            xlim([0 315])
            ylim([0 35])
        end
%         iBlock = iBlock + 1; % Keep track of which stimulation block we're in
        stimOn = 1 - stimOn;
    end
    if show_plot
        fs=20;
        ylabel('Firing Rate (Hz)')
        xlabel('Target Direction (degrees)')
        plot_title = sprintf('Firing rate vs. Target Dir. - \n Unit #%d - %s ', iNeuron, errorBars);
        title(plot_title,'FontSize',fs + 2)
        legend(legend_entries)
        pause
    end
end

end