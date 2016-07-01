function epochSSPerTrial = getSSPerEpoch(out_struct, unit, time1, time2)



binSize = 0.025;  %in s

for trialNo = 1:length(time1)
    EpochIndices = find(out_struct.units(1,unit).ts > time1(trialNo) & out_struct.units(1,unit).ts < time2(trialNo));
    ts = out_struct.units(1,unit).ts(EpochIndices);
    if isempty(ts)
        counts = 0;
    else
        binrange = ts(1)+(binSize/2):binSize:ts(end)-(binSize/2);
        counts = histc(ts,binrange);
    end
    epochSSPerTrial(trialNo,1) = sumsqr(counts);
end
