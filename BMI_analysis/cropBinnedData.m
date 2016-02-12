function cropData = cropBinnedData(binnedData,StartTime,EndTime)

cropBins  = binnedData.timeframe >=StartTime & binnedData.timeframe <= EndTime;

%% Meta
if isfield(binnedData,'meta')
    trainData.meta = binnedData.meta;
    cropData.meta  = binnedData.meta;
end
    
%% Timeframe
cropData.timeframe = binnedData.timeframe(cropBins,:);

%% EMGs
if isfield(binnedData,'emgdatabin')
    if ~isempty(binnedData.emgdatabin)
        cropData.emgdatabin = binnedData.emgdatabin(cropBins,:);
    end    
end
if isfield(binnedData,'emgguide')
    cropData.emgguide  = binnedData.emgguide;
end
%% Spikes
if isfield(binnedData,'spikeratedata')
    if ~isempty(binnedData.spikeratedata)
        cropData.spikeratedata  = binnedData.spikeratedata(cropBins,:);    
    end
end
if isfield(binnedData,'spikeguide')
    cropData.spikeguide  = binnedData.spikeguide;
end
if isfield(binnedData,'neuronIDs')
    cropData.neuronIDs  = binnedData.neuronIDs;
end
%% Force
if isfield(binnedData,'forcedatabin')
    if ~isempty(binnedData.forcedatabin)
        cropData.forcedatabin  = binnedData.forcedatabin(cropBins,:);
    end
end
if isfield(binnedData,'forcelabels')
    cropData.forcelabels  = binnedData.forcelabels;
end
%% Pos
if isfield(binnedData,'cursorposbin')
    if ~isempty(binnedData.cursorposbin)
        cropData.cursorposbin  = binnedData.cursorposbin(cropBins,:);
    end
end
if isfield(binnedData,'cursorposlabels')
    cropData.cursorposlabels  = binnedData.cursorposlabels;
end
%% Vel
if isfield(binnedData,'velocbin')
    if ~isempty(binnedData.velocbin)
        cropData.velocbin  = binnedData.velocbin(cropBins,:);
    end
end
if isfield(binnedData,'veloclabels')
    cropData.veloclabels  = binnedData.veloclabels;
end
%% Acceleration
if isfield(binnedData,'accelbin')
    if ~isempty(binnedData.accelbin)
        cropData.accelbin  = binnedData.accelbin(cropBins,:);
    end
end
if isfield(binnedData,'acclabels')
    cropData.acclabels  = binnedData.acclabels;
end

%% States



%% Trialtable
if isfield(binnedData,'trialtable')
    if ~isempty(binnedData.trialtable)
        cropData.trialtable  = binnedData.trialtable( (binnedData.trialtable(:,1)>=StartTime ...
                                                       & binnedData.trialtable(:,8)>=StartTime)...
                                                     & (binnedData.trialtable(:,1)<=EndTime ...
                                                       & binnedData.trialtable(:,8)<=EndTime),:);
    end
end
if isfield(binnedData,'trialtablelabels')
    trainData.trialtablelabels = binnedData.trialtablelabels;
    cropData.trialtablelabels  = binnedData.trialtablelabels;
end

%% Words
if isfield(binnedData,'words')
    if ~isempty(binnedData.words)
        cropData.words  = binnedData.words(binnedData.words(:,1)>=StartTime ...
                                                  & binnedData.words(:,1)<=EndTime,:);
    end
end

%% Targets
if isfield(binnedData,'targets') && ~isempty(binnedData.targets.corners)
    if ~isempty(binnedData.targets)  
       cropData.targets.corners  = binnedData.targets.corners(binnedData.targets.corners(:,1)>=StartTime ...
                                                           & binnedData.targets.corners(:,1)<=EndTime,:);
       cropData.targets.rotation  = binnedData.targets.rotation(binnedData.targets.rotation(:,1)>=StartTime ...
                                                           & binnedData.targets.rotation(:,1)<=EndTime,:);
    end
end

%% Stim
end