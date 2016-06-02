function [B,stat] = bc_psychometric_curve_stim5(tt,tt_hdr)

    % exclude aborts
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 ) ,  :); 
    %exclude catch trials
    tt = tt( ( tt(:,tt_hdr.bump_mag) ~= 0 ) ,  :); 
    %get a vector of flag values indicating whether the reach from each
    %trial was to the primary or secondary target
    is_secondary_target =( tt(:,tt_hdr.trial_result)==0 & 90 <= tt(:,tt_hdr.bump_angle) &  tt(:,tt_hdr.bump_angle)<= 270 |...
        tt(:,tt_hdr.trial_result)==2 & -90 <= tt(:,tt_hdr.bump_angle) & tt(:,tt_hdr.bump_angle) <= 90 |...
        tt(:,tt_hdr.trial_result)==2 & 270 <= tt(:,tt_hdr.bump_angle) & tt(:,tt_hdr.bump_angle) <= 360  );
    
    

    [B,stat]=mnrfit([tt(:,tt_hdr.bumpdir) ; tt(:,tt_hdr.stim_code)],is_secondary_target);
end