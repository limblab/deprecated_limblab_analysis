function roundedTime=roundTime(timeData)
    %takes in a time vector and returns a vector with superfluous precision
    %rounded out. Passing timeData=[0.0011,0.0111,0.0211,0.0311...] would
    %result in roundedTime=[0.0000,0.0100,0.0200,0.0300...]. roundTime uses
    %the difference between sample points to identify the appropriate
    %resolution to round time to.
    
    n=0;
    dt=mode(diff(timeData));
    while round(dt*10^n)<1;
        n=n+1;
    end
    roundedTime=round(timeData*10^n)/10^n;
end