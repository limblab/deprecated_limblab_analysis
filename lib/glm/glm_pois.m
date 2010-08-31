function b = glm_pois(x, y)
% Fits a GLM with a pois distribution and exponential link function to x
% and y

% $Id: $

warning('You should probably be using glmfit instead of this file');

% Check parameters
if size(y,2) > size(y,1)
    y = y';
end

if size(y,2) ~= 1
    error('Y must be a column vector');
end

if size(y,1) ~= size(x,1)
    error('X and Y must be the same length');
end

% Setup options
options = optimset();
options = optimset(options, 'GradObj','on');
options = optimset(options, 'MaxFunEvals', 1E6);
options = optimset(options, 'MaxIter', 1E4);
options = optimset(options, 'Display', 'iter');
options = optimset(options, 'TolFun', 1E-20);

% Run optimization
f = @(a) glm_pois_cost(a, x, y);
x0 = .01*randn(size(x,2),1);

b = fminunc(f, x0, options);
%b = fminsearch(f, x0, options);
