function plot_aborts(tdf)
    %this function plots all abort trials from a single tdf on the same
    %plot
    
    % compose trial table for only abort trials
    tt = tdf.tt( ( tt(:,tt_hdr.trial_result) == 1 ) ,  :);
    
    figure
    hold on
    title('Abort trials')
    axis equal
    %loop across the trial table and plot the movements for each trial
    for i=1:length(tt(:,1))
        %find the start and stop index for this trial
        t_1=find(tdf.pos(:,1)>tt(i,tdf.tt_hdr.start_time),'first');
        t_2=find(tdf.pos(:,1)>tt(i,tdf.tt_hdr.end_time),'first');
        %add the current trial to the figure
        plot(tdf.pos(t_1:t_2,2),tdf.pos(t_1:t_2,3))
    end

end