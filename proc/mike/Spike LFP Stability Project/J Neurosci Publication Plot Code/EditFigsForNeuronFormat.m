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

%% Chewie 
xlim([140 350])
Xticks = [100:50:350]

set(gca,'XTick',Xticks,'XTickLabel',Xticks)

ah = findobj(gca,'TickDirMode','auto')
set(ah,'Box','off')
set(ah,'TickLength',[0,0])

figure(13)
CYData{3,1} = 'Chewie Data';
h = findobj(gca,'Marker','o') % 'Color',[0 1 0]
CXData{1,1} = get(h,'XData')
CXData{2,1} = 'LMP LFP BC';
clear h

h = findobj(gca,'Color',[1 0 1],'Marker','o') %'Color',[1 0 1]
CYData{1,2} = get(h,'YData')
CYData{2,2} = 'LMP Sp BC';


h = findobj(gca,'Color',[0 1 0],'Marker','o') %'Color',[1 0 1]
CYData{1,1} = get(h,'YData')

% figure(22)
% % h = findobj(gca,'Marker','o') % 'Color',[0 1 0]
% % CYData{1,3} = get(h,'YData')
% % CYData{2,3} = 'Mu LFP BC';
% % clear h
% 
% h = findobj(gca,'Marker','o') %'Color',[1 0 1]
% CYData{1,4} = get(h,'YData')
% CYData{2,4} = 'Mu Sp BC';

figure(5)
% h = findobj(gca,'Marker','o')
% CYData{1,5} = get(h,'YData')
% CYData{2,5} = 'Gam1 LFP BC';
% clear h

h = findobj(gca,'Marker','o','Color',[1 0 1])
CYData{1,6} = get(gco,'YData')
CYData{2,6} = 'Gam1 Sp BC';

figure(9)
% h = findobj(gca,'Marker','o')
% CYData{1,7} = get(h,'YData')
% CYData{2,7} = 'Gam2 LFP BC';
% clear h

h = findobj(gca,'Marker','o','Color',[1 0 1])
CYData{1,8} = get(h,'YData')
CYData{2,8} = 'Gam2 Sp BC';

figure(11)
% h = findobj(gca,'Marker','o')
% CYData{1,9} = get(h,'YData')
% CYData{2,9} = 'Gam3 LFP BC';
% clear h

h = findobj(gca,'Marker','o','Color',[1 0 1])
CYData{1,10} = get(h,'YData')
CYData{2,10} = 'Gam3 Sp BC';

Means = cellfun(@nanmean,CYData(1,1:10));

STEs = cellfun(@nanstd,CYData(1,1:10))./sqrt(cellfun(@length,CYData(1,1:10)));

figure;
errorbar(Means(1,[1 5 7 9]),STEs(1,[1 5 7 9]),'go')
hold on
errorbar(Means(1,[2 6 8 10]),STEs(1,[2 6 8 10]),'mo')

ylim([0 1])
set(gca,'Xtick',[1,2,3,4],'XTicklabel',{'LMP','70-110','130-200','200-300'})
legend('All LFP (direct + indirect) features during LFP BC','All LFP (direct + indirect) Features During Spike BC')
ylabel('SI')

%% Mini
xlim([150 350])
Xticks = [150:50:350]
set(gca,'XTick',Xticks,'XTickLabel',Xticks)

ah = findobj(gca,'TickDirMode','auto')
set(ah,'Box','off')
set(ah,'TickLength',[0,0])

figure(23)
YData{3,1} = 'Mini Data';
h = findobj(gca,'Marker','o') %'Color',[0 1 0]
YData{1,1} = get(h,'YData')
YData{2,1} = 'LMP LFP BC';
clear h

% h = findobj(gca,'Color',[1 0 1],'Marker','o') % 
% YData{1,2} = get(h,'YData')
% YData{2,2} = 'LMP Sp BC';

figure(29)
h = findobj(gca,'Marker','o')
YData{1,3} = get(h,'YData')
YData{2,3} = 'Gam2 LFP BC';
clear h
% 
% h = findobj(gca,'Color',[1 0 1],'Marker','o')
% YData{1,4} = get(h,'YData')
% YData{2,4} = 'Gam2 Sp BC';

figure(31)
h = findobj(gca,'Marker','o') 
YData{1,5} = get(h,'YData')
YData{2,5} = 'Gam3 LFP BC';
clear h
% 
% h = findobj(gca,'Color',[1 0 1],'Marker','o')
% YData{1,6} = get(h,'YData')
% YData{2,6} = 'Gam3 Sp BC';

Means = cellfun(@nanmean,YData(1,1:6));

STEs = cellfun(@nanstd,YData(1,1:6))./sqrt(cellfun(@length,YData(1,1:6)));

figure;
errorbar(Means(1,[1 3 5]),STEs(1,[1 3 5]),'go')
hold on
errorbar(Means(1,[2 4 6]),STEs(1,[2 4 6]),'mo')

ylim([0 1])
set(gca,'Xtick',[1,2,3],'XTicklabel',{'LMP','Gam2','Gam3'})
legend('All LFP (direct + indirect) features during LFP BC',['All LFP'...
    ' (direct + indirect) features during Spike BC'])
ylabel('SI') 
