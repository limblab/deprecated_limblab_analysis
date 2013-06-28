function [pd, p] = computeFullTuning(neural, offsetFR, thetaTarg, trialTable, tau,doPlots)

% Get the outer hold times
timePeriods = [trialTable(:,7), trialTable(:,8)];

% Fit tuning curves for the hold period
timePeriods = timePeriods - tau;

% Get spike count for each channel in each center hold period
baseFR = zeros(size(timePeriods,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(timePeriods,1)
        % how many spikes are in this window?
        spikeCounts = length(ts(ts > timePeriods(iTrial,1) & ts <= timePeriods(iTrial,2)));
        baseFR(iTrial,unit) = spikeCounts ./ (timePeriods(iTrial,2)-timePeriods(iTrial,1));
    end
end

% Fit tuning curves in hold period
[tcs, p] = regressTuningCurves(baseFR,offsetFR,thetaTarg,doPlots);
pd = wrapAngle(tcs(:,3),0);