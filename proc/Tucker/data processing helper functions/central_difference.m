function dx=central_difference(x,varargin)
    %returns the central difference estimation for the derivative of x. If
    %a timeseries t is given, then the results will be scaled for the time
    %windows. This function does not compensate for irregular sampling
    %windows, so non-uniform time series will increase error in the
    %resulting estimate of the derivative. x must be a column matrix and t
    %must be a column vector
    %
    %Written by Tucker Tomlinson Jan-8-2015
    
    t=[];
    if length(varargin)>1
        t=varargin{1};
    end
        
    x1=[x(1,:);x(1,:);x];
    x2=[x;x(end,:);x(end,:)];
    dx=(x2-x1)/2;
    if ~isempty(t);
        t1=[t(1,:);t(1,:);t];
        t2=[t;t(end,:);t(end,:)];
        dt=(t2-t1)/2;
        dx=dx./dt;
    end
    dx=dx(2:end-1,:);
end