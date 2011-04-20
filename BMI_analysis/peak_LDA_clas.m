function [states,Coeffs] = peak_LDA_clas(spikes,bin_length,vel)

clear training_set;
clear group;

bin = double(bin_length); % convert bin to double for filtering
window = 0.500; % in seconds (for spike averaging)
cutoff = 5; % in Hz (for velocity low pass filtering)

window_bins = floor(window/bin); % calculate # of bins in window

speed = double(vel); % convert vel to double for filtering
[B,A] = butter(4,cutoff*bin/2,'low'); % low pass filter velocity
speed_filt = filtfilt(B,A,speed); % use filtfilt to prevent lag

observation = 0;
for x = window_bins:size(spikes,1)-1
    if (speed_filt(x-1) < speed_filt(x)) && (speed_filt(x) > speed_filt(x+1)) % local max
        observation = observation + 1;
        training_set(observation,:) = mean(spikes(x-3:x,:),1);
        group(observation) = 1; % movement
    elseif (speed_filt(x-1) > speed_filt(x)) && (speed_filt(x) < speed_filt(x+1)) % local min
        observation = observation + 1;
        training_set(observation,:) = mean(spikes(x-3:x,:),1);
        group(observation) = 0; % hold
    end
end

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