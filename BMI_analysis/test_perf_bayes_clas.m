function states = test_perf_bayes_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

observations = DuplicateAndShift(spikes,window_bins); % build training set

states = zeros(size(spikes,1),1); % initialize states

for x = 1:size(observations,1)
    states(x) = classifier.predict(observations(x,:)); % predict states
end