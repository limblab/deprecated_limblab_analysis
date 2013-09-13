function [x, y] = resampleTraces(x,y,n)
% Put all of the data in a consistent time scale
% x: x data, y: y data, n: # resampling points

x = resample(double(x),n,length(x),5);
y = resample(double(y),n,length(y),5);

% trim last point?
x = x(10:end-10);
y = y(10:end-10);

end