function [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_2] = bc_psychometric_curve_stim7(tt,tt_hdr,stimcode,invert_dir)
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

    %get only stim trials
    tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcode) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_code) == stimcode)),' stim trials with code: ',num2str(stimcode)))
    %get a list of the bump directions durign stim
    angs_stim=tt_stim(:,tt_hdr.bump_angle);
    dirs_stim = sort(unique(angs_stim));
    disp(strcat('Found ',num2str(length(dirs_stim)),' bump directions during stim'))
    
    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_left_reach_stim =( tt_stim(:,tt_hdr.trial_result)==0 & 90 <= tt_stim(:,tt_hdr.bump_angle) &  tt_stim(:,tt_hdr.bump_angle)<= 270 |...
        tt_stim(:,tt_hdr.trial_result)==2 & -90 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 90 |...
        tt_stim(:,tt_hdr.trial_result)==2 & 270 <= tt_stim(:,tt_hdr.bump_angle) & tt_stim(:,tt_hdr.bump_angle) <= 360  );

    if(invert_dir)
         is_left_reach_stim= ~is_left_reach_stim;
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

    %segregate the bump angles by hemispace relative to the target axis 
    %(some trials have shown different biases in the upper and lower 
    %hemispaces)
    up_angs_stim=angs_stim(angs_stim<=180);
    up_is_left_reach_stim=is_left_reach_stim(angs_stim<=180);
    down_angs_stim=angs_stim(angs_stim>=180);
    down_is_left_reach_stim=is_left_reach_stim(angs_stim>=180);
    up_dirs_stim = dirs_stim(dirs_stim<=180);
    down_dirs_stim = dirs_stim(dirs_stim>=180);
    %re-map the angles so that the left and right bumps can plot along the
    %same axis, and the curve fitting works properly
    down_dirs_stim = 360-down_dirs_stim;
    
    
    %split the reach counts to upper and lower hemispaces
    %stim:
    proportion_stim_upper = proportion_stim(dirs_stim<=180);
    proportion_stim_lower = proportion_stim(dirs_stim>=180);
    number_reaches_stim_upper = number_reaches_stim(dirs_stim<=180);
    number_reaches_stim_lower = number_reaches_stim(dirs_stim>=180);

    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
              
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for stim reaches in the upper hemispace (0-180deg bumps)
    data_stim_upper=[up_angs_stim,up_is_left_reach_stim];
    [g_stim_upper,logpdf_stim_upper]=get_ml_sigmoid(data_stim_upper);
    %g_stim_upper = lsqcurvefit(@sigmoid,[0,1,90,.2],up_dirs_stim,proportion_stim_upper);
    reach_fit_stim_upper = sigmoid(g_stim_upper,dd);

    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for stim reaches in the lower hemispace (180-360deg bumps)
    data_stim_lower=[360-down_angs_stim,down_is_left_reach_stim];
    [g_stim_lower,logpdf_stim_lower]=get_ml_sigmoid(data_stim_lower);
    %[g_stim_lower] = lsqcurvefit(@sigmoid,[0,1,90,.2],down_dirs_stim,proportion_stim_lower);
    reach_fit_stim_lower = sigmoid(g_stim_lower,dd);

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
    %number of reaches
    number_reaches_stim=[number_reaches_stim_upper;number_reaches_stim_lower];

    %plot the stim rate data points and the psychometric fit for the stim
    %trials
  
    H_2=figure; %cartesian plot
    subplot(2,1,1),plot(dirs_stim,proportion_stim,'rx')
    hold on

    subplot(2,1,1),plot(dd,reach_fit_stim,'r')

    subplot(2,1,2),plot(dirs_stim,number_reaches_stim,'rx')
    hold on
    
    %display number of reach stats so the user can estimate the quality of
    %the fits
    disp(strcat('Mean reaches per direction under stim: ',num2str(mean(number_reaches_stim))))
    disp(strcat('Min reaches per direction under stim: ',num2str(min(number_reaches_stim))))
    

    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) ~= 1)),' stim trials'))
    
    angs_no_stim=tt_no_stim(:,tt_hdr.bump_angle);
    dirs_no_stim = sort(unique(angs_no_stim));
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
    
    %split reaches into upper and lower hemispaces
    up_dirs_no_stim = dirs_no_stim(dirs_no_stim<=180);
    up_angs_no_stim=angs_no_stim(angs_no_stim<=180);
    up_is_left_reach_no_stim=is_left_reach_no_stim(angs_no_stim<=180);
    down_dirs_no_stim = dirs_no_stim(dirs_no_stim>=180);
    down_angs_no_stim=angs_no_stim(angs_no_stim>=180);
    down_is_left_reach_no_stim=is_left_reach_no_stim(angs_no_stim>=180);
    
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
    number_reaches_no_stim_upper = number_reaches_no_stim(dirs_no_stim<=180);
    number_reaches_no_stim_lower = number_reaches_no_stim(dirs_no_stim>=180);    
    
    
    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:180;
    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the upper hemispace (0-180deg bumps)
    data=[up_angs_no_stim,up_is_left_reach_no_stim];
    [g_no_stim_upper,logpdf_no_stim_upper]=get_ml_sigmoid(data);
    %g_no_stim_upper = lsqcurvefit(@sigmoid,[0,1,90,.2],up_dirs_no_stim,proportion_no_stim_upper);
    reach_fit_no_stim_upper = sigmoid(g_no_stim_upper ,dd);
        %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the lower hemispace (180-360deg bumps)
    data=[360-down_angs_no_stim,down_is_left_reach_no_stim];
    [g_no_stim_lower,logpdf_no_stim_lower]=get_ml_sigmoid(data);
    %g_no_stim_lower = lsqcurvefit(@sigmoid,[0,1,90,.2],down_dirs_no_stim,proportion_no_stim_lower);
    reach_fit_no_stim_lower = sigmoid(g_no_stim_lower,dd);
    
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
    %number of reaches
    number_reaches_no_stim=[number_reaches_no_stim_upper;number_reaches_no_stim_lower];
    

    %plot the stim rate data points and the psychometric fit for the stim
    %trials
    figure(H_2); %cartesian plot
    subplot(2,1,1),plot(dirs_no_stim,proportion_no_stim,'bo')
    hold on;

    subplot(2,1,1),plot(dd,reach_fit_no_stim,'b')
    axis([0,370,-0.5,1.5])
    subplot(2,1,2),plot(dirs_no_stim,number_reaches_no_stim,'bo')
    %fix the axes so that the psychometric and the reach counts use the
    %same x axis
    max_reaches=max(max(number_reaches_no_stim),max(number_reaches_stim));
    axis([0,370,0,10*(floor(max_reaches/10)+1)])
    disp(strcat('Mean reaches per direction without stim: ',num2str(mean(number_reaches_no_stim))))
    disp(strcat('Min reaches per direction without stim: ',num2str(min(number_reaches_no_stim))))
    %test whether the stim sigmoid fits the stim data better in a
    %statistically significant way. Will use a likelihood ratio test,
    %assuming that the stim fit is an extension of the non-stim model and
    %thus doubles the degrees of freedom. The likelihood ratio then follows
    %a Chi-Sq distribution with degrees of freedom=8 (DOF_unrestricted-
    %DOF_restricted=16-8) (this would be 4, but we are modeling the range 
    %0-360deg with 2 sigmoids, thus 8 parameters for the restricted model
    %(non stim fit) and 16 for the unrestricted (stim fit)
    
    logpdf_null_upper=logpdf_sigmoid2(data_stim_upper,g_no_stim_upper);
    logpdf_null_lower=logpdf_sigmoid2(data_stim_lower,g_no_stim_lower);
    [h,pValue,stat,cValue] = lratiotest(-1*(logpdf_stim_upper+logpdf_stim_lower),-1*(logpdf_null_lower+logpdf_null_upper),8,.05);
    figure(H_2);
    subplot(2,1,1),h=legend(['Stim: p=',num2str(pValue)],'Non stim');
    if invert_dir
        set(h,'Location','north')
    else
        set(h,'Location','south')
    end
    %D follows a Chi-sq distribution
end