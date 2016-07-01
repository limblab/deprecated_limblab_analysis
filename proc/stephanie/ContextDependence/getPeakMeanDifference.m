function [peakDifference nadirDifference] = getPeakMeanDifference(out_struct, unit, time1, time2)

% Epoch: 
% Get epoch length so that you can later use it to get the firing rate
EpochLength = time2-time1;

binSize = 0.025;  %in s

counts = []; runningcount = []; allTs = [];
for trialNo = 1:length(time1)
    EpochIndices = find(out_struct.units(1,unit).ts > time1(trialNo) & out_struct.units(1,unit).ts < time2(trialNo));
    ts = out_struct.units(1,unit).ts(EpochIndices);
    ts = ts-time1(trialNo);
    allTs = cat(1,allTs,ts);
end
binrange = 0+(binSize/2):binSize:EpochLength(1)-(binSize/2);
countsPerBin = hist(allTs,binrange);
hz = (countsPerBin/binSize)/(length(time1));
meanHz = mean(hz);
peakHz = max(hz);
nadirHz = min(hz);
peakDifference = peakHz-meanHz;
nadirDifference = peakHz-meanHz;