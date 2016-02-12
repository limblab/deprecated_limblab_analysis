function [eventMask,n_blocks] = separateStimBlocks_2(eventTimes,stimCycle,varargin)
% SEPARATESTIMBLOCKS_2 - Splits timestamps in 'eventTimes' into blocks defined by 'stimCycle'
%
% INPUT:
%       'eventTimes' - Column vector of time stamps in sec. (spike times, event times, etc.)
%       'stimCycle'  - OFF,ON times for stimulation. Time in minutes.
%           ex: [OFF1Start OFF1End ON1Start ON1End OFF2Start OFF2End ...]
%               [0 10 10.5 22.5 23 31.5 31.7 34.2];
%
% OUTPUT:
%       'eventMask' - logical array, [m x n_blocks]
%
% Created by John W. Miller
% 2014-08-27

% varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS; %#ok<*UNRCH>
    warn = 1;
END_DEFINE_CONSTANTS;



n_blocks = length(stimCycle)/2;     % OFF or ON blocks
iState = 0; % Stimulation state. OFF=0, ON=1
iBlock = 1;



% Logical indices for all event times
n_events    = length(eventTimes);
eventMask   = zeros(n_events,n_blocks);
prevPeriodEnd = 0;

%% Separate event times
for ii = 1:2:length(stimCycle)
    
    % Find the indices of times within 'eventTimes' falling within current block
    botEnd = find(eventTimes/60 >= stimCycle(ii),1,'first');
    topEnd = find(stimCycle(ii+1) >= eventTimes/60,1,'last');
    
    % Check if there is overlap  or large gap between current and previous block
    if botEnd <= prevPeriodEnd 
        if warn;warning('Overlapping region in "stimCycle". \nBlock Number: %d',iBlock);end;
    elseif (botEnd-prevPeriodEnd) > 3
        if warn;warning('Missing more than 3 indices between stim blocks. \nBlock Number: %d',iBlock);end;
    end
        
    prevPeriodEnd = topEnd;
    
    % Logical mask for idxs within current block
    eventMask(botEnd:topEnd,iBlock) = 1;

    iState = 1 - iState;
    iBlock = iBlock + 1;
end

% Convert to actual logical arrays
eventMask = logical(eventMask);




