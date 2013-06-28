function [WdotX] = perf_LDA_WdotX(spikes,bin_length,linear_class)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

training_set = zeros(size(spikes,1),size(spikes,2)*window_bins); % initialize training set

for x = window_bins:size(training_set,1)
    observation = [];
    for y = 1:size(spikes,2)
        observation = [observation spikes(x-(window_bins-1):x,y)']; % concat spikes to create observation (n1,1 n1,2... n1,bins n2,1 n2,2... nlast,bins)
    end
    training_set(x,:) = observation; % build training set from observations
end

WdotX = training_set*linear_class; % calc W dot X