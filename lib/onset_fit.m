function out = onset_fit( curve )
%ONSET_FIT returns a description of the fit to curve
%   OUT = ONSET_FIT( CURVE )
%
%   ONSET_FIT fits a curve (flat then parabolic).  The point at which the
%   fit transitions from flat to parabolic is defined as the onset.
%
%   OUT contains:
%       1) transition point
%       2) value for flat section
%       3) scale for parabolic section

% $Id$

x = 1:20;
y = [5*ones(1,10) .3*x(1:10).^2+5];
F = @(x,xdata) (xdata<x(1)).*x(2) + (xdata>=x(1)).*(x(3)*(xdata-x(1)).^2+x(2));
out = lsqcurvefit(F,x0,x,y);
plot(x, y, 'ko', x, F(out,x), 'r-')

