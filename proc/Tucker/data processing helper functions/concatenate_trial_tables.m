function tt_out=concatenate_trial_tables(tt_hdr,tt1,tt2,lag)
    %concatenates trial tables together adding a specified lag to the
    %elements of the second trial table that reflect timings
    
    
    %add lags to the second trial table
    tt2(:,tt_hdr.start_time)=tt2(:,tt_hdr.start_time)+lag;
    tt2(:,tt_hdr.bump_time)=tt2(:,tt_hdr.bump_time)+lag;
    tt2(:,tt_hdr.go_cue)=tt2(:,tt_hdr.go_cue)+lag;
    tt2(:,tt_hdr.end_time)=tt2(:,tt_hdr.end_time)+lag;
    
    tt_out=[tt1;tt2];
end