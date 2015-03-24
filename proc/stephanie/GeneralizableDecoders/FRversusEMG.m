%FRvEMG

cellIndex = 1;
emgInd = 10;
Pos = hypot(binnedData.cursorposbin(:),1), binnedData.cursorposbin(Go2EndInTargetIndices(:),2);
for iTrial = 1:length(trialtable)
    endtime = binnedData.trialtable(iTrial,8);
    intarget = endtime-0.5;
    timeIndices = find(binnedData.timeframe>=intarget & binnedData.timeframe<=endtime);
    EMGactivity = binnedData.emgdatabin(timeIndices,emgInd);
    meanEMG(iTrial,1) = mean(EMGactivity);
    Force = binnedData.emgdatabin(timeIndices,emgInd);
end