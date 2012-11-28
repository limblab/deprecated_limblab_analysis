function tstart=get_start_time(t,vx,vy,t_lowlim,t_highlim)
    %returns the start of a movement segment. inputs are the time vector,
    %the velocity in x and y at the time points in the time vector. and the
    %lower and upper time bounds to search within
    
    %could be improved by only working on the data between t_lowlim and
    %t_highlim
    
    %compute the instantaneous movement speed
    speed=sqrt(vx^2+vy^2);
    %set the speed outside the time range of interest to 0 so we ignore it
    %later
    speed(t<t_lowlim | t>t_highlim)=0;
    %find the peak speed between the timelimits
    [s_max,i_max]=max(speed);
    %find the first minima prior to the max speed where the velocity is
    %less than 10% of the peak speed
    
    tstart=find(speed(1:i_max)<0.1*s_max,'last');
end