function offsetFR = computeBaselineFR(neural, trialTable, tau)

%%% The goal here is to compute the non-directional component
% Use the inner hold period to calculate offset for each cell
%   ie this is when there is no activation
inHoldPeriods = [trialTable(:,1), trialTable(:,7)];
inHoldPeriods = inHoldPeriods - tau;

% Get spike count for each channel in each center hold period
offsetFR = zeros(size(inHoldPeriods,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(inHoldPeriods,1)
        % how many spikes are in this window?
        spikeCounts = length(ts(ts > inHoldPeriods(iTrial,1) & ts <= inHoldPeriods(iTrial,2)));
        offsetFR(iTrial,unit) = spikeCounts ./ (inHoldPeriods(iTrial,2)-inHoldPeriods(iTrial,1));
    end
end

% let offset be mean across trials
offsetFR = mean(offsetFR,1);