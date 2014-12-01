h = findobj(gca,'marker','o')

x = get(h,'xdata')

Xticks = floor(min(x)/10)*10:ceil(floor(range(x)/2)/10)*10:ceil(max(x)/10)*10
xlim([floor(min(x)/10)*10,ceil(max(x)/10)*10])

set(gca,'XTick',Xticks,'XTickLabel',Xticks)

Yticks = [0 .5 1]

set(gca,'YTick',Yticks,'YTickLabel',Yticks)

ah = findobj(gca,'TickDirMode','auto')

set(ah,'Box','off')
set(ah,'TickLength',[0,0])

fh = gcf

set(fh,'Color','w')


set(fh,'Units','centimeters')


set(fh,'Position',[0,0,4.25,2.125])
