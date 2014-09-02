% 7/7/14
% Make some plots of firing rates and stuff during tDCS

% get_trial_tables

%%

% Select which day's data to analyse
day = 2;

% bdf and trial table
if day == 1
    bdf = day1bdf;
    trial_table = day1tt;
    stim1ON  = 10; % minutes
    stim1OFF = 19;
        % Stimulation on/off train (minutes):
        % [stim1ON stim1OFF 2ON 2OFF 3ON etc.]
    stimCycle = [10 19]; % 'stimCycle' MUST be even pairs of on/off
    yMax = 5;
elseif day == 2
    bdf = day2bdf;
    trial_table = day2tt;
        % Stimulation on/off train:
    stimCycle = [10.5 22.5 32 34];
    yMax = 15;
end   
trains = get_sorted_units(bdf); % Timestamps of sorted units
tt_label = 4; % Specify which event to align on (for DCO, 4 = GO CUE)

% Cue times
cue_times = trial_table(:, tt_label); % Time stamps of each cue (each time is new trial)
n_trials = length(cue_times);

% Sorted units
sorted_units = get_sorted_units(bdf);
n_neuron = 3;
iNeuron = sorted_units{n_neuron};

% Time window
t1 = 1; % Back end of time window (seconds)
t2 = 3; % Front end
sampleInterval = 0.01; % sec
rate = 1/sampleInterval;

% Find spikes within window of cue for each trial
spikesInWindow = bsxfun(@ge, iNeuron, (cue_times - t1)') & bsxfun(@le, iNeuron, (cue_times + t2)');

% Indices of cue_times of stimulations on and off
endOfControl = find(cue_times/60 <= stimCycle(1),1,'last');
stimIdxs = [1 endOfControl];
for iStim = 1:2:length(stimCycle)
    onIdx = find(cue_times/60 >= stimCycle(iStim),1,'first');
    offIdx = find(stimCycle(iStim+1) >= cue_times/60,1,'last');
    stimIdxs = [stimIdxs onIdx offIdx];
end

%% Peri-Stimulus Time Histogram

bin = 0.1; % Time bin for histogram (sec)
edges = -1.5:bin:1.5;   % Time range, seconds

for iStimIdx = 1:2:length(stimIdxs)
    psth = zeros(length(edges),1);
    % ---------------------------------------------------
    for iTrial = iStimIdx:(iStimIdx+1)
        t_cue = cue_times(iTrial);

        if isfinite(t_cue)% && t_cue/60 < 10
                % Find spikes for current trial within window of cue
            iSpikes = iNeuron(spikesInWindow(:,iTrial));

            % Add current trial's spike times to count of total spikes around cue
            % for each trial
            N = histc(iSpikes - t_cue, edges);
            if size(N) == size(psth)
                psth = psth + N;
            end
        end
    end
    fs = 20;
    figure
    bar(edges,psth, 'histc')
    xlim([-1.1 1])
    ylim([0 yMax])
    xlabel('Time (sec)')
    ylabel('# of spikes')
    plot_title = sprintf('PSTH - \nneuron #%d ',n_neuron);
    title(plot_title,'FontSize',fs + 2)

end












if 0

%% PST Histogram

iNeuron = trains{8};

n_trials = length(trains);
cue_times = DCO.trial_table(:,DCO.table_columns.t_go_cue);
bin = .1; % Time bin in seconds
edges = -1:bin:1;   % Time range, seconds
psth = zeros(length(edges),1);

for iTrial = 10:n_trials
    t_cue = cue_times(iTrial);              % Time of GO_CUE, seconds
    
    % Add current trial's spike times
    N = histc(iNeuron(iSpikes) - t_cue, edges);
    if size(N) == size(psth)
        psth = psth + N;
    end
end

%% Plot all units Firing Rate

n_units = length(trains);

histMax = 40; % Minutes
histMax = histMax * 60;
bin = .2; % Seconds
EDGES = 0:bin:(histMax);
scale = 60/bin;

fs = 20;
%%
% Day 1
day = 1;
trains = get_sorted_units(day1bdf);
stim1ON  = 10*scale; % (scale aligns the stimulation times with the bin)
stim1OFF = 19*scale;
%%
% Day 2
day = 2;
trains = get_sorted_units(day2bdf);
stim1ON  = 10.5*scale;
stim1OFF = 22.5*scale;
stim2ON  = 32*scale;
stim2OFF = 34.5*scale;
%%

for iUnit = 10:20
    [N,BINS] = histc(trains{iUnit},EDGES);
    firingRate = N/bin;
    figure;
    plot(firingRate)
    xlabel('Time (?)','FontSize',fs)
    ylabel('Mean firing rate','FontSize',fs)
    plot_title = sprintf('Mean firing rate vs. Time - \n Day %d, Unit #%d ', day, iUnit);
    title(plot_title,'FontSize',fs + 2)
    yRange = range(firingRate);
    line('XData',[stim1ON stim1ON], 'YData',[0 yRange],'LineStyle', '-', ...
        'LineWidth', 2, 'Color','r');
    line('XData',[stim1OFF stim1OFF], 'YData',[0 yRange],'LineStyle', '-', ...
        'LineWidth', 2, 'Color','k');
    if day == 2
        line('XData',[stim2ON stim2ON], 'YData',[0 yRange],'LineStyle', '-', ...
            'LineWidth', 2, 'Color','r');
        line('XData',[stim2OFF stim2OFF], 'YData',[0 yRange],'LineStyle', '-', ...
            'LineWidth', 2, 'Color','k');
    end
end

end












