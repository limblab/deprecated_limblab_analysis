function [EMGmeans EMGstdplus EMGstdminus time] = EMGpeth(binnedData,tasktype,tgtNo,EMGind)

% Create trial table
trialtable = GetFixTrialTableWBinnedFile(binnedData,tasktype);
%--------------------------------------------------------------------------
% Separate out trial table into 2 and 3 force level trialtables
TgtNoindices = find(trialtable(:,10)==tgtNo);
trialtableforTgt = trialtable(TgtNoindices,:);

%--------------------------------------------------------------------------

% Rasters aligned on movement
preEvent = 1;    %in s
postEvent = 2;   %in s
binSize = 0.025;  %in s
%numBins = (postEvent+preEvent)/binSize; Do I need this?
binVals =  (binSize/2)-preEvent:binSize:postEvent-(binSize/2);

% Create total position and velocity variable
totalPos = hypot(binnedData.cursorposbin(:,1),binnedData.cursorposbin(:,2));
Vel = diff(totalPos);

% Find time when cursor is in the target
InTarget_FirstTimestamp =  trialtableforTgt(:,8)-0.5;

EMGind = EMGind;
for i = 1:length(trialtableforTgt(:,1))
    
    
    % Get your event times
    OTon(i) = trialtableforTgt(i,6);
    endTime = OTon(i)+postEvent;
    trialEnd(i) = trialtableforTgt(i,8);
    
    % Get your movement on timestamps
    OTtoEndIndices = find(binnedData.timeframe >= OTon(i) & binnedData.timeframe <= endTime);
    VelOTon2End = Vel(OTtoEndIndices+1);
    [peak peakInd] = max(VelOTon2End);
    MoveONind = peakInd-10+OTtoEndIndices(1);
    MoveON = binnedData.timeframe(MoveONind,1);
    
    % Initialize your AlignEvent
    AlignEvent = MoveON;
    timeIndices = find(binnedData.timeframe >= (AlignEvent - preEvent-.0000001) & binnedData.timeframe <= (AlignEvent + postEvent-.0000001));
    time = binnedData.timeframe(timeIndices)-AlignEvent;
    
    % Get EMG data for each trial
    EMGvalues(i,:) = binnedData.emgdatabin(timeIndices,EMGind);
    
end

EMGmeans = mean(EMGvalues)
EMGstd = std(EMGvalues)
EMGstdplus = EMGmeans+EMGstd;
EMGstdminus = EMGmeans-EMGstd;

end






        