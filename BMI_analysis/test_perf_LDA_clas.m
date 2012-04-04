function states = test_perf_LDA_clas(spikes,bin_length,classifier)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    observation = [];
    for y = 1:size(spikes,2)
        observation = [observation spikes(x-(window_bins-1):x,y)']; % concat spikes to create observation (n1,1 n1,2... n1,bins n2,1 n2,2... nlast,bins)
    end
    if states(x-1) == 0
        states(x) = 0 >= observation*classifier{1}.linear + classifier{1}.const; % predict states following posture state
    else
        states(x) = 0 >= observation*classifier{2}.linear + classifier{2}.const; % predict states following movement state
    end
end