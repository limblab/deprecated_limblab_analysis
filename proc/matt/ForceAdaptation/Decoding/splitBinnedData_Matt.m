function [trainData,testData] = splitBinnedData_Matt(binnedData,testStartTime,testEndTime)

trainBins = binnedData.timeframe < testStartTime | binnedData.timeframe >  testEndTime;    
testBins  = binnedData.timeframe >=testStartTime & binnedData.timeframe <= testEndTime;

%% Meta
if isfield(binnedData,'meta')
    trainData.meta = binnedData.meta;
    testData.meta  = binnedData.meta;
end
    
%% Timeframes
trainData.timeframe= binnedData.timeframe(trainBins,:);    
testData.timeframe = binnedData.timeframe(testBins,:);

%% EMGs
if isfield(binnedData,'emgdatabin')
    if ~isempty(binnedData.emgdatabin)
        trainData.emgdatabin= binnedData.emgdatabin(trainBins,:);
        testData.emgdatabin = binnedData.emgdatabin(testBins,:);
    end    
end
if isfield(binnedData,'emgguide')
    trainData.emgguide = binnedData.emgguide;
    testData.emgguide  = binnedData.emgguide;
end
%% Spikes
if isfield(binnedData,'spikeratedata')
    if ~isempty(binnedData.spikeratedata)
        trainData.spikeratedata = binnedData.spikeratedata(trainBins,:);
        testData.spikeratedata  = binnedData.spikeratedata(testBins,:);    
    end
end
if isfield(binnedData,'spikeguide')
    trainData.spikeguide = binnedData.spikeguide;
    testData.spikeguide  = binnedData.spikeguide;
end
%% Force
if isfield(binnedData,'forcedatabin')
    if ~isempty(binnedData.forcedatabin)
        trainData.forcedatabin = binnedData.forcedatabin(trainBins,:);
        testData.forcedatabin  = binnedData.forcedatabin(testBins,:);
    end
end
if isfield(binnedData,'forcelabels')
    trainData.forcelabels = binnedData.forcelabels;
    testData.forcelabels  = binnedData.forcelabels;
end
%% Pos
if isfield(binnedData,'cursorposbin')
    if ~isempty(binnedData.cursorposbin)
        trainData.cursorposbin = binnedData.cursorposbin(trainBins,:);
        testData.cursorposbin  = binnedData.cursorposbin(testBins,:);
    end
end
if isfield(binnedData,'cursorposlabels')
    trainData.cursorposlabels = binnedData.cursorposlabels;
    testData.cursorposlabels  = binnedData.cursorposlabels;
end
%% Vel
if isfield(binnedData,'velocbin')
    if ~isempty(binnedData.velocbin)
        trainData.velocbin = binnedData.velocbin(trainBins,:);
        testData.velocbin  = binnedData.velocbin(testBins,:);
    end
end
if isfield(binnedData,'veloclabels')
    trainData.veloclabels = binnedData.veloclabels;
    testData.veloclabels  = binnedData.veloclabels;
end
%% Acceleration
if isfield(binnedData,'accelbin')
    if ~isempty(binnedData.accelbin)
        trainData.accelbin = binnedData.accelbin(trainBins,:);
        testData.accelbin  = binnedData.accelbin(testBins,:);
    end
end
if isfield(binnedData,'acclabels')
    trainData.acclabels = binnedData.acclabels;
    testData.acclabels  = binnedData.acclabels;
end
%% Target Angle
if isfield(binnedData,'targetanglebin')
    if ~isempty(binnedData.targetanglebin)
        trainData.targetanglebin = binnedData.targetanglebin(trainBins,:);
        testData.targetanglebin  = binnedData.targetanglebin(testBins,:);
    end
end
if isfield(binnedData,'targetanglelabels')
    trainData.targetanglelabels = binnedData.targetanglelabels;
    testData.targetanglelabels  = binnedData.targetanglelabels;
end


%% States



%% Trialtable
if isfield(binnedData,'trialtable')
    if ~isempty(binnedData.trialtable)
        trainData.trialtable = binnedData.trialtable(binnedData.trialtable(:,1)<testStartTime ...
                                                  | binnedData.trialtable(:,1)>testEndTime,:);
        testData.trialtable  = binnedData.trialtable(binnedData.trialtable(:,1)>=testStartTime ...
                                                  & binnedData.trialtable(:,1)<=testEndTime,:);
    end
end
if isfield(binnedData,'trialtablelabels')
    trainData.trialtablelabels = binnedData.trialtablelabels;
    testData.trialtablelabels  = binnedData.trialtablelabels;
end

%% Words
if isfield(binnedData,'words')
    if ~isempty(binnedData.words)
        trainData.words = binnedData.words(binnedData.words(:,1)<testStartTime ...
                                                  | binnedData.words(:,1)>testEndTime,:);
        testData.words  = binnedData.words(binnedData.words(:,1)>=testStartTime ...
                                                  & binnedData.words(:,1)<=testEndTime,:);
    end
end

%% Targets
if isfield(binnedData,'targets')
%     if ~isempty(binnedData.targets)
%        trainData.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)<testStartTime ...
%                                                            | binnedData.targets.corners(:,1)>testEndTime,:);   
%        testData.targets.corners  = binnedData.targets.corners(binnedData.targets.corners(:,1)>=testStartTime ...
%                                                            & binnedData.targets.corners(:,1)<=testEndTime,:);
%        trainData.targets.rotation = binnedData.targets.rotation(binnedData.targets.rotation(:,1)<testStartTime ...
%                                                            | binnedData.targets.rotation(:,1)>testEndTime,:);   
%        testData.targets.rotation  = binnedData.targets.rotation(binnedData.targets.rotation(:,1)>=testStartTime ...
%                                                            & binnedData.targets.rotation(:,1)<=testEndTime,:);
%     end
end

%% Stim
end