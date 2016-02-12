function f = find_forces_fxfy(x,sigParams,xmin)

% If amps go below minimum, clamp to zero and set forces to zero
if x < xmin
    f(1) = 0; 
else
    % Fx
   f(1) = eval_sigmoid_MLE(sigParams,x);
end