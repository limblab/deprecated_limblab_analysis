


% Cycle through the trial table and get the timestamps for start and end
% trial

% Get your movement on timestamps
% totalPos = hypot(binnedData.cursorposbin(:,1),binnedData.cursorposbin(:,2));
% Vel = diff(totalPos); Vel = double(Vel);
% peakInd = find(findpeaks(Vel, 'minpeakdistance', 23));
% [VelPeaks VelIndices] = findpeaks(Vel,'minpeakheight',0.8,'minpeakdistance',10);
% MoveONind = VelIndices-2;
% MoveON = (binnedData.timeframe(MoveONind-1));

timeInds = [];
for i=1:length(binnedData.trialtable)
trialEnd = binnedData.trialtable(i,8);
startOuterHold = binnedData.trialtable(i,8)-1;

% Get the timeframe index for trialEnd and startOuterHold
indices = find(binnedData.timeframe >= startOuterHold & binnedData.timeframe <= trialEnd);
timeInds = cat(1,timeInds,indices);
end

xVals = 1:1:length(timeInds);
% appendedEMGs = binnedData.emgdatabin(timeInds,:);


appendedEMGs = binnedData.emgdatabin;
appendedEMGs(timeInds,:)=0;

figure
hold on
%plot(xVals',appendedEMGs(:,10))

plot(binnedData.timeframe,binnedData.emgdatabin(:,11),'k')
hold on
plot(binnedData.timeframe,appendedEMGs(:,11),'b')



%%

