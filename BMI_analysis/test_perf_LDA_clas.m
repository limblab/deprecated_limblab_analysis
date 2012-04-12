function states = test_perf_LDA_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

observations = DuplicateAndShift(spikes,window_bins); % build training set
states = zeros(size(spikes,1),1); % initialize states

for x = 2:size(observations,1)
    if states(x-1) == 0
        states(x) = 0 >= observations(x,:)*classifier{1}.linear + classifier{1}.const; % predict states following posture state
    else
        states(x) = 0 >= observations(x,:)*classifier{2}.linear + classifier{2}.const; % predict states following movement state
    end
end