%script to plot the evolution of PD's 
folderpath='E:\processing\move_PD';
PD_history=get_pd_history(folderpath);

%%PD's in the 210 deg direction
%channels of interest:
channels=[35 44 66 87];

for i=1:length(channels)
    figure
    subplot(2,1,1), plot(PD_history.dates,PD_history.channel(channels(i)).PD*180/pi,'-x')
    subplot(2,1,1), datetick('x',1)
    subplot(2,1,1), title(strcat('PD history for channel: ',num2str(channels(i))))
    subplot(2,1,2), plot(PD_history.dates,PD_history.channel(channels(i)).moddepth,'-x')
    subplot(2,1,2), datetick('x',1)
    subplot(2,1,2), title(strcat('Modulation depth history for channel: ',num2str(channels(i))))
end

%%PD's in the 270 deg direction
channels=[3 70 43 49];

for i=1:length(channels)
    figure
    subplot(2,1,1), plot(PD_history.dates,PD_history.channel(channels(i)).PD*180/pi,'-x')
    subplot(2,1,1), datetick('x',1)
    subplot(2,1,1), title(strcat('PD history for channel: ',num2str(channels(i))))
    subplot(2,1,2), plot(PD_history.dates,PD_history.channel(channels(i)).moddepth,'-x')
    subplot(2,1,2), datetick('x',1)
    subplot(2,1,2), title(strcat('Modulation depth history for channel: ',num2str(channels(i))))
end

%%PD's in the 20 deg direction
channels=[46 48 50 51];

for i=1:length(channels)
    figure
    subplot(2,1,1), plot(PD_history.dates,PD_history.channel(channels(i)).PD*180/pi,'-x')
    subplot(2,1,1), datetick('x',1)
    subplot(2,1,1), title(strcat('PD history for channel: ',num2str(channels(i))))
    subplot(2,1,2), plot(PD_history.dates,PD_history.channel(channels(i)).moddepth,'-x')
    subplot(2,1,2), datetick('x',1)
    subplot(2,1,2), title(strcat('Modulation depth history for channel: ',num2str(channels(i))))
end


%%PD's in the 70 deg direction
channels=[2 33 67 74];

for i=1:length(channels)
    figure
    subplot(2,1,1), plot(PD_history.dates,PD_history.channel(channels(i)).PD*180/pi,'-x')
    subplot(2,1,1), datetick('x',1)
    subplot(2,1,1), title(strcat('PD history for channel: ',num2str(channels(i))))
    subplot(2,1,2), plot(PD_history.dates,PD_history.channel(channels(i)).moddepth,'-x')
    subplot(2,1,2), datetick('x',1)
    subplot(2,1,2), title(strcat('Modulation depth history for channel: ',num2str(channels(i))))
end