function [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_1] = bc_psychometric_curve_stim3_cosplot_compressed(tt,tt_hdr,stimcode,invert_dir,plot_error,invert_error)
    %receives a trial table and a header object for the trial table. The
    %header object must include the fields bump_angle, trial_result and
    %stim_trial
    %this code assumes that the set of bump directions included in the stim
    %trials does not necessarily match the set from the non-stim trials. as
    %a consequence, the code is bloated by duplicate variables for the stim
    %and non-stim conditions. The function is organized so as to compute and
    %plot the results for stim trials, followed by computing and plotting
    %the results for non-stim trials.
    %the stimcode input specifies which stim setting the function will work
    %on
    %the plot error flag is used to force the code to plot the error rate,
    %rather than the rate of choosing the secondary target. The invert
    %error flag switches this to plot the success rate rather than the
    %error rate. if the plot_error flag is 0, then the invert_error flag is
    %ignored
    %if the catch_trial flag is 1 the function will ignore the stimcode,
    %and look for trials where the bump magnitude is 0

    % exclude aborts
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 ) ,  :); 
    %map the 180deg-360deg directions to the 0-180 hemispace
    for i=1:length(tt(:,1))
        if(tt(i,tt_hdr.bump_angle)>180)
            tt(i,tt_hdr.bump_angle)=360-tt(i,tt_hdr.bump_angle);
        end
    end

    %get only stim trials
    tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcode) ,  :);
    
    
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_code) == stimcode)),' stim trials with code: ',num2str(stimcode)))
    %get a list of the bump directions durign stim
    dirs_stim = sort(unique(tt_stim(:,tt_hdr.bump_angle)));
    

    
    disp(strcat('Found ',num2str(length(dirs_stim)),' bump directions during stim'))
    
    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_left_reach_stim =( tt_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_stim(:,tt_hdr.bump_angle) &  tt_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 360  );

    if(invert_dir)
         is_left_reach_stim= abs(is_left_reach_stim-1);
    end
    
    %get_stim reaching rates
    proportion_stim = zeros(size(dirs_stim));
    number_reaches_stim = zeros(size(dirs_stim));
    num_left_reaches_stim = zeros(size(dirs_stim));
    for i = 1:length(dirs_stim)
        reaches_stim = find(tt_stim(:,tt_hdr.bump_angle)==dirs_stim(i));                   %vector of trials indexes with a specific bump direction
        num_left_reaches_stim(i) = sum(is_left_reach_stim(reaches_stim));                       %number of reaches to the left with a specific bump direction
        proportion_stim(i) = sum(is_left_reach_stim(reaches_stim)) / length(reaches_stim);      %ratio of left reaches to total reaches at a specific direction
        number_reaches_stim(i) = length(reaches_stim);                                %total count of reaches to the specified direction
    end


    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
           
   g_stim = lsqcurvefit(@sigmoid,[0,1,90,.2],dirs_stim,proportion_stim);
    reach_fit_stim = sigmoid(g_stim,dd);

    
    
    if(plot_error)
        %invert the proportion of reaches in the 90-270deg space
        for i=1:length(dirs_stim)
            if (dirs_stim(i)>90 && dirs_stim(i)<270) %converts reaching proportion into error rate, reaching proportion is already error rate in the -90 to +90 hemispace
                proportion_stim(i)=1-proportion_stim(i);
            end

        end
        for i=1:length(dd)
            if (dd(i) > 90 && dd(i) < 270)
                reach_fit_stim(i)=1-reach_fit_stim(i);
            end
            
        end
        if invert_error %inverts all the errors
            proportion_stim=1-proportion_stim;
            reach_fit_stim=1-reach_fit_stim;
        end
    end
    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    H_1=figure; %cartesian plot
    dirs_stim=cos(dirs_stim*3.14159/180);
    plot(dirs_stim,proportion_stim,'rx')
    hold on
    dd=cos(dd*3.14159/180);
    plot(dd,reach_fit_stim,'r')

    %display number of reach stats so the user can estimate the quality of
    %the fits
    disp(strcat('Mean reaches per direction under stim: ',num2str(mean(number_reaches_stim))))
    disp(strcat('Min reaches per direction under stim: ',num2str(min(number_reaches_stim))))
    

    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) ~= 1)),' stim trials'))
    
    dirs_no_stim = sort(unique(tt_no_stim(:,tt_hdr.bump_angle)));
        %map the 180deg-360deg directions to the 0-180 hemispace
    
    disp(strcat('Found ',num2str(length(dirs_no_stim)),' bump directions during no stim'))
    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_left_reach_no_stim =( tt_no_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_no_stim(:,tt_hdr.bump_angle) &  tt_no_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 360  );
    
    if(invert_dir)
         is_left_reach_no_stim= abs(is_left_reach_no_stim-1);
    end

    
    %get_no_stim reaching rates
    proportion_no_stim = zeros(size(dirs_no_stim));
    number_reaches_no_stim = zeros(size(dirs_no_stim));
    num_left_reaches_no_stim = zeros(size(dirs_no_stim));
    for i = 1:length(dirs_no_stim)
        reaches_no_stim = find(tt_no_stim(:,tt_hdr.bump_angle)==dirs_no_stim(i));                   %vector of trials indexes with a specific bump direction
        num_left_reaches_no_stim(i) = sum(is_left_reach_no_stim(reaches_no_stim));                       %number of reaches to the left with a specific bump direction
        proportion_no_stim(i) = sum(is_left_reach_no_stim(reaches_no_stim)) / length(reaches_no_stim);      %ratio of left reaches to total reaches at a specific direction
        number_reaches_no_stim(i) = length(reaches_no_stim);                                %total count of reaches to the specified direction
    end    
  
    
    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the upper hemispace (0-180deg bumps)
    
    g_no_stim = lsqcurvefit(@sigmoid,[0,1,90,.2],dirs_no_stim,proportion_no_stim);
    reach_fit_no_stim = sigmoid(g_no_stim ,dd);

    
    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    figure(H_1)

    if(plot_error)
        %invert the proportion of reaches in the 90-270deg space
        for i=1:length(dirs_no_stim)
            if (dirs_no_stim(i)>90 && dirs_no_stim(i)<270) %converts reaching proportion into error rate, reaching proportion is already error rate in the -90 to +90 hemispace
                proportion_no_stim(i)=1-proportion_no_stim(i);
            end

        end
        for i=1:length(dd)
            if (dd(i) > 90 && dd(i) < 270)
                reach_fit_no_stim(i)=1-reach_fit_no_stim(i);
            end
            
        end
        if invert_error %inverts all the errors
            proportion_no_stim=1-proportion_no_stim;
            reach_fit_no_stim=1-reach_fit_no_stim;
        end
    end
    %plot the stim rate data points and the psychometric fit for the stim
    %trials

   % subplot(2,1,1),plot(dirs,ps,'ko')

    figure(H_1) %cartesian plot
    dirs_no_stim=cos(dirs_no_stim*3.14159/180);
    plot(dirs_no_stim,proportion_no_stim,'bo')
    hold on;
    dd=cos(dd*3.14159/180);
    plot(dd,reach_fit_no_stim,'b')

    


end