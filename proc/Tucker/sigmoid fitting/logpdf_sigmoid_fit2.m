function pdf=logpdf_sigmoid_fit2(data,params)
    %returns the log probability distribution function of a sigmoid

    %pdf=logpdf_sigmoid(data,[min_val,max_val,ctr_point,steepness])
    %data should be a column matrix of format [angle; stim; observation]
    %where angle is the angle of the bump relative to the PD in degrees,
    %and observation is a 0 or 1 value indicating whether whether the result
    %was a reach to the secondary target.
        
    %NOTE: THIS FUNCTION INTENTIALLY alters the liklihood reported to bias
    %fitting functions away from certain parameter ranges. For unbiased
    %results the correct function is logpdf_sigmoid2

    pdf=logpdf_sigmoid2(data,params);
%     pdf=sum(sum(log_p));

    %penalize for allowing the sigmoid to take a value above 1 or below 0
%  if (min_val<0    | (min_val+max_val)>1       |  max_val<0)
   if (params(1)<0)
       pdf=pdf+1000+1000000*abs(params(1));
   end
   if (params(1)+params(2))>1   
       pdf=pdf+10000*(params(1)+params(2));
   end
   if  params(2)<0
       pdf=pdf+1000+1000000*abs(params(2));
   end
   %penalize for allowing the center of the sigmoid to go out of the range
   %of the data:
%    if params(3)>max(data(:,1))
%        pdf=pdf+1000+100000*abs(params(3)-max(data(:,1)));
%    end
%    if params(3)<min(data(:,1))
%        pdf=pdf+1000+100000*abs(params(3)-min(data(:,1)));
%    end
   
end