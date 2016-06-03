function [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H,L,param_list] = bc_psychometric_curve_periodic_stim(tt,tt_hdr,invert_dir)
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

    % exclude aborts and catch trials
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 & tt(:,tt_hdr.bump_mag) ~= 0) ,  :); 
  
    %%plot the no-stim trials
    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ) ,  :);
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) ~= 1)),' no_stim trials'))
    
    dirs_no_stim = sort(unique(tt_no_stim(:,tt_hdr.bump_angle)));
    disp(strcat('Found ',num2str(length(dirs_no_stim)),' bump directions during no stim'))
    %generate a vector containing a 1 if the reach was leftward along the
    %target axis, and zero if the reach was rightward
    %note: the following computation for the number of leftward reaches
    %assumes that the bump angle never exceeds 360 deg
    is_primary_reach_no_stim =compute_primary_reaches(tt_no_stim,tt_hdr);
    %fit a periodic sigmoid to the data
    data=[tt_no_stim(:,tt_hdr.bump_angle);is_primary_reach_no_stim];
    params=fit_periodic_sigmoid(data);
    param_list(1,:)=params;
    L(1)=get_sigmoid_liklihood(data,params,@sigmoid_periodic);
    %get observed reaching rate at each observation point
    proportion_no_stim = zeros(size(dirs_no_stim));
    number_reaches_no_stim = zeros(size(dirs_no_stim));
    num_left_reaches_no_stim = zeros(size(dirs_no_stim));
    for i = 1:length(dirs_no_stim)
        reaches_no_stim = find(tt_no_stim(:,tt_hdr.bump_angle)==dirs_no_stim(i));                   %vector of trials indexes with a specific bump direction
        num_left_reaches_no_stim(i) = sum(is_primary_reach_no_stim(reaches_no_stim));                       %number of reaches to the left with a specific bump direction
        proportion_no_stim(i) = sum(is_primary_reach_no_stim(reaches_no_stim)) / length(reaches_no_stim);      %ratio of left reaches to total reaches at a specific direction
        number_reaches_no_stim(i) = length(reaches_no_stim);                                %total count of reaches to the specified direction
    end    
    
    %plot the stim rate data points and the psychometric fit for the stim
    %trials

    dd=0:360;
    
    H=figure; %cartesian plot of observed probability and fit sigmoid
    subplot(2,1,1),plot(dirs_no_stim,proportion_no_stim,'bo')
    hold on;
    subplot(2,1,1),plot(dd,sigmoid_periodic(params,dd*pi/180),'b')
    axis([-10,370,-0.5,1.5])
    %add subplot with observation counts
    subplot(2,1,2),plot(dirs_no_stim,number_reaches_no_stim,'bo')
    %fix the axes so that the psychometric and the reach counts use the
    %same x axis
    axis([0,370,0,10*(floor(max_reaches/10)+1)])
    disp(strcat('Mean reaches per direction without stim: ',num2str(mean(number_reaches_no_stim))))
    disp(strcat('Min reaches per direction without stim: ',num2str(min(number_reaches_no_stim))))
    
    
    %plot the stim-trials, with color intensity graded by stim code
    
    %%get only stim trials
    
    stimcodes=sort(unique(tt(:,tt_hdr.stim_code)));
    stimcodes=stimcodes(stimcodes~=-1);%exclude no stim flag
    disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
    

    %loop through stim codes plotting each one
    for j=1:length(stimcodes)
        tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcodes(j)) ,  :);
        disp(strcat('Found ',length(tt_stim(:,1)),' stim trials with code: ',num2str(stimcodes(j))))
        %get a list of the bump directions durign stim
        dirs_stim = sort(unique(tt_stim(:,tt_hdr.bump_angle)));
        disp(strcat('Found ',num2str(length(dirs_stim)),' bump directions during stim with stimcode ', num2str(stimcodes(j))))
        
        %generate a vector containing a 1 if the reach was leftward along the
        %target axis, and zero if the reach was rightward
        %note: the following computation for the number of leftward reaches
        %assumes that the bump angle never exceeds 360 deg
        is_primary_reach_stim =compute_primary_reaches(tt_stim,tt_hdr);
        %fit a periodic sigmoid to the data

        data=[tt_stim(:,tt_hdr.bump_angle);is_primary_reach_stim];
        params=fit_periodic_sigmoid(data);
        param_list(j+1,:)=params;
        L(j+1)=get_sigmoid_liklihood(data,params,@sigmoid_periodic);
        %get observed reaching rate at each observation point
        proportion_stim = zeros(size(dirs_stim));
        number_reaches_stim = zeros(size(dirs_stim));
        num_left_reaches_stim = zeros(size(dirs_stim));
        for i = 1:length(dirs_stim)
            reaches_stim = find(tt_stim(:,tt_hdr.bump_angle)==dirs_stim(i));                   %vector of trials indexes with a specific bump direction
            num_left_reaches_stim(i) = sum(is_primary_reach_stim(reaches_stim));                       %number of reaches to the left with a specific bump direction
            proportion_stim(i) = sum(is_primary_reach_stim(reaches_stim)) / length(reaches_stim);      %ratio of left reaches to total reaches at a specific direction
            number_reaches_stim(i) = length(reaches_stim);                                %total count of reaches to the specified direction
        end    

        %plot the stim rate data points and the psychometric fit for the stim
        %trials

        dd=0:360;
        C=[1 (j-1)/length(stimcodes) (j-1)/length(stimcodes)];
        figure(H); %cartesian plot of observed probability and fit sigmoid
        subplot(2,1,1),plot(dirs_stim,proportion_stim,'x','Colors',C)
        hold on;
        subplot(2,1,1),plot(dd,sigmoid_periodic(params,dd*pi/180),'Colors',C,'LineWidth',2)
        axis([-10,370,-0.5,1.5])
        %add subplot with observation counts
        subplot(2,1,2),plot(dirs_stim,number_reaches_stim,'x','Colors',C)
        %fix the axes so that the psychometric and the reach counts use the
        %same x axis
        axis([0,370,0,10*(floor(max_reaches/10)+1)])
        disp(strcat('Mean reaches per direction with stim: ',num2str(mean(number_reaches_stim))))
        disp(strcat('Min reaches per direction with stim: ',num2str(min(number_reaches_stim))))

    end
    
    format_for_lee(subplot(2,1,1));
    format_for_lee(subplot(2,1,2));
end