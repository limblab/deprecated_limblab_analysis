function h=catch_trials_all(tt,tt_hdr,stimcodes,invert_amp)
    %takes the trial table and trial table header and plots a simple bar
    %chart with the rate of reaching to the secondary target under the
    %catch trial conditions
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
    CI_no_stim=binoinv([0.05 0.95],length(is_left_reach_no_stim),P_no_stim);

    h=figure;
    bar([P_no_stim, zeros(1,length(stimcodes))],'b');
    hold on;
    
    for i=1:length(stimcodes)
        %get catch trials
        tt_catch=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.bump_mag) == 0 & tt(:,tt_hdr.stim_code) == stimcodes(i)) ,  :);

        is_left_reach_catch =(  (tt_catch(:,tt_hdr.trial_result)==0 & ...
                                90 <= tt_catch(:,tt_hdr.bump_angle) &  ...
                                tt_catch(:,tt_hdr.bump_angle)<= 270)    |...
                                (tt_catch(:,tt_hdr.trial_result)==2 & ...   
                                -90 <= tt_catch(:,tt_hdr.bump_angle) & ...
                                tt_catch(:,tt_hdr.bump_angle) <= 90)    |...
                                (tt_catch(:,tt_hdr.trial_result)==2 & ...
                                270 <= tt_catch(:,tt_hdr.bump_angle) & ...
                                tt_catch(:,tt_hdr.bump_angle) <= 360)   );

        
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
        
        temp=zeros(1,length(stimcodes)+1);
        temp(i+1)=P_catch(i);
        bar(temp,'r')
        
    end
    
    %lower errorbars
    e_lower(1)=P_no_stim-CI_no_stim(1)/length(is_left_reach_no_stim);
    %upper errorbars
    e_upper(1)=-P_no_stim+CI_no_stim(2)/length(is_left_reach_no_stim);
    
    
    err_ind=1:(length(stimcodes)+1);
    probs=[P_no_stim,P_catch];
    
    errorbar(err_ind,probs,e_lower,e_upper,'k')
    
    title(['\fontsize{14}Catch trials: reaching rate to primary target\newline' ...
        '\fontsize{10}error is 95% CI computed using matlabs binoinv function']) 
    ylabel('proportion of reaches to the primary target')
    disp(strcat('Probability our stim catch trials are drawn from the same distribution as the no stim catch trials: ',num2str(P_dist)))
    
end