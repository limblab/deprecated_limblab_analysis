function h=catch_trials_all_2PD(tt,tt_hdr,invert_amp)
    %takes the trial table and trial table header and plots a simple bar
    %chart with the rate of reaching to the secondary target under the
    %catch trial conditions
    %
    %
    %
%    this is a cludge that only works for sessions with 4 stim conditions
%
%
%
    %exclude aborts
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 ) ,  :); 
    
    
    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 & tt(:,tt_hdr.bump_mag) == 0) ,  :);

    is_left_reach_no_stim =( tt_no_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_no_stim(:,tt_hdr.bump_angle) &  tt_no_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 360  );
    
    P_no_stim=sum(is_left_reach_no_stim)/length(is_left_reach_no_stim);
    if(invert_amp)
        P_no_stim=1-P_no_stim;
    end
    CI_no_stim=binoinv([0.05 0.95],length(is_left_reach_no_stim),P_no_stim)

    h=figure;
    bar([P_no_stim, 0, 0, 0, 0],'b');
    hold on;
    
    
    %find the stim conditions used
    stimcodes=[0,1];
    
    
    for i=1:2
        %get catch trials
        tt_catch=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.bump_mag) == 0 & tt(:,tt_hdr.stim_code) == stimcodes(i)) ,  :);

        is_left_reach_catch =( tt_catch(:,tt_hdr.trial_result)==0 & 90 <= tt_catch(:,tt_hdr.bump_angle) &  tt_catch(:,tt_hdr.bump_angle)<= 270 |...
            tt_catch(:,tt_hdr.trial_result)==2 & -90 <= tt_catch(:,tt_hdr.bump_angle) & tt_catch(:,tt_hdr.bump_angle) <= 90 |...
            tt_catch(:,tt_hdr.trial_result)==2 & 270 <= tt_catch(:,tt_hdr.bump_angle) & tt_catch(:,tt_hdr.bump_angle) <= 360  );

        P_catch(i)=sum(is_left_reach_catch)/length(is_left_reach_catch);
        if(invert_amp)
            P_catch(i)=1-P_catch(i);
        end
        CI_catch=binoinv([0.05 0.95],length(is_left_reach_catch),P_catch(i));
        e_lower(i+1)=P_catch(i)-CI_catch(1)/length(is_left_reach_catch);
        e_upper(i+1)=-P_catch(i)+CI_catch(2)/length(is_left_reach_catch);
        %compute the probability of observing this number of left reaches during
        %stim trials if the rate of left reaches is the same as in the nostim
        %condition
        P_dist(i)=binopdf(sum(is_left_reach_catch),length(is_left_reach_catch),P_no_stim);
    end
     bar([0, P_catch(1), 0, 0, 0],'r')
     bar([0, 0, P_catch(2), 0, 0],'r') 
     bar([0, 0, 0, P_catch(3), 0],'r')
     bar([0, 0, 0, 0, P_catch(4)],'r')
    
    title(strcat('reaching rates under catch trial conditions'))
    legend('No-stim',strcat('5uA: p=',num2str(P_dist(1))),strcat('10uA: p=',num2str(P_dist(2))),strcat('15uA: p=',num2str(P_dist(3))),strcat('20uA: p=',num2str(P_dist(4))))
    %lower errorbars
    e_lower(1)=P_no_stim-CI_no_stim(1)/length(is_left_reach_no_stim);
    %upper errorbars
    e_upper(1)=-P_no_stim+CI_no_stim(2)/length(is_left_reach_no_stim);
    
    errorbar([1,2,3,4,5],[P_no_stim,P_catch(1),P_catch(2),P_catch(3),P_catch(4)],e_lower,e_upper,'k')
    
    disp(strcat('Probability our stim catch trials are drawn from the same distribution as the no stim catch trials: ',num2str(P_dist)))
    
end