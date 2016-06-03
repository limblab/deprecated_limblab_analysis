function [sponRatePerTrial] = spontFiringRates(spikeTimes, holdStarts)
% SPONTFIRINGRATES -
%
% INPUT: 
%
% OUTPUT: 
%
% Created by John W. Miller
% 2014-08-25
%

%% Calculate firing rates
postHoldTime = 0.4; % sec -- determined in 'plotMovements()'

spikesInWindow =...
    bsxfun(@ge, spikeTimes, holdStarts') & bsxfun(@le, spikeTimes, (holdStarts+postHoldTime)');

    % If the window length changes
% windowLengths =...
%     bsxfun(@minus, (holdStarts+postHoldTime), holdStarts);

windowLengths = postHoldTime;

% Number of spikes within window between hold and go cue
nSpikesPerTrial   = sum(spikesInWindow)';
sponRatePerTrial  = nSpikesPerTrial./windowLengths;

sponRate_avg      = mean(sponRatePerTrial);
sponRate_dev      = std(sponRatePerTrial);
sponRate_stdErr   = sponRate_dev/sqrt(length(sponRatePerTrial));


end