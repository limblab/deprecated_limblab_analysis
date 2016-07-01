function epochMeansPerTrial = getFRmeansPerEpoch(out_struct, unit, time1, time2)

% Epoch: 
% Get epoch length so that you can later use it to get the firing rate
EpochLength = time2-time1;

NumTimestamps = nan(length(time1),1);
for trialNo = 1:length(time1)
    EpochIndices = find(out_struct.units(1,unit).ts > time1(trialNo) & out_struct.units(1,unit).ts < time2(trialNo));
    NumTimestamps(trialNo,1) = length(EpochIndices);
end
epochMeansPerTrial = NumTimestamps./EpochLength;
