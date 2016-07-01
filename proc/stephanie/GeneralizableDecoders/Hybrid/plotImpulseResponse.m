


function plotImpulseResponse(IsoBinnedImpulsePred, WmBinnedImpulsePred,IsoBinned,emgInd)
figure
plot(IsoBinnedImpulsePred.preddatabin(1:30,emgInd),'k')
hold on
plot(WmBinnedImpulsePred.preddatabin(1:30,emgInd),'r')
title(IsoBinned.emgguide(emgInd,:))
xlabel('Lag (ms)')
set(gca,'XLim',[9 22],'XTick',[10:21], 'XTickLabel', [-50 0 50 150 200 250 300 350 400 450 500 550])
set(gca,'YTickLabel',[],'YTick',0,'YTickLabel',0)
legend('Isometric','Movement')
MillerFigure
end
