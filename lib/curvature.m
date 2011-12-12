function k = curvature(varargin)
% CURVATURE - Returns the curvature of the curve given as input
%   K = CURVATURE(X, Y) gives the curvature K of the two dimensioal curve
%       given by X and Y.
%
%   K = CURVATURE(C) gives the curvature K of the two dimensional curve
%       given by C with each column representing one dimension.

if nargin == 1
    c = varargin{1};
    x = c(:,1);
    y = c(:,2);
elseif nargin == 2
    x = varargin{1};
    y = varargin{2};
else 
    error('Unexpected number of arguments');
end

dx = diff(x);
ddx = diff(dx);
dx = dx(2:end);

dy = diff(y);
ddy = diff(dy);
dy = dy(2:end);

k = (dx.*ddy + dy.*ddx) ./ (dx.^2+dy.^2).^(3/2);

