function [states,Coeffs] = perf_LDA_clas(spikes,bin_length,vel,vel_thresh)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

observations = DuplicateAndShift(spikes,window_bins); % build training set
group = vel > vel_thresh; % assign training classes

[~,~,~,~,coeff0] = classify(observations(1,:),observations,group,'linear',[0.7 0.3]); % calculate coefficients for posture state
[~,~,~,~,coeff1] = classify(observations(1,:),observations,group,'linear',[0.3 0.7]); % calculate coefficients for movement state

Coeffs = {coeff0(1,2),coeff1(1,2)};

states = zeros(size(spikes,1),1); % initialize states

for x = 2:size(observations,1)
    if states(x-1) == 0
        states(x) = 0 >= observations(x,:)*coeff0(1,2).linear + coeff0(1,2).const; % predict states following posture state
    else
        states(x) = 0 >= observations(x,:)*coeff1(1,2).linear + coeff1(1,2).const; % predict states following movement state
    end
end