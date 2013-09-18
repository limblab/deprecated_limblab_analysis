function [x, y] = resampleTraces(x,y,n,trimPoints)
% Put all of the data in a consistent time scale
% x: x data, y: y data, n: # resampling points

if nargin < 4
    trimPoints = 10;
end

x = resample(double(x),n,length(x),5);
y = resample(double(y),n,length(y),5);

% trim last point?
x = x(trimPoints:end-trimPoints);
y = y(trimPoints:end-trimPoints);

end