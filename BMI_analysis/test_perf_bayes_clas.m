function states = test_perf_bayes_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    observation = [];
    for y = 1:size(spikes,2)
        observation = [observation spikes(x-(window_bins-1):x,y)']; % concat spikes to create observation (n1,1 n1,2... n1,bins n2,1 n2,2... nlast,bins)
    end
    states(x) = classifier.predict(observation); % predict states
end
