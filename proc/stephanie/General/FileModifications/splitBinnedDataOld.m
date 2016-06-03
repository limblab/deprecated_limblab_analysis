function [trainData,testData] = splitBinnedData(binnedData,splitTime)

    trainData = binnedData;
    testData  = binnedData;
    
    binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
    splitBin  = round(splitTime/binsize);

%% Timeframes
    
    trainData.timeframe = binnedData.timeframe(1:splitBin);
    testData.timeframe  = binnedData.timeframe(splitBin+1:end);


%% EMGs

    trainData.emgdatabin = binnedData.emgdatabin(1:splitBin,:);
    testData.emgdatabin  = binnedData.emgdatabin(splitBin+1:end,:);
    
%% Spikes

    trainData.spikeratedata = binnedData.spikeratedata(1:splitBin,:);
    testData.spikeratedata  = binnedData.spikeratedata(splitBin+1:end,:);
    
%% Force

    trainData.forcedatabin = binnedData.forcedatabin(1:splitBin,:);
    testData.forcedatabin  = binnedData.forcedatabin(splitBin+1:end,:);

%% Pos

    trainData.cursorposbin = binnedData.cursorposbin(1:splitBin,:);
    testData.cursorposbin  = binnedData.cursorposbin(splitBin+1:end,:);

%% Vel

    trainData.velocbin = binnedData.velocbin(1:splitBin,:);
    testData.velocbin  = binnedData.velocbin(splitBin+1:end,:);
    
%% Accel
    trainData.accelbin = binnedData.accelbin(1:splitBin,:);
    testData.accelbin  = binnedData.accelbin(splitBin+1:end,:);

%% States



%% Trialtable

    trainData.trialtable = binnedData.trialtable(binnedData.trialtable(:,1)<=splitTime,:);
    testData.trialtable  = binnedData.trialtable(binnedData.trialtable(:,1)>splitTime,:);

%% Words
    trainData.words = binnedData.words(binnedData.words(:,1)<=splitTime,:);
    testData.words  = binnedData.words(binnedData.words(:,1)>splitTime,:);

    

%% Targets

   trainData.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)<=splitTime,:);
   testData.targets.corners  = binnedData.targets.corners(binnedData.targets.corners(:,1)>splitTime,:);

   trainData.targets.rotation = binnedData.targets.rotation(binnedData.targets.rotation(:,1)<=splitTime,:);
   testData.targets.rotation  = binnedData.targets.rotation(binnedData.targets.rotation(:,1)>splitTime,:);


%% Stim
end
