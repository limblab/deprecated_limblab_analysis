load('D:\Data\Tiki_4C1\FMAs\Processed\Tiki_2011-06-23_BC_001')

stim_codes = 1:6;
currents = [0 10 20 25 30 35];
%%
figure
for stim_id = 1:6
    trial_num = find(trial_table(:,table_columns.stim_id)==stim_id);
    trial_num = trial_num(1);
    time_limits = [trial_table(trial_num,table_columns.bump_time)-1 trial_table(trial_num,table_columns.bump_time)+5];
    continuous_signal_stim = double(bdf.raw.analog.data{12});
    continuous_signal_no_stim = double(bdf.raw.analog.data{53});

    spikes_stim = bdf.units(14).ts;
    spikes_stim = spikes_stim(spikes_stim>=time_limits(1) & spikes_stim<=time_limits(2));
    spikes_no_stim = bdf.units(56).ts;
    spikes_no_stim = spikes_no_stim(spikes_no_stim>=time_limits(1) & spikes_no_stim<=time_limits(2));

    fs = bdf.raw.analog.adfreq(12);
    t = bdf.vel(:,1);

    continuous_signal_stim = continuous_signal_stim(bdf.vel(1,1)*fs:end-(bdf.meta.duration-bdf.vel(end,1))*fs);
    continuous_signal_stim = continuous_signal_stim(t>=time_limits(1) & t<=time_limits(2));
    continuous_signal_no_stim = continuous_signal_no_stim(bdf.vel(1,1)*fs:end-(bdf.meta.duration-bdf.vel(end,1))*fs);
    continuous_signal_no_stim = continuous_signal_no_stim(t>=time_limits(1) & t<=time_limits(2));
    t = t(t>=time_limits(1) & t<=time_limits(2));
    spikes_stim = spikes_stim-time_limits(1)-1;
    spikes_no_stim = spikes_no_stim-time_limits(1)-1;
    t = t-time_limits(1)-1;

%     figure;
    subplot(2,6,stim_id)
    hold on
    plot(0,0,'-b')
    area([0 0 .5 .5 0],...
        [1.5*min(continuous_signal_stim) 1.5*max(continuous_signal_stim) 1.5*max(continuous_signal_stim) 1.5*min(continuous_signal_stim) 1.5*min(continuous_signal_stim)],...
        'FaceColor',[0.7 0.7 1],'LineStyle','none')
    plot(t,continuous_signal_stim,'b')
    plot([spikes_stim spikes_stim]',repmat([1.1*min(continuous_signal_stim) 1.05*min(continuous_signal_stim)],size(spikes_stim),1)','-b')
    title(['Current: ' num2str(currents(stim_id)) ' uA'])
    xlim([-1 5])
    ylim([1.5*min(continuous_signal_stim) 1.5*max(continuous_signal_stim)])
    if stim_id ==6
        legend('Stimulated channel','Stim switch set to stim')
    end
    xlabel('t (s)')

    subplot(2,6,stim_id+6)
    hold on
     plot(0,0,'-r')
    area([0 0 .5 .5 0],...
        [1.5*min(continuous_signal_no_stim) 1.5*max(continuous_signal_no_stim) 1.5*max(continuous_signal_no_stim) 1.5*min(continuous_signal_no_stim) 1.5*min(continuous_signal_no_stim)],...
        'FaceColor',[1 0.7 0.7],'LineStyle','none')
    plot(t,continuous_signal_no_stim,'r')
    plot([spikes_no_stim spikes_no_stim]',repmat([1.1*min(continuous_signal_no_stim) 1.05*min(continuous_signal_no_stim)],size(spikes_no_stim),1)','-r')
    xlabel('t (s)')    
    xlim([-1 5])
    ylim([1.5*min(continuous_signal_no_stim) 1.5*max(continuous_signal_no_stim)])
    if stim_id ==6
        legend('Non-stimulated channel','Stim switch set to stim')
    end
end

% [b,a] = butter(4,1000/(fs/2),'high');
% filtered_stim = filtfilt(b,a,continuous_signal_stim);
% filtered_no_stim = filtfilt(b,a,continuous_signal_no_stim);
% 
% figure;
% hold on
% plot(t,filtered_stim,'b')
% plot(t,filtered_no_stim+2.5*min(filtered_stim),'r')
% legend('Stimulated channel','Non-stimulated channel')
% plot([spikes_stim spikes_stim]',repmat([1.1*min(filtered_stim) 1.05*min(filtered_stim)],size(spikes_stim),1)','-b')
% plot([spikes_no_stim spikes_no_stim]',repmat([4.1*min(filtered_stim) 4.05*min(filtered_stim)],size(spikes_no_stim),1)','-r')
% title(['Current: ' num2str(currents(stim_id)) ' uA'])