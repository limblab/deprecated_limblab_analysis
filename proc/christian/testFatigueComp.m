binsize = 0.05;
timebefore = 0.5;
timeafter  = 0;

%reward ts for tgt 0
ts = binnedData.trialtable( binnedData.trialtable(:,6)== 0 &...
                            binnedData.trialtable(:,12) == double('R'), 11);

signals = [binnedData.timeframe binnedData.forcedatabin];
[meanFtgt0, stdFtgt0, N] = sigStatAroundTs(signals,ts,timebefore,timeafter,binsize);

%scale force from 0 to 200
for i = 1:size(meanFtgt0,2)
    meanFtgt0(:,i) = 200*meanFtgt0(:,i)/max(meanFtgt0(:,i));
end

signals = binnedData.stim(:,any(binnedData.stim));

[meanStgt0, stdStgt0, N] = sigStatAroundTs(signals,ts,timebefore,timeafter,binsize);

MmeanStgt0 = mean(meanStgt0,2);

figure;
plot(meanFtgt0(:,1),'k'); hold on;
plot(MmeanStgt0,'r');

valid_idx = [2 4 6:18];

meanFtgt0  = meanFtgt0(valid_idx);
MmeanStgt0 =MmeanStgt0(valid_idx); 