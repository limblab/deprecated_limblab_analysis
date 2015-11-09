function [badChanF,rangeThresh,signalRangeBadLogical,signalRangeLowLogical,fpCutFig,fpCutTimes,fpCut,maxStrLen,fptimes]=fpFromBCI2000(signal,FPIND,samprate,parameters)

signalRange=max(signal(:,FPIND),[],1)-min(signal(:,FPIND),[],1);
signalRangeLowLogical=signalRange<(median(signalRange)-2*iqr(signalRange));
signalRangeLowLogical=signalRangeLowLogical | (signalRange==0);
badChanF=findobj(0,'Tag','badChanF');
if ~isempty(badChanF)
    if ~isequal(get(badChanF,'WindowStyle'),'docked')
        figureCenter(badChanF)
    end
    rangeThresh=median(get(findobj(badChanF,'LineStyle','--'),'ydata'));
else
    badChanF=figureCenter; % set(badChanF,'Position',[121 468 560 420])
    plot(signalRange,'.','MarkerSize',36)
    % for median range calculation, include everything except the zeros.
    rangeThresh=median(signalRange(~signalRangeLowLogical))+ ...
        2*iqr(signalRange(~signalRangeLowLogical));    % for TMSi
    %   0.5*std(signalRange(~signalRangeLowLogical));   % for Blackrock (with 32 crap chans)
end
signalRangeHighLogical=signalRange > rangeThresh;
signalRangeBadLogical=signalRangeLowLogical | signalRangeHighLogical;
hold on
plot(find(signalRangeBadLogical),signalRange(signalRangeBadLogical),'r.','MarkerSize',36)
if isempty(findobj(badChanF,'LineStyle','--'))
    plot(get(gca,'Xlim'),[0 0]+rangeThresh,'k--','LineWidth',2)
end
try                                                                         %#ok<TRYNC>
    title(sprintf('%s\nRange of raw signals.\nBad channel estimate=red. %d good channels.', ...
        FileName,nnz(~signalRangeBadLogical)),'Interpreter','none','FontSize',16)
end
set(gca,'box','off','FontSize',16), set(gcf,'Color',[0 0 0]+1)
set(badChanF,'Tag','badChanF')
% also, plot a cut-down version of the raw fp signals.
%  first, scale the signals so that they will appear 
%  separated by a nice amount.
fptimes=(1:size(signal,1))/samprate;
% fpCut=(signal(1:100:end,FPIND)')./mean(signalRange); 
fpCut=bsxfun(@minus,signal(1:100:end,FPIND),mean(signal(1:100:end,FPIND)))'./mean(signalRange);
fpCutTimes=fptimes(1:100:end);
% so as to scale nicely for plotting
fpCutFig=figure; set(fpCutFig,'Units','normalized','OuterPosition',[0 0 1 1])
fpCutAx=axes('Position',[0.0365    0.0297    0.9510    0.9636], ...
    'XLim',[0 max(fpCutTimes)], ...
    'Ylim',[0 max(FPIND)-min(FPIND)+2],'YTick',sort(FPIND-min(FPIND)+1));
hold on
maxStrLen=max(cellfun(@numel,parameters.ChannelNames.Value(FPIND)));
for n=1:size(fpCut,1)
    if ~isempty(intersect(n,find(signalRangeBadLogical)))
        plot(fpCutTimes,n+fpCut(n,:),'r')
    else
        plot(fpCutTimes,n+fpCut(n,:))
    end
    YaxLabelStr{n}=sprintf(['%02d %',num2str(maxStrLen),'s'],...
        n,parameters.ChannelNames.Value{FPIND(n)});                         %#ok<AGROW>
end, clear n
set(fpCutAx,'YTickLabel',YaxLabelStr)
figure(badChanF)