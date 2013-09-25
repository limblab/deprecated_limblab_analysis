function g = bc_psychometric_curve_stim2(tt,tt_hdr,stimcode)
    %receives a trial table and a header object for the trial table. The
    %header object must include the fields bump_angle, trial_result and
    %stim_trial
    %this code assumes that the set of bump directions included in the stim
    %trials does not necessarily match the set from the non-stim trials. as
    %a consequence, the code is bloated by duplicate variables for the stim
    %and non-stim conditions. The code is organized so as to compute and
    %plot the results for stim trials, followed by computing and plotting
    %the results for non-stim trials.

    % exclude aborts
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 ) ,  :); 

    %get only stim trials
    tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcode) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
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
    
    %remap the 180-360deg directions 
    for i=1:length(dirs_stim)
        if dirs_stim(i)>180
            dirs_stim(i)=360-dirs_stim(i);
        end
    end
    dirs_stim=sort(unique(dirs_stim));
    
    %get_stim reaching rates
    proportion_stim = zeros(size(dirs_stim));
    number_reaches_stim = zeros(size(dirs_stim));
    num_left_reaches_stim = zeros(size(dirs_stim));
    for i = 1:length(dirs_stim)
        reaches_stim = find( tt_stim(:,tt_hdr.bump_angle)==dirs_stim(i) | tt_stim(:,tt_hdr.bump_angle)== (360-dirs_stim(i)));                   %vector of trials indexes with a specific bump direction
        num_left_reaches_stim(i) = sum(is_left_reach_stim(reaches_stim));                       %number of reaches to the left with a specific bump direction
        proportion_stim(i) = sum(is_left_reach_stim(reaches_stim)) / length(reaches_stim);      %ratio of left reaches to total reaches at a specific direction
        number_reaches_stim(i) = length(reaches_stim);                                %total count of reaches to the specified direction
    end
    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
    
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for stim reaches in the upper hemispace (0-180deg bumps)
    g_stim = get_ml_fit(dirs_stim,num_left_reaches_stim,number_reaches_stim);
    reach_fit_stim = g_stim(1) + g_stim(2)*erf(g_stim(3)*(dd-g_stim(4)));

    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    H_1=figure;
    % subplot(2,1,1),plot(dirs,ps,'ko')
    plot(dirs_stim,proportion_stim,'rx');
    %title('Psychometric performance under stim and non-stim conditions')
     hold on;
    plot(dd, reach_fit_stim, 'r-');


    %display number of reach stats so the user can estimate the quality of
    %the fits
    disp(strcat('Mean reaches per direction under stim: ',num2str(mean(number_reaches_stim))))
    disp(strcat('Min reaches per direction under stim: ',num2str(min(number_reaches_stim))))
    
    
  
    
    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) ~= 1)),' stim trials'))
    
    dirs_no_stim = sort(unique(tt_no_stim(:,tt_hdr.bump_angle)));
    disp(strcat('Found ',num2str(length(dirs_no_stim)),' bump directions during no stim'))
    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_left_reach_no_stim =( tt_no_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_no_stim(:,tt_hdr.bump_angle) &  tt_no_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_no_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_no_stim(:,tt_hdr.bump_angle) & tt_no_stim(:,tt_hdr.bump_angle) <= 360  );
    
    %remap the 180-360deg directions 
    for i=1:length(dirs_no_stim)
        if dirs_no_stim(i)>180
            dirs_no_stim(i)=360-dirs_no_stim(i);
        end
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

    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the upper hemispace (0-180deg bumps)
    g_no_stim = get_ml_fit(dirs_no_stim,num_left_reaches_no_stim,number_reaches_no_stim);
    reach_fit_no_stim = g_no_stim(1) + g_no_stim(2)*erf(g_no_stim(3)*(dd-g_no_stim(4)));

    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    figure(H_1)
    plot(dirs_no_stim,proportion_no_stim,'bo')
    plot(dd, reach_fit_no_stim, 'b-');
    %legend('target 2 reaches under stim','psychometric fit under stim','target 2 reaches without stim','psychometric fit without stim')

    disp(strcat('Mean reaches per direction without stim: ',num2str(mean(number_reaches_no_stim))))
    disp(strcat('Min reaches per direction without stim: ',num2str(min(number_reaches_no_stim))))


end