function states = perf_bayes_clas(spikes,bin_length,vel)

bin = double(bin_length); % convert bin to double for filtering
window = 0.200; % in seconds (for spike averaging)

window_bins = floor(window/bin); % calculate # of bins in window

training_set = zeros(size(spikes,1)-(window_bins-1),size(spikes,2)); % initialize training set
for x = window_bins:size(spikes,1)
    training_set(x,:) = mean(spikes(x-(window_bins-1):x,:),1); % build training set
end

group = vel >= std(vel); % classify groups according to velocities

o1 = NaiveBayes.fit(training_set, group); % create predictor

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    states(x) = o1.predict(mean(spikes(x-(window_bins-1):x,:),1)); % predict states
end
