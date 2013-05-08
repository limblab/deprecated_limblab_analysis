function pdf=logpdf_sigmoid_fit(data,mask,params)
    %returns the log probability distribution function of a sigmoid

    %pdf=logpdf_sigmoid(data,min_val,max_val,ctr_point,steepness)
    %data should be a column matrix of format [angle; stim; observation]
    %where angle is the angle of the bump relative to the PD in degrees,
    %stim is a 0 or 1 value indicating whether the trial was a stim trial
    %or not, and observation is a 0 or 1 value indicating whether whether
    %the result was a reach to the secondary target.
    
    %NOTE: THIS FUNCTION INTENTIALLY alters the liklihood reported to bias
    %fitting functions away from certain parameter ranges. For unbiased
    %results the correct function is logpdf_sigmoid
    
    
   
    tmp=sort(unique(data(:,1)));
    angles=tmp(tmp<180  &  15<tmp);
    params=params.*mask;
    
    N_tot=zeros(length(angles),1);
    N_primary=zeros(length(angles),1);
    R_primary=N_primary;
    N_tot_stim=zeros(length(angles),1);
    N_primary_stim=zeros(length(angles),1);
    R_primary_stim=N_primary_stim;

    log_p=zeros(length(angles),2);
    
%     model=sigmoid_stim([min_val,min_val_stim,max_val,max_val_stim,ctr_point,ctr_point_stim,steepness,steepness_stim],[angles, zeros(length(angles),1)]);
%     model_stim=sigmoid_stim([min_val,min_val_stim,max_val,max_val_stim,ctr_point,ctr_point_stim,steepness,steepness_stim],[angles, ones(length(angles),1)]);
%     
    model=sigmoid_stim(params,[angles, zeros(length(angles),1)]);
    model_stim=sigmoid_stim(params,[angles, ones(length(angles),1)]);
    
    for i=1:length(angles)
        N_tot(i)=sum(data(:,1)==angles(i) & data(:,2)==0);%trials at the current angle with no stim
        N_tot_stim(i)=sum(data(:,1)==angles(i) & data(:,2)==1);%trials at the current angle with stim
        N_primary(i)=sum(data(:,1)==angles(i) & data(:,2)==0 & data(:,3)==1);%trials at the current angle with no stim and to the primary target
        N_primary_stim(i)=sum(data(:,1)==angles(i) & data(:,2)==1 & data(:,3)==1);%trials at the current angle with stim and to the primary target
        R_primary(i)=N_primary(i)/N_tot(i);
        R_primary_stim(i)=N_primary_stim(i)/N_tot_stim(i);
        %compose the log pdf for each angle-stim condition. 
        log_p(i,1)=    -N_primary(i)        *log(model(i))          -   (   N_tot(i)        -   N_primary(i)        )   *   log(1-model(i)      );
        log_p(i,2)=    -N_primary_stim(i)   *log(model_stim(i))     -   (   N_tot_stim(i)   -   N_primary_stim(i)   )   *   log(1-model_stim(i) );
        const(i,1)=     -log(nchoosek( N_tot(i)      , N_primary(i)      ));
        const(i,2)=     -log(nchoosek( N_tot_stim(i) , N_primary_stim(i) ));
        
    end
    %add u
    %add up all the individual logpdf values to get the log pdf for the
    %whole curve
%      log_p
%      const
    pdf=(sum(sum(log_p))+sum(sum(const)));
%     pdf=sum(sum(log_p));
    
%     
%         min_val=params(1);
%     min_val_stim=params(2);
%     max_val=params(3);
%     max_val_stim=params(4);
%     ctr_point=params(5);
%     ctr_point_stim=params(6);
%     steepness=params(7);
%     steepness_stim=params(8);
%     
   if (params(1)>1 | (params(1)+params(2))>1 | params(3)<0 | (params(3)+params(4))<0)
   %if (min_val>1 | max_val<0)
        pdf=pdf+10000000;
    end

end