function [posture_classifier,movement_classifier] = trainPeakLDA(spikes,binsize,vel)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/double(binsize)); % calculate # of bins in window
cutoff = 5; % in Hz (for velocity low pass filtering)
vel = double(vel);

[B,A] = butter(4,cutoff*bin/2,'low'); % low pass filter velocity
vel = filtfilt(B,A,vel); % use filtfilt to prevent lag

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

[~,~,~,~,posture_classifier] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.7 0.3]); % calculate coefficients for posture state

[~,~,~,~,movement_classifier] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.6 0.4]); % calculate coefficients for movement state

posture_classifier = posture_classifier(1,2);
movement_classifier=movement_classifier(1,2); 

end