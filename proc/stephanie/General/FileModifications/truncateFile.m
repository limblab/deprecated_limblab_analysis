%Truncate file

%% First File
firstInd = find(binnedData.timeframe == 0);
lastInd = find(binnedData.timeframe == 600);
binnedDataI.timeframe = binnedData.timeframe(firstInd:lastInd);
binnedDataI.emgdatabin = binnedData.emgdatabin(firstInd:lastInd,:);
binnedDataI.forcedatabin = binnedData.forcedatabin(firstInd:lastInd,:);
binnedDataI.spikeratedata = binnedData.spikeratedata(firstInd:lastInd,:);
binnedDataI.cursorposbin = binnedData.cursorposbin(firstInd:lastInd,:);
binnedDataI.velocbin = binnedData.velocbin(firstInd:lastInd,:);

bigTrialtable = find(binnedData.trialtable(:,1) >= lastInd);
 binnedDataI.trialtable = binnedData.trialtable;
if isempty(bigTrialtable)
    binnedDataI.trialtable(bigTrialtable) =[];
end

 bigWords = find(binnedData.words(:,1) >= lastInd);
 binnedDataI.words = binnedData.words;
if isempty(bigWords)
    binnedDataI.words(bigWords) =[];
end

 binnedDataI.emgdatabin = binnedDataIW.emgdatabin;
 binnedDataI.forcedatabin = binnedDataIW.forcedatabin;
 binnedDataI.spikeratedata = binnedDataIW.spikeratedata;
 binnedDataI.cursorposbin = binnedDataIW.cursorposbin;
 binnedDataI.velocbin = binnedDataIW.velocbin;
