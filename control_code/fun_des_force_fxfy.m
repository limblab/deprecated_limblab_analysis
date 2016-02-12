function f = fun_des_force_fxfy(x,sigParams,fdes,nmusc,xmin,c)

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
fhat = sum(f);

% Cost function
R = c(1)*eye(length(x));
Q = eye(2)*c(2);
f = x'*R*x + (fhat-fdes)*Q*(fhat-fdes)';

% % Constrain resultant force to be equal to desired force
% errorF = sumF-fdes;
% 
% % Cost function
% cost = sum(x.^2) + 100000*sum(errorF);

