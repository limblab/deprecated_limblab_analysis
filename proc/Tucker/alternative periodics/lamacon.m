function r=lamacon(params,theta)
    %computes the Lamacon function r=b+acos(theta)
    r=params(2)+params(1)*cos(theta);
end