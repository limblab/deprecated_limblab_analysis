function [y]=sigmoid_periodic2(params,x)
    %returns the y values of x,y pairs for a sigmoidal function of x.
    %takes in the: minimum value the output may have, the maximum value the
    %output may have, the value of x, for which the output will be halfway
    %between the minimum and maximum, and the time-constant defining the
    %steepness of the sigmoid.
    offset=params(1);
    amplitude=params(2);
    center=params(3);
    steepness=params(4);
    P1=params(5);
    y=offset+amplitude./(1+exp(-steepness*(P1+cos(x-center))));
end