function print_times(tdf,trial)
    disp(strcat('Start: ',num2str(tdf.tt(trial,tdf.tt_hdr.start_time))))
    disp(strcat('Bump: ',num2str(tdf.tt(trial,tdf.tt_hdr.bump_time))))
    disp(strcat('Go: ',num2str(tdf.tt(trial,tdf.tt_hdr.go_cue))))
    disp(strcat('End: ',num2str(tdf.tt(trial,tdf.tt_hdr.end_time))))


end