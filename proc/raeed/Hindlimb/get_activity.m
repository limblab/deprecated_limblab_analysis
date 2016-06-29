function [activity,avg_act] = get_activity(neurons, scaled_lengths, num_sec)
% Calculate activity of neurons according to scaled muscle lengths
%   NEURONS - num_neurons x num_muscles array of neural weights
%   SCALED_LENGTHS - num_positions x num_muscles array of muscle lengths
%   scaled between 0 and 1
%   ACTIVITY - Poisson noise neural activity (num_neurons x num_positions)
%   AVG_ACT - mean of noisy neural activity (num_neurons x num_positions)

% num_sec = 3*8;

% calculate average firing rate (Imp/sec)
avg_act = 60./(1+exp(-neurons*scaled_lengths'));

% run for num_sec seconds and then calculate average
activity = poissrnd(num_sec*avg_act)/num_sec;

end