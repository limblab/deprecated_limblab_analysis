function out = SmoothLP(in, dt, RC)
    %Low-pass filter with time constant RC
    %and time interval dt
    a = dt/(RC+dt);
    out(1,:) = in(1,:);
    for i=2:size(in,1)
        out(i,:)= out(i-1,:) + a*( in(i,:)-out(i-1,:) );
    end
end