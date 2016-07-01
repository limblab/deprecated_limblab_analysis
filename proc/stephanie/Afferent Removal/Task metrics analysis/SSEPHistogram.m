
histStats = [];

for chan = 1:96
   
    t_vector{chan} = [];
    % Get your stimulus timestamps
    pulse_times = out_struct.words(:,1);
    % Get rid of every other word because 
    %there are two timestamps per pulse
    pulse_times = pulse_times(diff(pulse_times)>0.01);

    for iStim = 1:length(pulse_times)
        temp_t = out_struct.units(chan).ts - pulse_times(iStim);
        temp_t = temp_t(temp_t >= -.5 & temp_t < 0.5);
        t_vector{chan} = [t_vector{chan}; temp_t];
    end

    figure(1)
    clf    %t_axis = (-.5:.05:.7);
    t_axis = (-.5:.01:.7);
    
    hist_t = hist(t_vector{chan},t_axis);
    norm_hist = hist_t/length(pulse_times);
    bar(t_axis,hist_t)
    %    bar(t_axis,norm_hist)
    xlim([min(t_axis) max(t_axis)])
    %ylim([0 0.1])
    title(['Chan ' num2str(out_struct.units(chan).id(1))])
    ylabel('P(spike|stim)')
    xlabel('Delay to spike (in seconds)')
    drawnow
    pause
    
    histStats(chan,1) = max(norm_hist(12:25)); %rightPeak
    histStats(chan,2) = mean(norm_hist(1:10)); %leftMean
    histStats(chan,3) = max(norm_hist(1:10));  %leftPeak
    histStats(chan,4) = mean(norm_hist(12:25)); %rightMean
    
end

 histStatsLabels = {'rightPeak','leftMean', 'leftPeak', 'rightMean'};