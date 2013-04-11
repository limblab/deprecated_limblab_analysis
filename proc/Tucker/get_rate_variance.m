function [rate rate_var]=get_rate_variance(n_obs,N)
    %returns the rate of a single observation occurrance as well as the 
    %variance of the rate estimate when given the number of
    %observations and how many observations resulted in the desired outcome
    rate=N/n_obs; %estimator of the probability of the desired event
    rate_var=rate*(1-rate)/n_obs; %estimate of the variance in the rate estimates
end