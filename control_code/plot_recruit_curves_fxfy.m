function plot_recruit_curves_fxfy(data_struct,magF,stdF,pulseamp,pulsewidth,vecGood,color,name_data)

emg_labels = data_struct.emg_labels(data_struct.is_channel_modulated>0);
if strcmp(data_struct.mode,'mod_amp')
    for jj = 1:length(vecGood)
        indK = vecGood(jj);
        figure(indK+10); hold on;
        plot(pulseamp(:,jj),magF(:,jj),'.','Color',color);
        legend(name_data);
        if ~isempty(stdF)
            errorbar(pulseamp(:,jj),magF(:,jj),stdF(:,jj),'Color',color,'LineStyle','none','Marker','.');
        end
        title(strcat('Recruitment curve, ',emg_labels(indK),', PW=',num2str(pulsewidth(1,jj)),'msec, f=',num2str(data_struct.freq),'Hz, red=raw data, blk = fit'))
        xlabel('pulse amplitdue (mA)')
        ylabel('Force (N)')
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