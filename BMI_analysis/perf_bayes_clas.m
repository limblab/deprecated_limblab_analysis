function [states,o1] = perf_bayes_clas(spikes,bin_length,vel,vel_thresh)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

observations = DuplicateAndShift(spikes,window_bins); % build training set
group = vel > vel_thresh; % assign training classes

o1 = NaiveBayes.fit(observations, group); % create predictor

states = zeros(size(spikes,1),1); % initialize states

for x = 1:size(observations,1)
    states(x) = o1.predict(observations(x,:)); % predict states
end