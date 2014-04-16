
getrid =  find(binnedData.trialtable(:,7) == -1);
binnedData.trialtable(getrid,:)=[];

x = binnedData.timeframe; %time in seconds

figure    
plot1 = subplot(2,1,1);
% Plot a shaded area from Go Cue to End of Trial
for i=1:length(binnedData.trialtable)
    Go_ts = binnedData.trialtable(i,7);
    TgtNo = num2str(binnedData.trialtable(i,10));
    TrialEnd_ts = binnedData.trialtable(i,8);
    start(i)= find(abs(binnedData.timeframe-Go_ts) <= 0.05,1,'first'); %to convert to sec
    stop(i) = find(abs(binnedData.timeframe-TrialEnd_ts) <= 0.05,1,'first'); %to convert to sec
    patch([start(i)*.05 stop(i)*.05 stop(i)*.05 start(i)*.05],[0.4 0.4 40 40],'k','FaceAlpha',0.1,'EdgeAlpha',0);
    %text(((start(i)*.05)+(stop(i)*.05))/2, 10,TgtNo,'FontSize',20);
    hold on
    
%     for a=1:6
%         EMGheft(i,a) = mean(binnedData.emgdatabin((floor(start(i)/.05)):floor((stop(i)/.05)),a));
%     end
    
end
hold on
%Plot the EMG activity for each channel

y1=binnedData.emgdatabin(:,1);
h1 = plot(x,y1,'Color','r','LineWidth',1.5);
ylim([0 40])


y2=binnedData.emgdatabin(:,2);
h2=plot(x,y2,'Color','m','LineWidth',1.5);
ylim([0 40])

y3=binnedData.emgdatabin(:,3);
h3 = plot(x,y3,'Color','y','LineWidth',1.5);
ylim([0 40])

y4=binnedData.emgdatabin(:,4);
h4 = plot(x,y4,'Color','b','LineWidth',1.5);
ylim([0 40])

y5=binnedData.emgdatabin(:,5);
h5 = plot(x,y5,'Color','c','LineWidth',1.5);
ylim([0 40])

y6=binnedData.emgdatabin(:,6);
h6 = plot(x,y6,'Color','g','LineWidth',1.5);
ylim([0 40])

legend([h1 h2 h3 h4 h5 h6], binnedData.emgguide);

xlabel('Seconds')
hold off

%EMGheft(:,7) = (binnedData.trialtable(:,10));

%Plot x position under the EMGs
plot2 = subplot(2,1,2);
y7=binnedData.cursorposbin(:,1);
h7 = plot(x,y7,'Color','k','LineWidth',1.5);
linkaxes([plot1 plot2], 'x');
xlabel('Seconds')
box off
%set(gca,'XTickLabel','','YTickLabel','')

%title('Jango | Iso-Horizontal | EMGtraces | 10/11/13')
%print -dpdf Jango_IsoHoriz_UtahFMAsEMGs_101113_001.pdf