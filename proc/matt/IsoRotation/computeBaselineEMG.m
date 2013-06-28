function offsetFR = computeBaselineEMG(emg, trialTable, tau)

%%% The goal here is to compute the non-directional component
% Use the inner hold period to calculate offset for each cell
%   ie this is when there is no activation
inHoldPeriods = [trialTable(:,1), trialTable(:,7)];
inHoldPeriods = inHoldPeriods - tau;

% Get spike count for each channel in each center hold period
offsetFR = zeros(size(inHoldPeriods,1),size(emg,2)-1);
for unit = 2:size(emg,2)
    for iTrial = 1:size(inHoldPeriods,1)
        % how many spikes are in this window?
        totAct = sum(emg(emg(:,1) > inHoldPeriods(iTrial,1) & emg(:,1) <= inHoldPeriods(iTrial,2),unit));
        offsetFR(iTrial,unit) = totAct ./ (inHoldPeriods(iTrial,2)-inHoldPeriods(iTrial,1));
    end
end

% let offset be mean across trials
offsetFR = mean(offsetFR,1);