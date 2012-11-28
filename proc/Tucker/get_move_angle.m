function net_move_angle=get_move_angle(t,x,y,t_1,t_2)
    %returns the movement direction from the x,y position at time t_1, to
    %the x,y position at t_2. t is the vector of timestamps for the x and y
    %positions.
    
    %the angle is returned in degrees
    
    %find the x,y position at time t_1
    t_1=find(t>t_1,'first');
    t_2=find(t>t_2,'first');
    
    x_1=x(t_1);
    y_1=y(t_1);
    %find the x,y position at time t_2
    x_2=x(t_2);
    y_2=y(t_2);
    
    %get the angle from p_1 to p_2
    %acos(dx/sqrt(dx^2+dy^2))
    net_move_angle=acos((x_2-x_1)/sqrt((x_2-x_1)^2+(y_2-y_1)^2))*180/PI;
end