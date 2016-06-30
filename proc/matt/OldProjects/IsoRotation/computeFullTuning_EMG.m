function [pd, p] = computeFullTuning_EMG(emg, offsetFR, thetaTarg, trialTable, tau,doPlots)

% Get the outer hold times
timePeriods = [trialTable(:,7), trialTable(:,8)];

% Get spike count for each channel in each center hold period
baseFR = zeros(size(timePeriods,1),size(emg,2)-1);
for unit = 2:size(emg,2)
    for iTrial = 1:size(timePeriods,1)
        % how many spikes are in this window?
        totAct = sum(emg(emg(:,1) > timePeriods(iTrial,1) & emg(:,1) <= timePeriods(iTrial,2),unit));
        baseFR(iTrial,unit) = totAct ./ (timePeriods(iTrial,2)-timePeriods(iTrial,1));
    end
end

% Fit tuning curves in hold period
[tcs, p] = regressTuningCurves(baseFR,offsetFR,thetaTarg,doPlots);
pd = wrapAngle(tcs(:,3),0);