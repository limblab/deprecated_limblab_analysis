function [H1,H2]=plot_tail_choices(tt,tt_hdr,varargin)
    %plots the binary selections in the tails of our psychometric 
    %distribution against time
        


    % exclude aborts and catch trials
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 & tt(:,tt_hdr.bump_mag)~=0) ,  :); 

    %get only stim trials
    if ~isempty(varargin)
        stimcode=varargin{1};
        tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcode) ,  :);
    else
        stimcode=-1;
        tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 ) ,  :);
    end
    tt_no_stim=tt( ( tt(:,tt_hdr.stim_trial) ~= 1 ),:);

    is_primary_reach_stim =~( tt_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_stim(:,tt_hdr.bump_angle) &  tt_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 360  );

    is_primary_reach_no_stim =~( tt_no_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_no_stim(:,tt_hdr.bump_angle) &  tt_no_stim(:,tt_hdr.bump_angle)<= 270 |...
            tt_no_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 90 |...
            tt_no_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 360  );
    
    
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_code) == stimcode)),' stim trials with code: ',num2str(stimcode)))
    %get a list of the bump directions during stim
    dirs_stim = sort(unique(tt_stim(:,tt_hdr.bump_angle)));
    disp(strcat('Found ',num2str(length(dirs_stim)),' bump directions during stim'))
    
    %look at bumps towards the PD bump angle from -50deg to 50deg
    tt_stim_up=tt_stim( ( tt_stim(:,tt_hdr.bump_angle)<50 | tt_stim(:,tt_hdr.bump_angle)>310  ) ,:);
    tt_no_stim_up=tt_no_stim(( tt_no_stim(:,tt_hdr.bump_angle)<50 | tt_no_stim(:,tt_hdr.bump_angle)>310  ),:);
    is_primary_reach_stim_up=is_primary_reach_stim(tt_stim(:,tt_hdr.bump_angle)<50 | tt_stim(:,tt_hdr.bump_angle)>310  );
    is_primary_reach_no_stim_up=is_primary_reach_no_stim(tt_no_stim(:,tt_hdr.bump_angle)<50 | tt_no_stim(:,tt_hdr.bump_angle)>310  );
    
    %get linear regression to points
    p=polyfit(tt_stim_up(:,tt_hdr.bump_time),is_primary_reach_stim_up(:),1);
    trend=polyval(p,tt_stim_up(:,tt_hdr.bump_time));
    
    %test beginning vs end using binomial theorem
    endtime=tt_stim(end,tt_hdr.bump_time);
    starttime=tt_stim(1,tt_hdr.bump_time);
    halftime=(endtime-starttime)/2;
    firsthalf=(tt_stim_up(:,tt_hdr.bump_time)<halftime);
    secondhalf=(tt_stim_up(:,tt_hdr.bump_time)>halftime);
    total_beginning=sum(firsthalf);
    preferred_beginning=sum(is_primary_reach_stim_up(firsthalf));
    rate_beginning=preferred_beginning/total_beginning;
    total_end=sum(secondhalf);
    preferred_end=sum(is_primary_reach_stim_up(secondhalf));
    prob_up=binocdf(preferred_end,total_end,rate_beginning);
    
    %draw the figure
    H1=figure;
    plot(tt_stim_up(:,tt_hdr.bump_time),is_primary_reach_stim_up(:),'rx')
    hold on
    title('primary target selections for bumps in the -50 to 50 deg window')
    if prob_up<.05
        %draw our trend in black
        plot(tt_stim_up(:,tt_hdr.bump_time),trend,'-k')
    else
        %draw our trend in green
        plot(tt_stim_up(:,tt_hdr.bump_time),trend,'-g')
        disp(strcat('beginning and end rates for PD tail are different with a p val of: ',num2str(prob_up)))
    end
    %plot(tt_no_stim_up(:,tt_hdr.bump_time),is_primary_reach_no_stim_up(:),'bo')
    
    
    %look at bumps away from the PD from 130deg to 230 deg
    tt_stim_down=tt_stim( ( tt_stim(:,tt_hdr.bump_angle)>130 & tt_stim(:,tt_hdr.bump_angle)<230 ),:);
    tt_no_stim_down=tt_no_stim(( tt_no_stim(:,tt_hdr.bump_angle)>130 | tt_no_stim(:,tt_hdr.bump_angle)<230  ),:);
    is_primary_reach_stim_down=is_primary_reach_stim(tt_stim(:,tt_hdr.bump_angle)>130 & tt_stim(:,tt_hdr.bump_angle)<230);
    is_primary_reach_no_stim_down=is_primary_reach_no_stim(tt_no_stim(:,tt_hdr.bump_angle)>130 | tt_no_stim(:,tt_hdr.bump_angle)<230);
    
        %get linear regression to points
    p=polyfit(tt_stim_down(:,tt_hdr.bump_time),is_primary_reach_stim_down(:),1);
    trend=polyval(p,tt_stim_down(:,tt_hdr.bump_time));
    
    %test beginning vs end using binomial theorem
    endtime=tt_stim(end,tt_hdr.bump_time);
    starttime=tt_stim(1,tt_hdr.bump_time);
    halftime=(endtime-starttime)/2;
    firsthalf=(tt_stim_down(:,tt_hdr.bump_time)<halftime);
    secondhalf=(tt_stim_down(:,tt_hdr.bump_time)>halftime);
    total_beginning=sum(firsthalf);
    preferred_beginning=sum(is_primary_reach_stim_down(firsthalf));
    rate_beginning=preferred_beginning/total_beginning;
    total_end=sum(secondhalf);
    preferred_end=sum(is_primary_reach_stim_down(secondhalf));
    prob_down=binocdf(preferred_end,total_end,rate_beginning);
    
    length(tt_stim)
    length(tt_stim_down)
    H2=figure;
    plot(tt_stim_down(:,tt_hdr.bump_time),is_primary_reach_stim_down(:),'rx')
    hold on
    title('primary target selections for bumps in the 130 to 230 deg window')
    if prob_down<.05
        %draw our trend in black
        plot(tt_stim_down(:,tt_hdr.bump_time),trend,'-k')
        disp(strcat('beginning and end rates for PD tail are different with a p val of: ',num2str(prob_down)))
    else
        %draw our trend in green
        plot(tt_stim_down(:,tt_hdr.bump_time),trend,'-g')
        
    end
    %plot(tt_no_stim_down(:,tt_hdr.bump_time),is_primary_reach_no_stim_down(:),'bo')
end