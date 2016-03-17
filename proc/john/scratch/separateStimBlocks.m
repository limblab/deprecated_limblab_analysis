function [spikeMask, eventMask, spikeBlocks, eventBlocks] = ...
    separateStimBlocks(spikeTimes,eventTimes,stimCycle)
% SEPARATESTIMBLOCKS - Return indices covering the stim blocks defined in
% 'stimCycle'
%
% INPUT:
%       'spikeTimes' - Spike times (sec) of a sorted unit from get_sorted_units()
%       'eventTimes' - List of times (sec) of events during trial (e.g. GO_CUE)
%       'stimCycle' - OFF,ON times for stimulation. Time in minutes.
%           ex: [OFF1Start OFF1End ON1Start ON1End OFF2Start OFF2End ...]
%               [0 10 10.5 22.5 23 31.5 31.7 34.2];
%
% OUTPUT:
%       'spikeMask' - logical array, masking spike times
%       'eventMask' - logical array
%       'spikeBlocks' - Cell array of spike times (sec) split into stim blocks
%       'eventBlocks' - Cell array of event times (sec) split into stim blocks
%           -> 3rd row is idxs of event times (can be used to split trial
%           table)
%
% Created by John W. Miller
% 2014-08-13

n_blocks = length(stimCycle)/2;     % OFF or ON blocks
iState = 0; % Stimulation state. OFF=0, ON=1
iBlock = 1;

% Cell arrays for spike and event times (sec) separated by stim block
spikeBlocks = cell(2,n_blocks);
eventBlocks = cell(2,n_blocks);

% Logical indices for all spike and event times
n_spikes    = length(spikeTimes);
n_events    = length(eventTimes);
spikeMask   = zeros(n_spikes,n_blocks);
eventMask   = zeros(n_events,n_blocks);

%% Separate spike times
for ii = 1:2:length(stimCycle)
    n_spikes = 0;
    
    
    %% Spike Mask
    if iBlock > 1
       prevPeriodEnd = find(spikeMask(:,iBlock-1)==1,1,'last');
    else
       prevPeriodEnd = 0;
    end   
    
    % Range of indices in 'spikeTimes' for current block
    botEnd = find(spikeTimes/60 >= stimCycle(ii),1,'first');
    if botEnd <= prevPeriodEnd 
        warning('Overlapping region in "stimCycle". \nBlock Number: %d',iBlock)
%         botEnd = prevPeriodEnd + 1;
    elseif (botEnd-prevPeriodEnd) > 3
        warning('Missing more than 3 indices between stim blocks. \nBlock Number: %d',iBlock)
    end
    
    topEnd = find(stimCycle(ii+1) >= spikeTimes/60,1,'last');
    spikeBlocks{1,iBlock} = iState;
    spikeBlocks{2,iBlock} = spikeTimes(botEnd:topEnd,:); % Idx -> time
        % Logical mask for idxs within current block
    spikeMask(botEnd:topEnd,iBlock) = 1;
    
    
    %% Event Mask
    if iBlock > 1
       prevPeriodEnd = find(spikeMask(:,iBlock-1)==1,1,'last');
    else
       prevPeriodEnd = 0;
    end
    % Range of indices in 'eventTimes' for current block
    botEnd = find(eventTimes/60 >= stimCycle(ii),1,'first');
%     if botEnd <= prevPeriodEnd 
%         botEnd = prevPeriodEnd + 1;
%     end  
    topEnd = find(stimCycle(ii+1) >= eventTimes/60,1,'last');
    eventBlocks{1,iBlock} = iState;
    eventBlocks{2,iBlock} = eventTimes(botEnd:topEnd,:); % Idx -> time
        % Logical mask for idxs within current block
    eventMask(botEnd:topEnd,iBlock) = 1;

    iState = 1 - iState;
    iBlock = iBlock + 1;
end

% Convert to actual logical arrays
spikeMask = logical(spikeMask);
eventMask = logical(eventMask);




