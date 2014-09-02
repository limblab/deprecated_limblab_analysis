function [movementFRs, spontaneousFRs] = calcFiringRates(...
    spikeTimes, eventTimes, eventDirections, holdStarts)
% calcFiringRates -
%
% INPUT:
%       'spikeTimes' - spike times (sec)
%       'eventTimes' - times (sec) of events (probably GO Cues)
%       'eventDirections' - same size as 'eventTimes', each trial's direction
%       'holdTimes'  - times (sec) of center target hold_on
% OUTPUT:
%       'movementFRs' - Cell array: firing rates during 'bin' after 'eventTimes'
%       'spontaneousFRs' - Cell array: Spontaneous firing rate, calculated during hold time
%
% Created by John W. Miller
% 2014-08-15
%
%%

bin = .3; % seconds

% Target directions
directions = unique(eventDirections);
dirDegrees = directions*(180/pi);

%% Mean firing rates
% Spikes within 'bin' of 'eventTimes' for each trial
spikesInWindow =...
    bsxfun(@ge, spikeTimes, eventTimes') & bsxfun(@le, spikeTimes, (eventTimes + bin)');

% Direction of each trial
trialsInDirection =...
    bsxfun(@eq, eventDirections, directions');
trialsPerDirection = sum(trialsInDirection);

% Number of spikes within 'bin' of cue for each trial
nSpikesPerTrial    = sum(spikesInWindow)';
firingRatePerTrial = nSpikesPerTrial/bin;

% Mean firing rate for each direction
for iDir = 1:length(directions)
    inCurDir = trialsInDirection(:,iDir) == 1;
    n_trials = trialsPerDirection(iDir);
    movFRs(iDir,1) = sum(firingRatePerTrial(inCurDir))/n_trials;
    movFRs_std(iDir,1)  = std(firingRatePerTrial(inCurDir));
    movFRs_stdErr(iDir,1) = movFRs_std(iDir,1)/sqrt(n_trials);
end
movementFRs = {movFRs; movFRs_std; movFRs_stdErr};

%% Spontaneous firing rates

spikesInWindow =...
    bsxfun(@ge, spikeTimes, holdStarts') & bsxfun(@le, spikeTimes, (holdStarts+.4)');
windowLengths =...
    bsxfun(@minus, eventTimes, holdStarts);

% Number of spikes within window between hold and go cue
nSpikesPerTrial   = sum(spikesInWindow)';
sponRatePerTrial = nSpikesPerTrial./windowLengths;
sponRate_avg      = mean(sponRatePerTrial);
sponRate_dev      = std(sponRatePerTrial);
sponRate_stdErr   = sponRate_dev/sqrt(length(sponRatePerTrial));

spontaneousFRs = {sponRate_avg; sponRate_dev; sponRate_stdErr};


end


