function [pdHold, pHold] = computeHoldPeriodTuning_EMG(emg, offsetFR, thetaTarg, trialTable, holdTime, tau,doPlots)

% Get the outer hold times
outHoldPeriods = [trialTable(:,8)-holdTime, trialTable(:,8)];

% Fit tuning curves for the hold period
outHoldPeriods = outHoldPeriods - tau;

% Get spike count for each channel in each center hold period
holdFR = zeros(size(outHoldPeriods,1),size(emg,2)-1);
for unit = 2:size(emg,2)
    for iTrial = 1:size(outHoldPeriods,1)
        % how many spikes are in this window?
        totAct = sum(emg(emg(:,1) > outHoldPeriods(iTrial,1) & emg(:,1) <= outHoldPeriods(iTrial,2),unit));
        holdFR(iTrial,unit) = totAct ./ (outHoldPeriods(iTrial,2)-outHoldPeriods(iTrial,1));
    end
end


% Fit tuning curves in hold period
[tcsHold, pHold] = regressTuningCurves(holdFR,offsetFR,thetaTarg,doPlots);
pdHold = wrapAngle(tcsHold(:,3),0);