function [FR_and_groups] = tuningCurveStats(bdf, tt, stimCycle)
% TUNINGCURVESTATS - Compute firing rate based on target direction
%
% INPUT:
%       'stimCycle' - OFF,ON times for stimulation. Time in minutes.
%           ex: [OFF1Start OFF1End ON1Start ON1End OFF2Start OFF2End ...]
%               [0 10 10.5 22.5 23 31.5 31.7 34.2];
%
%
% OUTPUT:
%
% Created by John W. Miller
% 2014-07-24
%

%% Define constants
tt_label = 4; % 4 = GO CUE; 5 = MOVEMENT ONSET
bin = .3;     % seconds after cue (for calc. firing rate)

% Sorted units (time stamps from bdf)
[sorted_units, channels]  = get_sorted_units(bdf);
n_neurons     = length(sorted_units);

% Time stamps of each cue (each time is new trial)
cue_times = tt(:, tt_label);
n_trials  = 0;
% Stimulation states
n_states = 2; % OFF or ON
n_blocks = length(stimCycle)/n_states; % OFF or ON blocks
trialBlocksIdxs = cell(2,n_blocks); % Trial ranges for the different blocks

%% Group trials into stimulation ON or OFF
iState = 0; % Stimulation state. OFF = 0, ON=1
iBlock = 1;
for ii = 1:2:length(stimCycle)
    botEnd = find(cue_times/60 >= stimCycle(ii),1,'first');
    topEnd = find(stimCycle(ii+1) >= cue_times/60,1,'last');
    trialBlocksIdxs{1,iBlock} = iState;
    trialBlocksIdxs{2,iBlock} = [trialBlocksIdxs{2,iBlock} botEnd:topEnd];
    n_trials = n_trials + length(botEnd:topEnd);
    iState = 1 - iState;
    iBlock = iBlock + 1;
end

%% Calculate firing rates
FR_and_groups = cell(n_neurons,5);
FR_and_groups{1,1} = 'Mean FRs';
FR_and_groups{1,2} = 'Direction';
FR_and_groups{1,3} = 'Stim. Block';
FR_and_groups{1,4} = 'Stim. I/O';
FR_and_groups{1,5} = 'Channel Info';

for n_neuron = 1:n_neurons
    iNeuron  = sorted_units{n_neuron};
    
    firingRates = [];
    dirGroup    = [];
    blockGroup  = [];
    stateGroup  = [];
        
    % Indices of spikes within 'bin' seconds of go cue for every trial
    spikesNearCue =...
        bsxfun(@ge, iNeuron, cue_times') & bsxfun(@le, iNeuron, (cue_times + bin)');
    
    for iBlock = 1:n_blocks
       trialRange = trialBlocksIdxs{2,iBlock}; % Trials within current block
              
       % Calculate FR for each trial, keeping track of dir, block, etc.
       for iTrial = trialRange
          iDir = tt(iTrial,12); % 12 = target direction
          
          n_spikes = sum(spikesNearCue(:,iTrial)); % # of spikes for iTrial
          rate = n_spikes/bin; % Spikes/sec

          firingRates = [firingRates;  rate];
          dirGroup    = [dirGroup;     iDir];
          blockGroup  = [blockGroup; iBlock];
          stateGroup  = [stateGroup; trialBlocksIdxs{1,iBlock}];
       end
    end
        
    FR_and_groups{n_neuron+1,1} = firingRates;
    FR_and_groups{n_neuron+1,2} = dirGroup;
    FR_and_groups{n_neuron+1,3} = blockGroup;
    FR_and_groups{n_neuron+1,4} = stateGroup;
    FR_and_groups{n_neuron+1,5} = channels(n_neuron,:);
end
