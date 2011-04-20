function [states,Coeffs] = perf_LDA_clas(spikes,bin_length,vel)

bin = double(bin_length); % convert bin to double for filtering
window = 0.50; % in seconds (for spike averaging)

window_bins = floor(window/bin); % calculate # of bins in window

training_set = zeros(size(spikes,1)-(window_bins-1),size(spikes,2)); % initialize training set
for x = window_bins:size(spikes,1)
    training_set(x,:) = mean(spikes(x-(window_bins-1):x,:),1); % build training set
end

group = vel >= 8; % classify groups according to velocities

[~,~,~,~,coeff0] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.7 0.3]); % calculate coefficients for posture state

[~,~,~,~,coeff1] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.6 0.4]); % calculate coefficients for movement state

Coeffs = {coeff0(1,2),coeff1(1,2)};

states = zeros(size(spikes,1),1); % initialize states

for x = window_bins:size(spikes,1)
    if states(x-1) == 0
        states(x) = 0 >= mean(spikes(x-(window_bins-1):x,:),1)*coeff0(1,2).linear + coeff0(1,2).const; % predict states following posture state
    else
        states(x) = 0 >= mean(spikes(x-(window_bins-1):x,:),1)*coeff1(1,2).linear + coeff1(1,2).const; % predict states following movement state
    end
end