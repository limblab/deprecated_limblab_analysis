function [pdHold, pHold] = computeHoldPeriodTuning(neural, offsetFR, thetaTarg, trialTable, holdTime, tau,doPlots)

% Get the outer hold times
outHoldPeriods = [trialTable(:,8)-holdTime, trialTable(:,8)];

% Fit tuning curves for the hold period
outHoldPeriods = outHoldPeriods - tau;

% Get spike count for each channel in each center hold period
holdFR = zeros(size(outHoldPeriods,1),length(neural));
for unit = 1:length(neural)
    ts = neural(unit).ts;
    for iTrial = 1:size(outHoldPeriods,1)
        % how many spikes are in this window?
        spikeCounts = length(ts(ts > outHoldPeriods(iTrial,1) & ts <= outHoldPeriods(iTrial,2)));
        holdFR(iTrial,unit) = spikeCounts ./ (outHoldPeriods(iTrial,2)-outHoldPeriods(iTrial,1));
    end
end

% Fit tuning curves in hold period
[tcsHold, pHold] = regressTuningCurves(holdFR,offsetFR,thetaTarg,doPlots);
pdHold = wrapAngle(tcsHold(:,3),0);