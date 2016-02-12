function states = test_peak_LDA_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    if states(x-1) == 0
        states(x) = 0 >= mean(spikes(x-(window_bins-1):x,:),1)*classifier{1}.linear + classifier{1}.const; % predict states following posture state
    else
        states(x) = 0 >= mean(spikes(x-(window_bins-1):x,:),1)*classifier{2}.linear + classifier{2}.const; % predict states following movement state
    end
end