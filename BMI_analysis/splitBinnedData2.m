function [data1,data2] = splitBinnedData2(binnedData,split_time)

data1bin = binnedData.timeframe < split_time;    
data2bin = binnedData.timeframe >=split_time;

%% Meta
if isfield(binnedData,'meta')
    data1.meta = binnedData.meta;
    data2.meta  = binnedData.meta;
end
    
%% Timeframes
data1.timeframe = binnedData.timeframe(data1bin,:);    
data2.timeframe = binnedData.timeframe(data2bin,:);

%% EMGs
if isfield(binnedData,'emgdatabin')
    if ~isempty(binnedData.emgdatabin)
        data1.emgdatabin= binnedData.emgdatabin(data1bin,:);
        data2.emgdatabin = binnedData.emgdatabin(data2bin,:);
    end    
end
if isfield(binnedData,'emgguide')
    data1.emgguide = binnedData.emgguide;
    data2.emgguide  = binnedData.emgguide;
end
%% Spikes
if isfield(binnedData,'spikeratedata')
    if ~isempty(binnedData.spikeratedata)
        data1.spikeratedata = binnedData.spikeratedata(data1bin,:);
        data2.spikeratedata  = binnedData.spikeratedata(data2bin,:);    
    end
end
if isfield(binnedData,'spikeguide')
    data1.spikeguide = binnedData.spikeguide;
    data2.spikeguide  = binnedData.spikeguide;
end
if isfield(binnedData,'neuronIDs')
    data1.neuronIDs = binnedData.neuronIDs;
    data2.neuronIDs  = binnedData.neuronIDs;
end
%% Force
if isfield(binnedData,'forcedatabin')
    if ~isempty(binnedData.forcedatabin)
        data1.forcedatabin = binnedData.forcedatabin(data1bin,:);
        data2.forcedatabin  = binnedData.forcedatabin(data2bin,:);
    end
end
if isfield(binnedData,'forcelabels')
    data1.forcelabels = binnedData.forcelabels;
    data2.forcelabels  = binnedData.forcelabels;
end
%% Pos
if isfield(binnedData,'cursorposbin')
    if ~isempty(binnedData.cursorposbin)
        data1.cursorposbin = binnedData.cursorposbin(data1bin,:);
        data2.cursorposbin  = binnedData.cursorposbin(data2bin,:);
    end
end
if isfield(binnedData,'cursorposlabels')
    data1.cursorposlabels = binnedData.cursorposlabels;
    data2.cursorposlabels  = binnedData.cursorposlabels;
end
%% Vel
if isfield(binnedData,'velocbin')
    if ~isempty(binnedData.velocbin)
        data1.velocbin = binnedData.velocbin(data1bin,:);
        data2.velocbin  = binnedData.velocbin(data2bin,:);
    end
end
if isfield(binnedData,'veloclabels')
    data1.veloclabels = binnedData.veloclabels;
    data2.veloclabels  = binnedData.veloclabels;
end
%% Acceleration
if isfield(binnedData,'accelbin')
    if ~isempty(binnedData.accelbin)
        data1.accelbin = binnedData.accelbin(data1bin,:);
        data2.accelbin  = binnedData.accelbin(data2bin,:);
    end
end
if isfield(binnedData,'acclabels')
    data1.acclabels = binnedData.acclabels;
    data2.acclabels  = binnedData.acclabels;
end

%% States



%% Trialtable
if isfield(binnedData,'trialtable')
    if ~isempty(binnedData.trialtable)
        data1.trialtable = binnedData.trialtable( (binnedData.trialtable(:,1)<split_time ...
                                                       & binnedData.trialtable(:,8)<split_time),:);
        data2.trialtable  = binnedData.trialtable( (binnedData.trialtable(:,1)>=split_time ...
                                                       & binnedData.trialtable(:,8)>=split_time),:);
    end
end
if isfield(binnedData,'trialtablelabels')
    data1.trialtablelabels = binnedData.trialtablelabels;
    data2.trialtablelabels  = binnedData.trialtablelabels;
end

%% Words
if isfield(binnedData,'words')
    if ~isempty(binnedData.words)
        data1.words = binnedData.words(binnedData.words(:,1)<split_time,:);
        data2.words  = binnedData.words(binnedData.words(:,1)>=split_time,:);
    end
end

%% Targets
if isfield(binnedData,'targets') && ~isempty(binnedData.targets.corners)
    if ~isempty(binnedData.targets)
       data1.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)<split_time,:);   
       data2.targets.corners  = binnedData.targets.corners(binnedData.targets.corners(:,1)>=split_time,:);
       data1.targets.rotation = binnedData.targets.rotation(binnedData.targets.rotation(:,1)<split_time,:);   
       data2.targets.rotation  = binnedData.targets.rotation(binnedData.targets.rotation(:,1)>=split_time,:);
    end
end

%% Stim
end