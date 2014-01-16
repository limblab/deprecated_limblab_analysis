function [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_1,g_stim,g_no_stim] = bc_psychometric_curve_stim_cosplot_all(tt,tt_hdr,invert_dir)
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
    %exclude the one random target at 0deg
    tt = tt( ( tt(:,tt_hdr.tgt_angle) ~= 0 ) ,  :); 
    
    %set the angle interval on which the fit curves will be displayed
    dd = 0:.01:360;
   
    %%
    %get curves and data for non-stim trials:
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

    %get the parameters of the maximum likelyhood model of the psychometric
    %curve for no-stim reaches in the upper hemispace (0-180deg bumps)
    optifun=@(P) sigmoid_square_error(P,dirs_no_stim*pi/180,proportion_no_stim); %defined at end of this function
    g_no_stim = fminsearch(optifun,[0,1,.65,10,.75]);
    optifun=@(P) inv_liklihood(P,[dirs_no_stim*pi/180,num_left_reaches_no_stim,number_reaches_no_stim]);  %defined at end of this function
    g_no_stim=fminsearch(optifun,g_no_stim);
    reach_fit_no_stim = sigmoid_periodic2(g_no_stim ,dd*3.14159/180);
    disp(strcat('Mean reaches per direction without stim: ',num2str(mean(number_reaches_no_stim))))
    disp(strcat('Min reaches per direction without stim: ',num2str(min(number_reaches_no_stim))))
    %%
    %plot the non_stim data and fit
    %plot the data points 
    H_1=figure; %cartesian plot
    plot(dirs_no_stim,proportion_no_stim,'bo')
    hold on
    %plot the fit curve keeping the handle for adding a legend later
    legend_handles(1)=plot(dd,reach_fit_no_stim,'b');
    legend_text{1}='Non-Stim';
    
    %%
    %loop across stim conditions:
    stimcode=unique(tt(:,tt_hdr.stim_code));
    
    %set the RGB color values to plot stim curves from:
    color_range=[0,1];
    numlevels=length(stimcode);
    color_incriment=(color_range(2)-color_range(1))/numlevels;
    color_levels=[color_range(2):-1*color_incriment:color_range(1)];
    offset=0;
    for j=1:length(stimcode)
        %don't do the loop for the non-stim trials
        if stimcode(j)<0
            continue
        end
        %get only stim trials
        tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcode(j)) ,  :);
        disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_trial) == 1)),' stim trials'))
        disp(strcat('Found ',num2str(sum(tt(:,tt_hdr.stim_code) == stimcode(j))),' stim trials with code: ',num2str(stimcode(j))))
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

        %get the parameters of the maximum likelyhood model of the psychometric
        %curve for stim reaches
        optifun=@(P) sigmoid_square_error(P, dirs_stim*pi/180,proportion_stim);      %defined at end of this function
        g_stim = fminsearch(optifun,[0,1,.65,10,.75]);
        optifun=@(P) inv_liklihood(P,[dirs_stim*pi/180,num_left_reaches_stim,number_reaches_stim]);
%   Problem=createOptimProblem('fmincon','objective',optifun,'nonlcon',@constr);
%     GS=Globalsearch;
%     run(GS,Problem);  

        optifun=@(P) bounded_inv_liklihood(P,[dirs_stim*pi/180,num_left_reaches_stim,number_reaches_stim]);  %defined at end of this function
        %g_stim=fminsearch(optifun,g_stim);
        g_stim=fmincon(optifun,g_stim,[],[],[],[],[],[],@constr);
        reach_fit_stim = sigmoid_periodic2(g_stim,dd*pi/180);

        %display number of reach stats so the user can estimate the quality of
        %the fits
        disp(strcat('For stim case: ',num2str(stimcode(j)),':'))
        disp(strcat('Mean reaches per direction under stim: ',num2str(mean(number_reaches_stim))))
        disp(strcat('Min reaches per direction under stim: ',num2str(min(number_reaches_stim))))

        %test the stim data for significance:
        L_null=get_sigmoid_liklihood2([dirs_no_stim*pi/180,num_left_reaches_no_stim,number_reaches_no_stim],g_no_stim,@sigmoid_periodic2);
        L_stim=get_sigmoid_liklihood2([dirs_stim*pi/180,num_left_reaches_stim,number_reaches_stim],g_stim,@sigmoid_periodic2);

        D=2*(log(L_stim)-log(L_null));
        P(j)=1-chi2cdf(D,1); %(assumes 1DOF)

        if P(j)<0.05
            plotcolor=[1,color_levels(j),color_levels(j)];
        else
            plotcolor=[color_levels(j),1,1];
        end

        %do the plotting
        %points:
        %plot the data points for the stim trials
        plot(dirs_stim,proportion_stim,'Marker','x', 'LineStyle', 'none','Color',plotcolor)
        hold on
        %plot the fit curves, adding the handle to the vector and updating
        %the legend text
        legend_handles(length(legend_handles)+1)=plot(dd,reach_fit_stim,'Color',plotcolor);
        legend_text{length(legend_text)+1}=strcat('Stim level ',num2str(stimcode(j)),' P=',num2str(P(j)));
       
    end

    %%
    %add a legend and format the figure for Lee
    legend(legend_handles,legend_text)
    format_for_lee(H_1)

end
function out=sigmoid_square_error(params,x,y0)
    %returns the square error of the periodic sigmoid for the input set of
    %parameters

    y=sigmoid_periodic2(params,x);
    out=y-y0;
    if max(y)>1  
        out=mean(out.^2);
        out=out+100*(max(y)-1);
    elseif min(y)<0
        out=mean(out.^2);
        out=out+100*abs(min(y));
    else
        out=mean(out.^2);
    end
%     out=mean(out.^2);
end
function il=inv_liklihood(params,data)
    y=sigmoid_periodic2(params,unique(data(:,1)));
    L=get_sigmoid_liklihood2(data,params,@sigmoid_periodic2);
    
%     if min(p)<0
%         il=1/L + 100*abs(min(p));
%     elseif max(p)>1
%         il=1/L + 1000*(max(p)-1);
%     else
%         il=1/L;
%     end
    if max(y)>1  
        il=1/L+100*(max(y)-1);
    elseif min(y)<0
        il=1/L+100*abs(min(y));
    else
        il=1/L;
    end
end
function il=bounded_inv_liklihood(params,data)
    L=get_sigmoid_liklihood2(data,params,@sigmoid_periodic2);
    il=1/L;
end
function [c,ceq]=constr(params)
    x=[0,2*pi];
    y=sigmoid_periodic2(params,x);
    c(1)=max(y)-1;%max<1
    c(2)=-min(y);%min<0
    ceq=[];
end