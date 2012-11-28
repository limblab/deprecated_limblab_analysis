function catch_trials(tt,tt_hdr,stimcode)
    %takes the trial table and trial table header and plots a simple bar
    %chart with the rate of reaching to the secondary target under the
    %nostim, and catch trial conditions
    
    %exclude aborts
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 ) ,  :); 
    %get catch trials
    tt_catch=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.bump_mag) == 0) ,  :);

    is_left_reach_catch =( tt_catch(:,tt_hdr.trial_result)==0 & 90 <= tt_catch(:,tt_hdr.bump_angle) &  tt_catch(:,tt_hdr.bump_angle)<= 270 |...
        tt_catch(:,tt_hdr.trial_result)==2 & -90 <= tt_catch(:,tt_hdr.bump_angle) & tt_catch(:,tt_hdr.bump_angle) <= 90 |...
        tt_catch(:,tt_hdr.trial_result)==2 & 270 <= tt_catch(:,tt_hdr.bump_angle) & tt_catch(:,tt_hdr.bump_angle) <= 360  );
    
    P_catch=sum(is_left_reach_catch)/length(is_left_reach_catch);
    
    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ) ,  :);

    is_left_reach_no_stim =( tt_no_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_no_stim(:,tt_hdr.bump_angle) &  tt_no_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 360  );
    
    P_no_stim=sum(is_left_reach_no_stim)/length(is_left_reach_no_stim);
    CI_no_stim=binoinv([0.05 0.95],length(is_left_reach_no_stim),P_no_stim)
    CI_catch=binoinv([0.05 0.95],length(is_left_reach_catch),P_catch)
    bar([P_no_stim, 0],'b');
    hold on;
    bar([0 P_catch],'r')
   %compute the probability of observing this number of left reaches during
   %stim trials if the rate of left reaches is the same as in the nostim
   %condition
    P_dist=binopdf(sum(is_left_reach_catch),length(is_left_reach_catch),P_no_stim);
    
    title(strcat('reaching rates under stim and nostim. p=',num2str(P_dist)))
    legend('No-stim','Catch')
    %lower errorbars
    e_lower=[P_no_stim-CI_no_stim(1)/length(is_left_reach_no_stim),P_catch-CI_catch(1)/length(is_left_reach_catch)];
    %upper errorbars
    e_upper=[-P_no_stim+CI_no_stim(2)/length(is_left_reach_no_stim),-P_catch+CI_catch(2)/length(is_left_reach_catch)];
    errorbar([1 ,2],[P_no_stim,P_catch],e_lower,e_upper,'k')
    
    disp(strcat('Probability our stim trials are drawn from the same distribution as the no stim trials: ',num2str(P_dist)))
    
end