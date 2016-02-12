function states = test_peak_bayes_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    states(x) = classifier.predict(mean(spikes(x-(window_bins-1):x,:),1)); % predict states
end
