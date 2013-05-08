function [y]=sigmoid(params,x)
    %returns the y values of x,y pairs for a sigmoidal function of x.
    %takes in the: minimum value the output may have, the maximum value the
    %output may have, the value of x, for which the output will be halfway
    %between the minimum and maximum, and the time-constant defining the
    %steepness of the sigmoid.
    minimum=params(1);
    maximum=params(2);
    center=params(3);
    steepness=params(4);
    y=minimum+(maximum-minimum)./(1+exp(-steepness*(x-center)));
end