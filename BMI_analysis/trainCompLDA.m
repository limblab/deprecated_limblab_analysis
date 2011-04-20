function [posture_classifier,movement_classifier] = trainCompLDA(spikes,binsize)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/binsize); % calculate # of bins in window

training_set = zeros(size(spikes,1)-(window_bins-1),size(spikes,2)); % initialize training set
for x = window_bins:size(spikes,1)
    training_set(x,:) = mean(spikes(x-(window_bins-1):x,:),1); % build training set
end

group = vel >= 8; % classify groups according to velocities

[~,~,~,~,posture_classifier] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.7 0.3]); % calculate coefficients for posture state

[~,~,~,~,movement_classifier] = classify(mean(spikes(1:window_bins,:),1),training_set,group,'linear',[0.6 0.4]); % calculate coefficients for movement state

posture_classifier = posture_classifier(1,2);
movement_classifier=movement_classifier(1,2); 

end