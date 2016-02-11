MSP_R2 =open(['L:\Mike_PD_Data\Mini PD figs\HC\Mini_HC_AllSpikeCounts_Non-normalized_NoShunts.fig']);
images=findobj(MSP_R2,'Type','Image');
ChewieMSPr2=get(images,'CData');
compositeFig=figure;
set(compositeFig,'Units','Inches','Position',[5 2.5 9.6 2.1])
MSP_R2axInCompFig=axes('Position',[0 0.05 0.4/1.7362 0.9]); 
set(imagesc(ChewieMSPr2),'Parent',MSP_R2axInCompFig), clear ChewieMSPr2
set(MSP_R2axInCompFig,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')
caxis([0 20])
clear images

LFP_R2=open(['L:\Mike_PD_Data\Mini PD figs\HC\Mini_HC_LFP1Direct_FinalDecoder_AllFreqLFPcounts_Non-normalized_NoShunts.fig']);
images=findobj(LFP_R2,'Type','Image');
ChewieLFPr2=get(images,'CData');
compositeFig=figure;
set(compositeFig,'Units','Inches','Position',[5 2.5 9.6 2.1])
LFP_R2axInCompFig=axes('Position',[0 0.05 (0.4*.8696)/1.3095 0.9]);
set(imagesc(ChewieLFPr2),'Parent',LFP_R2axInCompFig), clear ChewieLFPr2
set(LFP_R2axInCompFig,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')
caxis([-100 100])

meanR3fig=open(['L:\Mike_PD_Data\Mini PD figs\HC\Mini_HC_AllSpikeCounts_Non-normalized_CorrelationMap_Summary_LineFit_NoShunts.fig']);
meanR3MSP=get(findobj(meanR3fig,'Marker','o'),'xdata');
meanR3MSPmat = meanR3MSP{2,1}';
meanR3MSPmat(:,1) = meanR3MSPmat(:,1) - meanR3MSPmat(1,1);
meanR3MSP=[meanR3MSP; get(findobj(meanR3fig,'Marker','o'),'ydata')];
meanR3MSPmat = [meanR3MSPmat meanR3MSP{4,1}'];
figure(compositeFig)
meanR3axInCompFig=axes('Position',[0.6 0.05 (0.4*.8696)/1.3095 0.9]); 
% Chewie LFP 1 is scaled to 0.4/1.15 (Divding by 1.15 = Multiplying by 0.8696), everything else is in relation to
% this ratio.  Mini's HC is 798 days, Chewies HC, 1045.  The ratio between
% these two (1045/798 = 1.3095), thus dividing by this finally gives you
% the appropriate ratio.  I wish I had written this the first time around.
set(plot(meanR3MSPmat(:,1),meanR3MSPmat(:,2),'mo'), ...
    'Parent',meanR3axInCompFig,'MarkerSize',12)
set(meanR3axInCompFig,'Xlim',[0 max(meanR3MSPmat(:,1))],'Ylim',[0 1],'TickLength',[0 0], ...
    'XTick',[],'YTick',[],'box','off')

set(meanR3axInCompFig,'NextPlot','Add')
meanR3fig=open(['L:\Mike_PD_Data\Mini PD figs\HC\Mini_HC_LFP1Direct_FinalDecoder_AllFreqLFPcounts_Non-normalized_CorrelationMap_Summary_LineFit_NoShunts.fig']);
meanR3LFP=get(findobj(meanR3fig,'Marker','o'),'xdata');
meanR3LFPmat = meanR3LFP';
meanR3LFPmat(:,1) = meanR3LFPmat(:,1) - meanR3LFPmat(1,1);
meanR3LFP=[meanR3LFP; get(findobj(meanR3fig,'Marker','o'),'ydata')];
meanR3LFPmat = [meanR3LFPmat meanR3LFP'];

set(plot(meanR3LFPmat(:,1),meanR3LFPmat(:,3),'go','MarkerSize',12), ...
    'Parent',meanR3axInCompFig)
set(meanR3axInCompFig,'Xlim',[0 max(meanR3LFPmat(:,1))],'Ylim',[0 1],'TickLength',[0 0], ...
    'XTick',[],'YTick',[],'box','off')

LFPmean = mean(meanR3LFPmat(:,3))
LFPstd = std(meanR3LFPmat(:,3))

[h p] = ttest2(meanR3LFPmat(:,3),meanR3MSPmat(:,2))