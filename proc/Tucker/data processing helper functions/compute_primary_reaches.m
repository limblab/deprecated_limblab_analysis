function R=compute_primary_reaches(tt,tt_hdr)
    R=( tt(:,tt_hdr.trial_result)==0 & 90 >= tt(:,tt_hdr.bump_angle) &  tt(:,tt_hdr.bump_angle)>= -90 |...
        tt(:,tt_hdr.trial_result)==2 & 90 >= tt(:,tt_hdr.bump_angle) & tt(:,tt_hdr.bump_angle) <= 270 |...
        tt(:,tt_hdr.trial_result)==0 & 270 <= tt(:,tt_hdr.bump_angle) & tt(:,tt_hdr.bump_angle) <= 360  );
end