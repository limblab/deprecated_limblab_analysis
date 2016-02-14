PL = 1;
TTT = 0;
numpts = 11;
Xtick = [1 6 11];
XTicklabel = [10 60 110];
set(gca,'Xtick',Xtick,'XTicklabel',{XTicklabel})
xlabel('Minutes of Exposure to ONF (10 min segments)','FontSize',18)
xlim([1 11])

ah = findobj(gca,'TickDirMode','auto')
set(ah,'Box','off')
%  plot([4 4],[0 100],'k--')
h = findobj(gca,'MarkerSize',6.0)
set(h,'LineWidth',2.0)
set(gca,'Fontsize',20)

if TTT == 1
    avgAllTTT = repmat(mean(meanAllTTT_MAT),1,numpts);
    avgSTDAllTTT = repmat(std(meanAllTTT_MAT),1,numpts);
    ylim([0 25])
    ytick = [0 12.5 25];
    yticklabel = [0 12.5 25]; 
    set(gca,'Ytick',ytick,'YTicklabel',{yticklabel})
    ylabel('TTT (mean +/- STE)','FontSize',18)
    hold on
    shadedErrorBar([1:numpts],avgAllTTT,avgSTDAllTTT,'r')
    h = findobj(gco,'Color','r')
    set(h,'LineStyle','--')
    f = findobj(gco,'FaceAlpha',1.0)
    set(f(1),'FaceAlpha',.5)
    set(gcf,'Renderer','openGL')
end

if PL == 1;
    avgAllPL = repmat(mean(meanAllPL_MAT),1,numpts);
    avgSTDAllPL = repmat(std(meanAllPL_MAT),1,numpts);
    ylim([0 40])
    ytick = [0 20 40];
    yticklabel = [0 20 40];
    set(gca,'Ytick',ytick,'YTicklabel',{yticklabel})
    ylabel('Path Length (mean +/- STE)','FontSize',18)
    hold on
    shadedErrorBar([1:numpts],avgAllPL,avgSTDAllPL,'r')
    ylim([0 40])
    h = findobj(gco,'Color','r')
    set(h,'LineStyle','--')
    f = findobj(gco,'FaceAlpha',1.0)
    set(f(1),'FaceAlpha',0.5)
    set(gcf,'Renderer','openGL')

end

