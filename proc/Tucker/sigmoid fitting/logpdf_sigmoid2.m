function logpdf=logpdf_sigmoid2(data,params)
    %returns the log likelihood of a sigmoid

    %pdf=logpdf_sigmoid(data,min_val,max_val,ctr_point,steepness)
    %data should be a column matrix of format [angle; stim; observation]
    %where angle is the angle of the bump relative to the PD in degrees,
    %stim is a 0 or 1 value indicating whether the trial was a stim trial
    %or not, and observation is a 0 or 1 value indicating whether whether
    %the result was a reach to the secondary target.
    
    %NOTE: THIS FUNCTION INTENTIALLY OMITS A CONSTANT TERM. THE RESULT WILL
    %SCALE LINEARLY WITH THE ACTUAL LOGPDF, BUT WILL NOT HAVE THE SAME
    %VALUE.
    
   
    tmp=sort(unique(data(:,1)));
    angles=tmp(tmp<180  &  15<tmp);
    
    N_tot=zeros(length(angles),1);
    N_primary=zeros(length(angles),1);
    p=zeros(length(angles),1);
    %find the probability of reaches to the primary and secondary targets
    %as a function of the reach angle (get the height of the sigmoid at
    %each angle)
    p_primary=sigmoid(params,angles);
    
    for i=1:length(angles)
        N_tot(i)=sum(data(:,1)==angles(i));%trials at the current angle
        N_primary(i)=sum(data(:,1)==angles(i) & data(:,2)==1);%trials at the current angle and to the primary target
        p(i)=binopdf(N_primary(i),N_tot(i),p_primary(i));
        %compose the log pdf for each angle-stim condition. 
   end
    %add u
    %add up all the individual logpdf values to get the log pdf for the
    %whole curve

    logpdf=-2*sum(log(p));
%     pdf=sum(sum(log_p));

end