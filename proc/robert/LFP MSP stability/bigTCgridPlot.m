function bigTCgridPlot(TCin)


fig=figure; 
set(fig,'Position',[-1920 -138 1920 1000])
                                        % [1 1 1430 800]
                                        % [-1920 -138 1920 1000] Caligula at work
                                        % [0 50 1000 650] bumbleBeeMan remote access
                                        % [1 1 1900 980] Caligula at home
                                        % [-75 1080 1600 1130] Lurie 8 conf. room
                                        
axH=gridPlotSetup(fig,size(TCin,2),[size(TCin,2) 1]);

for n=1:size(TCin,2)
    set(fig,'CurrentAxes',axH(n))
    imagesc(squeeze(TCin(:,n,:)))
    text(0.1*max(get(gca,'Xlim')),median(get(gca,'Ylim')), ...
        num2str(n),'HorizontalAlignment','Left', ...
        'VerticalAlignment','middle')
    text(0.25*max(get(gca,'Xlim')),median(get(gca,'Ylim')), ...
        num2str(n),'HorizontalAlignment','Left', ...
        'VerticalAlignment','middle')
    text(0.5*max(get(gca,'Xlim')),median(get(gca,'Ylim')), ...
        num2str(n),'HorizontalAlignment','Left', ...
        'VerticalAlignment','middle')
    text(0.75*max(get(gca,'Xlim')),median(get(gca,'Ylim')), ...
        num2str(n),'HorizontalAlignment','Left', ...
        'VerticalAlignment','middle')  
    text(max(get(gca,'Xlim')),median(get(gca,'Ylim')), ...
        num2str(n),'HorizontalAlignment','Right', ...
        'VerticalAlignment','middle')    
    set(gca,'TickLength',[0 0])
end, clear n 

