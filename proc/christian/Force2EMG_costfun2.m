function [cost_out, cost_grad] = Force2EMG_costfun2(EMG, F, w, lambda)
    % EMG is predicted EMG
    % F is expected force
    % w are the EMG-to-Force vectors (MxN), M = num_muscle, N = num_force
    % lambda is the regularization factor to minimize predicted EMG.

    Fpred  = sigmoid(EMG,'direct')*w;
    dFpred = sigmoid(EMG,'derivative')*diag(w);
    
    dFpred(isnan(dFpred)) = 0;
    
    cost_out  =  sum( (F-Fpred).*(F-Fpred)  + ... %minimize Fpred error
                       lambda*sum(EMG.^2,2) ); %minimize overal EMG preds)
    
    cost_grad = (-2*dFpred'*diag(F-Fpred))' + 2*lambda*EMG;
    
%     sig = sigmoid(EMG,'direct');
%     dsig= sigmoid(EMG,'derivative');
% 
%     cost_out =  (F-sig*w)'*(F-sig*w) ... %minimize Fpred error
%                     + lambda*norm(EMG)^2; %minimize overal EMGs pred 
%                 
%     cost_grad = -2*w'.*dsig.*(F-sig*w) + 2*lambda*EMG; %cost gradient

end