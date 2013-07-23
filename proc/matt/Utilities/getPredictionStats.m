function [VAF, R2, MSE] = getPredictionStats(preds,real)
% GETPREDICTIONSTATS returns performance metrics for decoder predictions.
%
% INPUTS:
%   preds: predicted data
%   real: observed data
%
% OUTPUTS:
%   VAF: variance accounted for
%   R2: R2 of prediction
%   MSE: mean squared error
%
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

% Compute VAF and R2
VAF = 1 - var(preds - real,0,1)./var(real,0,1);

R2 = zeros(1,size(real,2));
for i = 1:size(real,2)
    R2(i) = 1-sum((preds(:,i)-real(:,i)).^2,1)./sum((preds(:,i) - mean(real(:,i))).^2);
end

MSE = mean((preds-real).^2,1);

end