function TaskEMG_Movement(binnedData,emg1,emg2,emg3,emg4, save,foldername, filename)
% TaskEMG_Movement(WmBinned,'FCU', 'FCR', 'ECU', 'ECR');
% TaskEMG_Movement(WmBinned,'FDS', 'FDP', 'EDC', 'ECR');

% This function makes a figure that shows the difference in EMG for the
% isometric task. It produces a subplot(2,1). The top plot has EMGs
% for the task. The bottom task has a force or position trace.

% Set save default to 0
if nargin <= 5
    save=0;
end

% Find the EMGs you are interested in plotting
EMGind1 = strmatch(emg1,(binnedData.emgguide)); EMGind1 = EMGind1(1);
EMGind2 = strmatch(emg2,(binnedData.emgguide)); EMGind2 = EMGind2(1);
EMGind3 = strmatch(emg3,(binnedData.emgguide)); EMGind3 = EMGind3(1);
EMGind4 = strmatch(emg4,(binnedData.emgguide)); EMGind4 = EMGind4(1);
emg_vector = [EMGind1 EMGind2 EMGind3 EMGind4];

% Mean removal so that EMGs dont have a huge offset
%EMGmeans = mean(binnedData.emgdatabin);
%binnedData.emgdatabin = binnedData.emgdatabin-repmat(EMGmeans,length(binnedData.emgdatabin(:,1)),1);

% Find your relevant task metrics
startInd = 1; endInd = 7500;
timeStart = binnedData.timeframe(startInd);
timeEnd = binnedData.timeframe(endInd);
excessTrialtable = find(binnedData.trialtable(:,8)>timeEnd);
trialtable = binnedData.trialtable;
trialtable(excessTrialtable,:)=[];





figure;
ax1 = subplot(2,1,1); hold on; %Make top subplot for the EMG data
title(strcat(['Movement ',binnedData.meta.datetime(1:9)]));
for i = 1:length(emg_vector)
    colors = ['b' 'c' 'r' 'm'];
    plot(binnedData.timeframe(startInd:endInd),binnedData.emgdatabin(startInd:endInd,emg_vector(i)),colors(i),'LineWidth',2)
end
ylim([0 2]); set(gca,'xticklabel',[]); %set(gca,'yticklabel',[]);
legend(emg1, emg2, emg3, emg4)
MillerFigure;
ax2 = subplot(2,1,2); hold on;
for j = 1:length(trialtable(:,1))
    w = .5;
    h = abs(trialtable(j,2) - trialtable(j,4));
    y = trialtable(j,4)-h;
    rectangle('Position',[trialtable(j,8)-.5,y,w,h],'EdgeColor',[1 .1 .1],'FaceColor',[1 .5 .5])
end
plot(binnedData.timeframe(startInd:endInd),binnedData.cursorposbin(startInd:endInd,1),'k','LineWidth',1.2)
MillerFigure;
set(gca,'yticklabel',[])
linkaxes([ax1,ax2],'x')
xlim([timeStart timeEnd])
xlabel('Time (seconds)')

if save == 1
    SaveFigure(foldername, filename)
end
    
