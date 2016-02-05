function [] = psth(bdf, tt, stimCycle, varargin)
% PSTH - Make a peri-stimulus time histogram from a bdf, split into time sections
% based on 'stimCycle'.
%
% INPUT: 'stimCycle': [Off1Start Off1End On1Start On1End Off2Start etc.]
%        (times, not indices - minutes)
%        'tt_label': 4 is GOCue based on Ricardo's DCO_trial_table function
%

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS;

    tt_label = 4;
    neurons = [];
                
END_DEFINE_CONSTANTS;


%% Get time stamps of sorted units in 'bdf'
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

% Time window
t1 = 1; % Back end of time window (seconds)
t2 = 3; % Front end




%% Create the PSTH

% Repeat for each specified neuron
for iNeuron = neurons
    one_neuron = sorted_units{iNeuron};
    spikesAroundCue = bsxfun(@ge, one_neuron, (cue_times - t1)') & bsxfun(@le, one_neuron, (cue_times + t2)');
    
        % Separate based on stimulation block (OFF/ON/Off, etc.)
    iBlock = 1;
    stimOn = 0; % Assume that stimulation starts OFF
    for iStimIdx = 1:2:length(stimIdxs)
        bin = .05;
        edges = -1.5:bin:1.5;   % Time range, seconds
        psth = zeros(length(edges),1);
        
        trialRange = stimIdxs(iStimIdx):stimIdxs(iStimIdx+1);
        n_trials = length(trialRange);
       
        % ---------------------------------------------------
        for iTrial = trialRange
            t_cue = cue_times(iTrial);
            
            if isfinite(t_cue)% && t_cue/60 < 10
                % Find spikes for current trial within window of cue
                iSpikes = spikesAroundCue(:,iTrial);
                spikes = one_neuron(iSpikes);
                
                % Add current trial's spike times to count of total spikes around cue
                % for each trial
                N = histc(spikes - t_cue, edges)/n_trials;
                if size(N) == size(psth)
                    psth = psth + N;
                end
            end
        end
        fs = 20;
        figure
        bar(edges,psth, 'histc')
        xlim([-1.1 1])
        ylim([0 0.5])
        xlabel('Time (sec)')
        ylabel('# of spikes')
        plot_title = sprintf('PSTH - \nneuron #%d ',iNeuron);
        title(plot_title,'FontSize',fs + 2)

    end

       
end

end