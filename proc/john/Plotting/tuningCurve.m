function [firingRates,std_spike_count,std_error,modulation] = tuningCurve(bdf, tt, stimCycle, varargin)
% TUNINGCURVE - Plot a tuning curve from a bdf, split into time sections
% based on 'stimCycle'.
%
% INPUT: 'stimCycle': [Off1Start Off1End On1Start On1End Off2Start etc.]
%        (times, not indices - minutes)
%        'tt_label': 4 is GOCue based on Ricardo's DCO_trial_table function
%

% varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS; %#ok<*UNRCH>

    show_plot = 1;
    tt_label = 5;
    bin = .3;
    neurons = [];
    stdError = 0;
            
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
stimIdxs = [];
for iBlock = 1:2:length(stimCycle)
    stimIdxs = [stimIdxs find(cue_times/60 >= stimCycle(iBlock),1,'first')];
    stimIdxs = [stimIdxs find(stimCycle(iBlock+1) >= cue_times/60,1,'last')];
end
% Number of time blocks
n_blocks = length(stimCycle)/2;

% Target directions
directions = unique(tt(:,12));
dirDegrees = directions*(180/pi);
n_dirs     = length(directions);

mean_spike_count = zeros(n_dirs,n_blocks,n_neurons);
std_spike_count  = zeros(n_dirs,n_blocks,n_neurons);
std_error        = zeros(n_dirs,n_blocks,n_neurons);
modulation       = zeros(n_blocks,n_neurons);

%%
% Repeat for each specified neuron

for iNeuron = neurons
    one_neuron = sorted_units{iNeuron};
    
    if show_plot
        figure
        hold on
    end
    
    % Spikes within 'bin' of cue
    spikesInWindow =...
        bsxfun(@ge, one_neuron, cue_times') & bsxfun(@le, one_neuron, (cue_times + bin)');
    
        % Separate based on stimulation block (OFF/ON/Off, etc.)
    iBlock = 1;
    stimOn = 0; % Assume that stimulation starts OFF
    for iStimIdx = 1:2:length(stimIdxs)
        
        trialRange = stimIdxs(iStimIdx):stimIdxs(iStimIdx+1);

        % Count the number of spikes for each trial in each direction
        for iDir = 1:length(directions)
            trialsInDirection = find(tt(trialRange,12) == directions(iDir));
            n_trials = length(trialsInDirection);
            % Spikes within time window of cue, that occured on trials in current direction
            iSpikes = spikesInWindow(:,trialsInDirection);
            
            % Make sure there is at least one trial in current direction
            if n_trials > 0
                mean_spike_count(iDir,iBlock,iNeuron) = sum(sum(iSpikes))/n_trials;
                std_spike_count(iDir,iBlock,iNeuron)  = std(sum(iSpikes));
                std_error(iDir,iBlock,iNeuron)        = std(sum(iSpikes))/sqrt(n_trials);
                
            else
                msg='0 trials for direction %d. Adding NaN to mean and std';
                warning(msg,iDir)
                mean_spike_count(iDir,iBlock,iNeuron) = NaN;
                std_spike_count(iDir,iBlock,iNeuron)  = NaN;
            end
                        
        end
        
        firingRates = mean_spike_count/bin;
        modulation(iBlock,iNeuron) = range(firingRates(:,iBlock,iNeuron));

       
            % Change color based on stimulation block
            if stimOn
                colors = colormap(autumn);
                color  = colors(iBlock*9,:);
                legend_entries(iStimIdx,:) = 'ON ';
                stimOn=0;
            else
                colors = colormap(gray);
                color  = colors(iBlock*12,:);
                legend_entries(iStimIdx,:) = 'OFF';
                stimOn=1;
            end
            
        %% Plotting
        if show_plot
%             color = colors(iBlock,:);
            % Plot firing rate vs. target direction
            plot(dirDegrees,firingRates(:,iBlock,iNeuron),'Color', color,'LineWidth',2)
            
            % Error bars
            if stdError == 0
                error_bars = std_spike_count;
                errorBars = 'Std. Dev.';
            else
                error_bars = std_error;
                errorBars = 'Std. Error';
            end
            patch([dirDegrees' fliplr(dirDegrees')],[(firingRates(:,iBlock,iNeuron)'+error_bars(:,iBlock,iNeuron)'), ...
                fliplr(firingRates(:,iBlock,iNeuron)'-error_bars(:,iBlock,iNeuron)')],color,'FaceAlpha',0.25,'EdgeAlpha',0);
            xlim([0 315])
            ylim([0 50])
        end
        iBlock = iBlock + 1; % Keep track of which stimulation block we're in
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