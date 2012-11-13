function g = bc_psychometric_curve_stim(tt,tt_hdr,stimcode)
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

    %segregate the bump angles by hemispace relative to the target axis 
    %(some trials have shown different biases in the upper and lower 
    %hemispaces)
    up_dirs_stim = dirs_stim(dirs_stim<=180);
    down_dirs_stim = dirs_stim(dirs_stim>=180);
    %re-map the angles so that the left and right bumps can plot along the
    %same axis, and the curve fitting works properly
    down_dirs_stim = 360-down_dirs_stim;
    
    
    %split the reach counts to upper and lower hemispaces
    %stim:
    proportion_stim_upper = proportion_stim(dirs_stim<=180);
    proportion_stim_lower = proportion_stim(dirs_stim>=180);
    num_left_reaches_stim_upper = num_left_reaches_stim(dirs_stim<=180);
    num_left_reaches_stim_lower = num_left_reaches_stim(dirs_stim>=180);
    number_reaches_stim_upper = number_reaches_stim(dirs_stim<=180);
    number_reaches_stim_lower = number_reaches_stim(dirs_stim>=180);

    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
    
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for stim reaches in the upper hemispace (0-180deg bumps)
    g_stim_upper = get_ml_fit(up_dirs_stim,num_left_reaches_stim_upper,number_reaches_stim_upper);
    reach_fit_stim_upper = g_stim_upper(1) + g_stim_upper(2)*erf(g_stim_upper(3)*(dd-g_stim_upper(4)));

    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for stim reaches in the lower hemispace (180-360deg bumps)
    g_stim_lower = get_ml_fit(down_dirs_stim,num_left_reaches_stim_lower,number_reaches_stim_lower);
    reach_fit_stim_lower = g_stim_lower(1) + g_stim_lower(2)*erf(g_stim_lower(3)*(dd-g_stim_lower(4)));


    
    %recombine the hemispaces
    %re-shift the directions in the lower hemispace
    down_dirs_stim=360-down_dirs_stim;
    
    %dirs
    dirs_stim=[up_dirs_stim;down_dirs_stim];
    %proportion reaches
    proportion_stim=[proportion_stim_upper;proportion_stim_lower];
    %psychometric fits
    reach_fit_stim=[reach_fit_stim_upper,reach_fit_stim_lower(end:-1:1)];
    %psychometric base
    dd=[dd,360-dd(end:-1:1)];
    
    
    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    H_1=figure;

%     %add cardinal lines to force the size
    polar([90*pi/180 270*pi/180],[1.01 1.01],'k')
    hold on;
    polar([0 180*pi/180],[1.01 1.01],'k')
    polar(dirs_stim*pi/180,proportion_stim,'ro')
    hold on;

    polar(dd*pi/180,reach_fit_stim,'r')
    % subplot(2,1,1),plot(dirs,ps,'ko')

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
    
    up_dirs_no_stim = dirs_no_stim(dirs_no_stim<=180);
    down_dirs_no_stim = dirs_no_stim(dirs_no_stim>=180);
    %re-map the angles so that the left and right bumps can plot along the same axis
    %right_dirs = right_dirs-180;%remapps the angles so that the left and right bumps can plot along the same axis
    down_dirs_no_stim = 360-down_dirs_no_stim;
    
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
    
    %split the reach counts to upper and lower hemispaces
    %no stim
    proportion_no_stim_upper = proportion_no_stim(dirs_no_stim<=180);
    proportion_no_stim_lower = proportion_no_stim(dirs_no_stim>=180);
    num_left_reaches_no_stim_upper = num_left_reaches_no_stim(dirs_no_stim<=180);
    num_left_reaches_no_stim_lower = num_left_reaches_no_stim(dirs_no_stim>=180);
    number_reaches_no_stim_upper = number_reaches_no_stim(dirs_no_stim<=180);
    number_reaches_no_stim_lower = number_reaches_no_stim(dirs_no_stim>=180);    
    
    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the upper hemispace (0-180deg bumps)
    g_no_stim_upper = get_ml_fit(up_dirs_no_stim,num_left_reaches_no_stim_upper,number_reaches_no_stim_upper);
    reach_fit_no_stim_upper = g_no_stim_upper(1) + g_no_stim_upper(2)*erf(g_no_stim_upper(3)*(dd-g_no_stim_upper(4)));
        %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the lower hemispace (180-360deg bumps)
    g_no_stim_lower = get_ml_fit(down_dirs_no_stim,num_left_reaches_no_stim_lower,number_reaches_no_stim_lower);
    reach_fit_no_stim_lower = g_no_stim_lower(1) + g_no_stim_lower(2)*erf(g_no_stim_lower(3)*(dd-g_no_stim_lower(4)));
    
    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    figure(H_1)
%     subplot(2,1,1),plot(up_dirs_no_stim,proportion_no_stim_upper,'bo')
%     subplot(2,1,1),plot(dd, reach_fit_no_stim_upper, 'b-');
%  
%     subplot(2,1,2),plot(down_dirs_no_stim,proportion_no_stim_lower,'bo')
%     subplot(2,1,2),plot(dd, reach_fit_no_stim_lower, 'b-');


    
    %recombine the hemispaces
    %re-shift the directions in the lower hemispace
    down_dirs_no_stim=360-down_dirs_no_stim;
    
    %dirs
    dirs_no_stim=[up_dirs_no_stim;down_dirs_no_stim];
    %proportion reaches
    proportion_no_stim=[proportion_no_stim_upper;proportion_no_stim_lower];
    %psychometric fits
    reach_fit_no_stim=[reach_fit_no_stim_upper,reach_fit_no_stim_lower(end:-1:1)];
    %psychometric base
    dd=[dd,360-dd(end:-1:1)];
    
    
    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    figure(H_1)
    polar(dirs_no_stim*pi/180,proportion_no_stim,'bo')
    hold on;
    polar(dd*pi/180,reach_fit_no_stim,'b')
    % subplot(2,1,1),plot(dirs,ps,'ko')



    disp(strcat('Mean reaches per direction without stim: ',num2str(mean(number_reaches_no_stim))))
    disp(strcat('Min reaches per direction without stim: ',num2str(min(number_reaches_no_stim))))


end