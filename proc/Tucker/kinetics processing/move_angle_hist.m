function h=move_angle_hist(pos,tt,tt_hdr, lag)
    % generates a histogram of move angles for the net movement segment
    % between the start of the trial and lag sec into the trial
    
    
    move_dirs=zeros(length(tt(:,1)),1);

    for i=1:length(tt(:,1))
        disp(strcat('Working on trial number: ',num2str(i)))
        move_dirs(i)=get_move_angle(pos(:,1),pos(:,2),pos(:,3),tt(i,tt_hdr.bump_time),tt(i,tt_hdr.end_time));
    end
    figure
    hist(move_dirs)
end