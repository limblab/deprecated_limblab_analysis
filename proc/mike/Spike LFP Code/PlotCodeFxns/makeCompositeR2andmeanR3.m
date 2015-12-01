%% 
clear
compFigR2andR3=open(['L:\Mike_PD_Data\Mini PD Figs\HC\Mini_HC_AllSpikeCounts_Non-normalized_NoShunts.fig']);
images=findobj(compFigR2andR3,'Type','Image');
imageSize=numel(get(images,'CData'));
ChewieLFPr2=get(images,'CData');
% ChewieLFPr2axPos=get(get(images(imageSize==11800),'Parent'),'OuterPosition');
% ChewieLFPr3=get(images(imageSize==13924),'CData');
% ChewieLFPr3axPos=get(get(images(imageSize==13924),'Parent'),'OuterPosition');
ChewieMSPr2=get(images,'CData');
% ChewieMSPr3=get(images(imageSize==12321),'CData');
close(compFigR2andR3), clear compFigR2andR3
%%
compositeFig=figure;
set(compositeFig,'Units','Inches','Position',[5 2.5 9.6 2.1])
LFP_R2axInCompFig=axes('Position',[0 0.05 0.4 0.9]);
set(imagesc(ChewieLFPr2),'Parent',LFP_R2axInCompFig), clear ChewieLFPr2
set(LFP_R2axInCompFig,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')
LFP_R3axInCompFig=axes('Position',[0.4 0.05 0.2 0.9]);
set(imagesc(ChewieLFPr3),'Parent',LFP_R3axInCompFig), clear ChewieLFPr3
set(gca,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')
caxis([0 1])
%% this is  currently not being used but the sizes, etc should be correct
% divide width so that span is proportional compared to LFP length of days
MSP_R2axInCompFig=axes('Position',[0 0.05 0.4/1.65 0.9]); 
set(imagesc(ChewieMSPr2),'Parent',MSP_R2axInCompFig), clear ChewieMSPr2
set(MSP_R2axInCompFig,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')

MSP_R3axInCompFig=axes('Position',[0.4 0.05 0.2 0.9]);
set(imagesc(ChewieMSPr3),'Parent',MSP_R3axInCompFig), clear ChewieMSPr3
set(MSP_R3axInCompFig,'TickLength',[0 0],'XTick',[],'YTick',[],'box','off')
caxis([0 1])
%%
meanR3fig=open(['L:\Mike_PD_Data\Mini PD Figs\HC\Chewie_HC_LFP1Direct_FinalDecoder_AllFreqLFPCounts_Non-normalized_NoShunts_CorrelationMap_Summary_LineFit.fig']);
meanR3LFP=get(findobj(meanR3fig,'Color','g','Marker','o'),'xdata');
meanR3LFP=[meanR3LFP; get(findobj(meanR3fig,'Color','g','Marker','o'),'ydata')];
meanR3MSP=get(findobj(meanR3fig,'Marker','o'),'xdata');
meanR3MSPmat = meanR3MSP{2,1}';
meanR3MSPmat(:,1) = meanR3MSPmat(:,1) - meanR3MSPmat(1,1);
meanR3MSP=[meanR3MSP; get(findobj(meanR3fig,'Marker','o'),'ydata')];
meanR3MSPmat = [meanR3MSPmat meanR3MSP{4,1}'];
mSize=get(findobj(meanR3fig,'Color','g','Marker','o'),'MarkerSize');
axLim=get(findobj(meanR3fig,'Type','Axes'),'Xlim');
close(meanR3fig), clear meanR3fig
figure(compositeFig)
meanR3axInCompFig=axes('Position',[0.6 0.05 0.4 0.9]);
set(plot(meanR3LFP(1,:),meanR3LFP(2,:),'go','MarkerSize',mSize), ...
    'Parent',meanR3axInCompFig)
set(meanR3axInCompFig,'NextPlot','Add')
set(plot(meanR3MSPmat(1,:),meanR3MSPmat(2,:),'o'), ...
    'Parent',meanR3axInCompFig)
set(meanR3axInCompFig,'Xlim',axLim,'Ylim',[0 1],'TickLength',[0 0], ...
    'XTick',[],'YTick',[],'box','off')