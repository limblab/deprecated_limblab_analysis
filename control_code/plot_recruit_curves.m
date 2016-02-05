function plot_recruit_curves(data_struct,magF,stdF,dirF,stdDir,pulseamp,pulsewidth,vecGood,color)

emg_labels = data_struct.emg_labels(data_struct.is_channel_modulated>0);
if strcmp(data_struct.mode,'mod_amp')
    for jj = 1:length(vecGood)
        indK = vecGood(jj);
        figure(indK+10); clf; subplot(2,1,1); hold on;
        plot(pulseamp(:,indK),magF(:,indK),'.','Color',color);
        if ~isempty(stdF)
            errorbar(pulseamp(:,indK),magF(:,indK),stdF(:,indK),'Color',color,'LineStyle','none','Marker','.');
        end
        title(strcat('Recruitment curve, ',emg_labels(indK),', PW=',num2str(pulsewidth(1,indK)),'msec, f=',num2str(data_struct.freq),'Hz, red=raw data, blk = fit'))
        xlabel('pulse amplitdue (mA)')
        ylabel('Force (N)')
        subplot(2,1,2); hold on;
        plot(pulseamp(:,indK),180/pi*dirF(:,indK),'.','Color',color);
        if ~isempty(stdDir)
            errorbar(pulseamp(:,indK),180/pi*dirF(:,indK),180/pi*stdDir(:,indK),'Color',color,'LineStyle','none','Marker','.');
        end
        title(strcat('Recruitment curve, ',emg_labels(indK),', PW=',num2str(pulsewidth(1,indK)),'msec, f=',num2str(data_struct.freq),'Hz, red=raw data, blk = fit'))
        xlabel('pulse amplitdue (mA)')
        ylabel('Direction (deg)')
    end 
else
    for jj = 1:size(magF,2)
        figure(jj+10); hold on;
        plot(pulsewidth(:,jj),magF(:,jj),'o','Color',color);
        title(strcat('Recruitment curve, ',emg_labels(vecGood(jj)),', PW=',num2str(pulseamp(1,jj)),'msec, f=',num2str(data_struct.freq),'Hz, red=raw data, blk = fit'))
        xlabel('pulse width (msec)')
        ylabel('Force (N)')
    end
    
end