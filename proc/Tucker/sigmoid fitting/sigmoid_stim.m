function [y]=sigmoid_stim(params,x)
    %returns the y values of x,y pairs for a sigmoidal function of x.
    %takes in the: minimum value the output may have, the maximum value the
    %output may have, the value of x, for which the output will be halfway
    %between the minimum and maximum, and the time-constant defining the
    %steepness of the sigmoid.
    
    angle=x(:,1);
    stim=x(:,2);
    

    
    minimum=params(1);
    stim_min=params(2);
    maximum=params(3);
    stim_max=params(4);
    center=params(5);
    stim_center=params(6);
    steepness=params(7);
    stim_steepness=params(8);
    
    
    minval=minimum+stim.*stim_min;
    maxval=maximum+stim.*stim_max;
    
    %y=minval+(maxval-minval)./(1+exp(-(stim_steepness.*angle.*stim  +   steepness*angle     -   stim_center*stim     -   center)));
    
    y=minval+(maxval-minval)./(1+exp( -(    (steepness + stim_steepness.*stim)  .*  (angle - stim_center.*stim - center)) ));
    
      
end