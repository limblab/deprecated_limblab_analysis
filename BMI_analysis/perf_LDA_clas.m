function [states,Coeffs] = perf_LDA_clas(spikes,bin_length,vel,vel_thresh)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

training_set = zeros(size(spikes,1),size(spikes,2)*window_bins); % initialize training set
group = zeros(size(training_set,1),1); % initialize training classes

for x = window_bins:size(training_set,1)
    observation = [];
    for y = 1:size(spikes,2)
        observation = [observation spikes(x-(window_bins-1):x,y)']; % concat spikes to create observation (n1,1 n1,2... n1,bins n2,1 n2,2... nlast,bins)
    end
    training_set(x,:) = observation; % build training set from observations
    group(x) = vel(x) > vel_thresh; % assign training classes according to ground truth
end

[~,~,~,~,coeff0] = classify(observation,training_set(window_bins:end,:),group(window_bins:end),'linear',[0.7 0.3]); % calculate coefficients for posture state

[~,~,~,~,coeff1] = classify(observation,training_set(window_bins:end,:),group(window_bins:end),'linear',[0.6 0.4]); % calculate coefficients for movement state

Coeffs = {coeff0(1,2),coeff1(1,2)};

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    observation = [];
    for y = 1:size(spikes,2)
        observation = [observation spikes(x-(window_bins-1):x,y)']; % concat spikes to create observation (n1,1 n1,2... n1,bins n2,1 n2,2... nlast,bins)
    end
    if states(x-1) == 0
        states(x) = 0 >= observation*coeff0(1,2).linear + coeff0(1,2).const; % predict states following posture state
    else
        states(x) = 0 >= observation*coeff1(1,2).linear + coeff1(1,2).const; % predict states following movement state
    end
end