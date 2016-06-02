% Combine two binnedData files

%% First File
lastInd = find(binnedData.timeframe == 600);
binnedDataI.timeframe = binnedData.timeframe(1:lastInd);
binnedDataI.emgdatabin = binnedData.emgdatabin(1:lastInd,:);
binnedDataI.forcedatabin = binnedData.forcedatabin(1:lastInd,:);
binnedDataI.spikeratedata = binnedData.spikeratedata(1:lastInd,:);
binnedDataI.cursorposbin = binnedData.cursorposbin(1:lastInd,:);
binnedDataI.velocbin = binnedData.velocbin(1:lastInd,:);

bigTrialtable = find(binnedData.trialtable(:,1) >= 600);
 binnedDataI.trialtable = binnedData.trialtable;
if isempty(bigTrialtable)
    binnedDataI.trialtable(bigTrialtable) =[];
end

 bigWords = find(binnedData.words(:,1) >= 600);
 binnedDataI.words = binnedData.words;
if isempty(bigWords)
    binnedDataI.words(bigWords) =[];
end


SD = std(binnedDataI.emgdatabin);
for a=1:length(binnedDataI.emgdatabin(1,:))
    binnedDataI.emgdatabin(:,a) = binnedDataI.emgdatabin(:,a)/SD(a);
end

%% Second  file

lastInd = find(binnedData.timeframe == 600);
binnedData2.timeframe = binnedData.timeframe(1:lastInd);
binnedData2.emgdatabin = binnedData.emgdatabin(1:lastInd,:);
binnedData2.forcedatabin = binnedData.forcedatabin(1:lastInd,:);
binnedData2.spikeratedata = binnedData.spikeratedata(1:lastInd,:);
binnedData2.cursorposbin = binnedData.cursorposbin(1:lastInd,:);
binnedData2.velocbin = binnedData.velocbin(1:lastInd,:);

bigTrialtable = find(binnedData.trialtable(:,1) >= 600);
 binnedData2.trialtable = binnedData.trialtable;
if isempty(bigTrialtable)
    binnedData2.trialtable(bigTrialtable) =[];
end

 bigWords = find(binnedData.words(:,1) >= 600);
 binnedData2.words = binnedData.words;
if isempty(bigWords)
    binnedData2.words(bigWords) =[];
end

SD = std(binnedData2.emgdatabin);
for a=1:length(binnedData2.emgdatabin(1,:))
    binnedData2.emgdatabin(:,a) = binnedData2.emgdatabin(:,a)/SD(a);
end


%% Append

dt = 0.05;
binnedDataIW.timeframe = cat(1, binnedDataI.timeframe, (binnedData2.timeframe + (binnedDataI.timeframe(end)+dt)));
binnedDataIW.emgdatabin = cat(1, binnedDataI.emgdatabin, binnedData2.emgdatabin);
binnedDataIW.forcedatabin = cat(1, binnedDataI.forcedatabin, binnedData2.forcedatabin);
binnedDataIW.spikeratedata = cat(1,binnedDataI.spikeratedata, binnedData2.spikeratedata);
binnedDataIW.cursorposbin = cat(1, binnedDataI.cursorposbin, binnedData2.cursorposbin);
binnedDataIW.velocbin  = cat(1, binnedDataI.velocbin, binnedData2.velocbin);


binnedData2.trailtable(:,1) = binnedData2.trialtable(:,1) + binnedDataI.timeframe(end)+dt;
binnedDataIW.trialtable  = cat(1, binnedDataI.trialtable, binnedData2.trialtable);

binnedData2.words(:,1) = binnedData2.words(:,1) + binnedDataI.timeframe(end)+dt;
binnedDataIW.words  = cat(1, binnedDataI.words, binnedData2.words);


%% Finalize


 
 binnedData.timeframe = binnedDataIW.timeframe;
 binnedData.emgdatabin = binnedDataIW.emgdatabin;
 binnedData.forcedatabin = binnedDataIW.forcedatabin;
 binnedData.spikeratedata = binnedDataIW.spikeratedata;
 binnedData.cursorposbin = binnedDataIW.cursorposbin;
 binnedData.velocbin = binnedDataIW.velocbin;
 binnedData.trialtable = binnedDataIW.trialtable;
 binnedData.words = binnedDataIW.words;
 binnedData.meta.filename = 'Hybrid_IsoWM_Gry_04-08-13';
 binnedData.meta.duration = binnedDataIW.timeframe(end);
 
