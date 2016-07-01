%Plot mean EMG versus mean force

getrid =  find(binnedData.trialtable(:,7) == -1);
binnedData.trialtable(getrid,:)=[];

figure
for i=1:length(binnedData.trialtable)
    Go_ts = binnedData.trialtable(i,7);
    TgtNo = num2str(binnedData.trialtable(i,10));
    TrialEnd_ts = binnedData.trialtable(i,8);
    start(i)= find(abs(binnedData.timeframe-Go_ts) <= 0.05,1,'first');
    stop(i) = find(abs(binnedData.timeframe-TrialEnd_ts) <= 0.05,1,'first');
end

for a = 1:6
for b = 1:length(start)
EMGmeansPerTrial(b,a) = mean(binnedData.emgdatabin(start(b):stop(b),a));
XPositionmeansPerTrial(b,1) = mean(binnedData.cursorposbin(start(b):stop(b),1));
end
end
% 
% subplot(1,3,3)
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,1),'xr','LineWidth',6)
% hold on
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,2),'xm','LineWidth',6)
% hold on
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,3),'xy','LineWidth',6)
% hold on
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,5),'xb','LineWidth',6)
% hold on
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,5),'xc','LineWidth',6)
% hold on
% plot(XPositionmeansPerTrial,EMGmeansPerTrial(:,6),'xg','LineWidth',6)


%Normalized

maxVals = max(EMGmeansPerTrial);
maxValsExpanded = repmat(maxVals,length(EMGmeansPerTrial),1);
EMGmeansPerTrialNorm = EMGmeansPerTrial./maxValsExpanded;


subplot(1,3,2)
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,1),'xr','LineWidth',6)
hold on
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,2),'xm','LineWidth',6)
hold on
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,3),'xy','LineWidth',6)
hold on
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,5),'xb','LineWidth',6)
hold on
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,5),'xc','LineWidth',6)
hold on
plot(XPositionmeansPerTrial,EMGmeansPerTrialNorm(:,6),'xg','LineWidth',6)
