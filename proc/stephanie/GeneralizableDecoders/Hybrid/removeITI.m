

% 

timeInds = find(binnedData.timeframe >= 0 & binnedData.timeframe <= binnedData.trialtable(1,1));
for i=1:length(binnedData.trialtable)
    % Cycle through the trial table and get the timestamps for start and end
    % trial
    
    trialEnd = binnedData.trialtable(i,8);
   
    
    if i == length(binnedData.trialtable)
        indices = find(binnedData.timeframe >= trialEnd & binnedData.timeframe <= binnedData.timeframe(end));
    else
         nexttrialStart = binnedData.trialtable(i+1,1);
        indices = find(binnedData.timeframe >= trialEnd & binnedData.timeframe <= nexttrialStart);
    end

timeInds = cat(1,timeInds,indices);
end

    
newBinned = binnedData;
newBinned.timeframe = 0:0.05:length(timeInds)*.05;
newBinned.emgdatabin(timeInds,:) = [];
newBinned.forcedatabin(timeInds,:) = [];
newBinned.cursorposbin(timeInds,:)=[];
newBinned.spikeratedata(timeInds,:)=[];
newBinned.accelbin(timeInds,:) = [];
newBinned.velocbin(timeInds,:) = [];

% figure
% plot(binnedData.timeframe,binnedData.cursorposbin(:,1),'k')
% hold on
% plot(binnedData.timeframe,newBinned.cursorposbin(:,1),'r')









