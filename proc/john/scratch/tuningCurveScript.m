% Produce a tuning curve using bdf's
%

% load_trial_tables

%% Select and organize data
% Select which day's data to analyse
day = 2;

clear legend_entries
% bdf and trial table
if day == 1
    bdf = day1bdf;
    trial_table = day1tt;
    % Stimulation on/off train (minutes):
        % [Off1Start Off1End Stim1Start Stim1End Off2Start etc.]
        stimCycle = [0 9.5 10 19]; % 'stimCycle' MUST be even pairs of on/off
%     fastNeurons = [4 9 10 14 17 18 19 23 24 25 26 27 30 31 32 33];
    neurons = 19;
    yMax = 30;
elseif day == 2
    bdf = day2bdf;
    trial_table = day2tt;
    stimCycle = [0 10 10.5 22.5 23 31.5 31.7 34.2];
    yMax = 35;
    neurons = [29 31];
end
trains = get_sorted_units(bdf); % Timestamps of sorted units
tt_label = 4; % Specify which event to align on (for DCO, 4 = GO CUE)

% Cue times
cue_times = trial_table(:, tt_label); % Time stamps of each cue (each time is new trial)
% n_trials = length(cue_times);

% Sorted units
sorted_units = get_sorted_units(bdf);
n_neurons = length(sorted_units);

%%


% Indices of cue_times of stimulations on and off
stimIdxs = [];
for iBlock = 1:2:length(stimCycle)
    stimIdxs = [stimIdxs find(cue_times/60 >= stimCycle(iBlock),1,'first')];
    stimIdxs = [stimIdxs find(stimCycle(iBlock+1) >= cue_times/60,1,'last')];
end
n_blocks = length(stimCycle)/2;

bin = .5; % Time bin for calculating FR (seconds)
directions = unique(trial_table(:,12));
dirDegrees = directions*(180/pi);

mean_spike_count = zeros(length(directions),n_blocks,n_neurons);
std_spike_count  = zeros(length(directions),n_blocks,n_neurons);

% Plot for each specified neuron
for iNeuron = 1:n_neurons
    one_neuron = sorted_units{iNeuron};
    stimOn = 0;
    
    figure
    colors = colormap(lines(n_blocks*2));
    hold on
    
    % Separate based on stimulation block (OFF/ON/Off, etc.)
    iBlock = 1;
    for iStimIdx = 1:2:length(stimIdxs)
        
        trialRange = stimIdxs(iStimIdx):stimIdxs(iStimIdx+1);
        
        spikesInWindow  = bsxfun(@ge, one_neuron, cue_times') & bsxfun(@le, one_neuron, (cue_times + bin)');
        spikesInWindow  = spikesInWindow(:,trialRange);
        
        % Count the number of spikes for each trial in each direction
        for iDir = 1:length(directions)
            trialsInDirection = find(trial_table(trialRange,12) == directions(iDir));
            n_trials = length(trialsInDirection);
            
            iSpikes = spikesInWindow(:,trialsInDirection);
            if n_trials > 0
                mean_spike_count(iDir,iBlock,iNeuron) = sum(sum(iSpikes))/n_trials;
                std_spike_count(iDir,iBlock,iNeuron)  = std(sum(iSpikes));
            else
                msg='0 trials for direction %d. Adding NaN to mean and std';
                warning(msg,iDir)
                mean_spike_count(iDir,iBlock,iNeuron) = NaN;
                std_spike_count(iDir,iBlock,iNeuron)  = NaN;
            end
            
        end
        firingRates = mean_spike_count/bin;
        
        % Change color based on stimulation block
        if stimOn
            color = 'r';
            legend_entries(iStimIdx,:) = 'ON ';
            stimOn=0;
        else
            color = 'k';
            legend_entries(iStimIdx,:) = 'OFF';
            stimOn=1;
        end
        
        % Plot firing rate vs. target direction
        plot(dirDegrees,firingRates(:,iBlock,iNeuron),'Color', color,'LineWidth',2)
        patch([dirDegrees' fliplr(dirDegrees')],[(firingRates(:,iBlock,iNeuron)'+std_spike_count(:,iBlock,iNeuron)'), ...
            fliplr(firingRates(:,iBlock,iNeuron)'-std_spike_count(:,iBlock,iNeuron)')],color,'FaceAlpha',0.25,'EdgeAlpha',0);
        
%         h = errorbar(dirDegrees,firingRates,stdeviation);
%         set(h,'Color',color)
        xlim([0 315])
        ylim([0 yMax])

        iBlock = iBlock + 1;
    end
%     if mean(firingRates) >= 4
%             fastNeurons = [fastNeurons iNeuron];
%     end
    fs=20;
    ylabel('Firing Rate (Hz)')
    xlabel('Target Direction (degrees)')
    plot_title = sprintf('Firing rate vs. Target Dir. - \n Unit #%d ', iNeuron);
    title(plot_title,'FontSize',fs + 2)
    legend(legend_entries)
    pause
end
