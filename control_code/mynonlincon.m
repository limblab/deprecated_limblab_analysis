function [c,ceq] = mynonlincon(x,sigParams,fdes,nmusc,xmin)

% Evaluate Fx and Fy sigmoids at current activation
f = zeros(nmusc,2); 
for i = 1:nmusc
    % If amps go below minimum, clamp to zero and set forces to zero
    if x(i) < xmin(i)
        x(i) = 0;
        f(i,1) = 0; f(i,2) = 0;
    else
        % Fx
       f(i,1) = eval_sigmoid_MLE(sigParams(1:4,i),x(i));
       % Fy
       f(i,2) = eval_sigmoid_MLE(sigParams(5:8,i),x(i));
    end
end

% Sum Fx and Fy across all muscles
sumF = sum(f);

% Constrain resultant force to be equal to desired force
error = sumF-fdes;

% Define nonlinear constraints in easy to interpret format
c = 0 ;        % Compute nonlinear inequalities at x.
ceq = error;   % Compute nonlinear equalities at x.