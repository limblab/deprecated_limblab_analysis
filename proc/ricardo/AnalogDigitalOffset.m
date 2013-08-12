load('\\citadel\data\TestData\T_offset_test\T_offset_test','bdf')
% clear bdf
% bdf{1} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_no_sync001.nev',3);
% bdf{2} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_synced001.nev',3);
% bdf{3} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_synced_recording_from_both001.nev',3);
% bdf{4} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_no_sync002.nev',3);
% bdf{5} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_synced002.nev',3);
% bdf{6} = get_cerebus_data('Z:\Kevin_12A2\T_offset_test_synced_recording_from_both002.nev',3);
% save('\\citadel\data\TestData\T_offset_test\T_offset_test','bdf')
titles = {'No sync, 30kHz','Synced, 30kHz','Synced, recording from both, 30kHz',...
    'No sync, 2kHz','Synced, 2kHz','Synced, recording from both, 2kHz'};    

%%
figure; 
for iBDF = 1:length(bdf)
    subplot(2,3,iBDF)
    plot(bdf{iBDF}.analog.ts,bdf{iBDF}.analog.data{27})
    hold on
    plot([bdf{iBDF}.units(1).ts bdf{iBDF}.units(1).ts]',[0 4000]','r')    
    analog_onset = find(diff(bdf{iBDF}.analog.data{27})>1000);
    analog_onset(find(diff(analog_onset) < 2)+1) = [];
    analog_spikes = bdf{iBDF}.analog.ts(analog_onset)';
    analog_spikes = analog_spikes(analog_spikes>2 & analog_spikes<bdf{iBDF}.analog.ts(end)-2);
    digital_spikes = bdf{iBDF}.units(1).ts;
    digital_spikes = digital_spikes(digital_spikes>2 & digital_spikes<bdf{iBDF}.analog.ts(end)-2);

    average_delay = mean(analog_spikes-digital_spikes);
    title({titles{iBDF};['Average delay: ' num2str(average_delay*1000) ' ms']})
    xlabel('t (s)')
    legend('Digital','Analog')
    xlim([analog_spikes(2)-.03 analog_spikes(2)+.03])
end
