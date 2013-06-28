function [timeCenters, uTimes] = getTimeBinCenters(trialTable, holdTime, winSize, stepSize, reqTrialNum)

% For each trial, separate the hold period into a bin
%   Then, shift in bins of 300 width at intervals of 100 msec
%   Only take complete bins... when it reaches the end and doesn't have
%       a full 300 ms, just ditch the rest
% Make some extra zeros since we don't know how long they have to be
timeCenters = zeros(size(trialTable,1),20);
for iTrial = 1:size(trialTable,1)
    c = 1;
    temp = trialTable(iTrial,7)+winSize/2;
%     while temp < trialTable(iTrial,8)-holdTime-winSize/2
    while temp < trialTable(iTrial,8)-winSize/2
        timeCenters(iTrial,c) = temp-trialTable(iTrial,7);
        temp = temp + stepSize;
        c = c+1;
    end
end

% Trim the extra zeros
timeCenters(:,~any(timeCenters,1)) = [];

% So, trim the time bins that don't have enough trials
numTrials = sum(timeCenters > 0,1);
timeCenters(:,numTrials < reqTrialNum) = [];

% do some trickery to get the timing centers
uTimes = unique(unique(round(1000*timeCenters)/1000))';
uTimes = uTimes(uTimes > 0);