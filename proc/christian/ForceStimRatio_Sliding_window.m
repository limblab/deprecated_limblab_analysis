load('D:\Monkey\Jaco\Data\BinnedData\04-19-11\Jaco_04-19-11_005_Fcorr.mat');

% tt = binnedData.trialtable(binnedData.trialtable(:,1)>60,:);
tt = binnedData.trialtable;
target = 0;
stimForceOffset = 4; %number of bins
slidingWindowLength = 60;

AllRewards = find(tt(:,12)==double('R'));
t0Rewards  = find(tt(:,12)==double('R') & tt(:,6)==target);
AllTrials  = 1:size(tt,1);

ValidTrials = t0Rewards;

S = sum([binnedData.stim(:,3) binnedData.stim(:,5)],2);
% S = [binnedData.stim(:,3) binnedData.stim(:,5)]);

S = interp1(binnedData.stim(:,1),S,binnedData.timeframe);

ConcatForce = [];
ConcatStim  = [];

for i = 1:length(ValidTrials)

    startt = tt(ValidTrials(i),3);
    endt = tt(ValidTrials(i),11);
    idxTimeRange = find(binnedData.timeframe > startt & binnedData.timeframe <= endt);
       % Use only data ts when there is some force
    idxTimeRange = idxTimeRange(binnedData.forcedatabin(idxTimeRange)>0);
       % Skip data early in file if < stimForceOffset
    idxTimeRange = idxTimeRange(idxTimeRange >=stimForceOffset); 
    if isempty(idxTimeRange)
        disp(sprintf('Could not find force signal in specific time range for trial #%g',i));
        continue;
    end
    
    ConcatForce  = [ConcatForce; binnedData.forcedatabin(idxTimeRange)];
    
    ConcatStim   = [ConcatStim; S(idxTimeRange-stimForceOffset)];
        
end

%scale force 0-400
ConcatForce = ConcatForce * 400 /max(ConcatForce);

figure;plot(ConcatForce,'k');hold on;plot(ConcatStim,'r');

%% smooth force and stim
aveForce = zeros(length(ConcatForce)-slidingWindowLength+1,1);
aveStim  = zeros(length(ConcatStim) -slidingWindowLength+1,1);

for i = 1:length(aveForce)
    aveForce(i) = mean(ConcatForce(i:i+slidingWindowLength-1));
    aveStim(i)  = mean(ConcatStim (i:i+slidingWindowLength-1));
end

% figure;plot(aveStim,'r');hold on;plot(aveForce,'k');
Force2StimRatio = aveForce./aveStim;

%% Smooth Ratio

% figure;plot(Force2StimRatio);title('Force 2 Stim Ratio');

%smooth ratio
aveRatio = zeros(length(Force2StimRatio)-slidingWindowLength+1,1);
for i = 1:length(aveRatio)
    aveRatio(i) = mean(Force2StimRatio(i:i+slidingWindowLength-1));
end

figure; plot(aveRatio,'r');title('Smoothed Force 2 Stim Ratio');