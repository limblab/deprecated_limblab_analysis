function L = spike_train_log_likelihood(s, lambda)
% SPIKE_TRAIN_LOG_LIKELIHOOD - the log likelihood of the spike train given
%                              firing rate lambda
%
%   L = SPIKE_TRAIN_LOG_LIKELIHOOD(S, LAMBDA) returns the log likelihood L
%   of the observed spike train given as a list of bins with spike counts S
%   given the predicted firing rate LAMBDA.  S and LAMBDA must be the same
%   length.

if size(s,1) ~= 1
    error('Spike train must be a vector');
end

if size(lambda,1) ~= 1
    error('Lambda must be a vector');
end

if size(s,2) ~= size(lambda,2)
    error('Lambda and S must be the same length');
end

L = sum(log(lambda(s ~= 0))) - sum(lambda);
