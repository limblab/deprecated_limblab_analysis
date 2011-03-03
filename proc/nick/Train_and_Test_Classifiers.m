function [states, correct]=Train_and_Test_Classifiers(modelData, testData)
% Calculate classification coefficients from model data

window = 0.500; % in seconds (for spike averaging) should match training

bin = double(modelData.timeframe(2) - modelData.timeframe(1));
window_bins = floor(window/bin);

complete_training_set = zeros(length(modelData.timeframe),length(modelData.spikeguide)*window_bins);
group = zeros(length(complete_training_set),1);

for x = window_bins:length(modelData.timeframe)
observation = [];
    for y = 1:window_bins
        observation = [observation modelData.spikeratedata(x-(y-1),:)];
    end
    complete_training_set(x,:) = observation;

    if modelData.velocbin(x,3) > 8
        group(x) = 1;
    end
end

cutoff = 5; % in Hz (for velocity low pass filtering)

speed = double(modelData.velocbin(:,3));
[B,A] = butter(4,cutoff*bin/2,'low');
speed_filt = filtfilt(B,A,speed);

peak_training_set = [];
peak_group = [];
peak_count = 0;
for x = window_bins:length(modelData.timeframe)-1 % default
    if (speed_filt(x-1) < speed_filt(x)) && (speed_filt(x) > speed_filt(x+1)) % local max
        peak_count = peak_count + 1;
        peak_training_set(peak_count,:) = mean(modelData.spikeratedata(x-(window_bins-1):x,:),1);
        peak_group(peak_count) = 1; % movement
    elseif (speed_filt(x-1) > speed_filt(x)) && (speed_filt(x) < speed_filt(x+1)) % local min
        peak_count = peak_count + 1;
        peak_training_set(peak_count,:) = mean(modelData.spikeratedata(x-(window_bins-1):x,:),1);
        peak_group(peak_count) = 0; % hold
    end
end

data_set = [];
for y = 1:window_bins
    data_set = [data_set modelData.spikeratedata(window_bins-(y-1),:)];
end

mean_data_set = mean(modelData.spikeratedata(1:window_bins,:),1);

% completeBayes = NaiveBayes.fit(complete_training_set(window_bins:end,:), group(window_bins:end));
% peakBayes = NaiveBayes.fit(peak_training_set, peak_group);

[a,b,c,d,completeLDAcoeffL] = classify(data_set,complete_training_set(window_bins:end,:),group(window_bins:end),'linear');
[a,b,c,d,peakLDAcoeffL] = classify(mean_data_set,peak_training_set,peak_group,'linear');
clear a b c d;
% Classify test data according to coefficients

states = zeros(length(testData.timeframe),5);

for x = window_bins:length(testData.timeframe)

    data_set = [];
    for y = 1:window_bins
        data_set = [data_set testData.spikeratedata(x-(y-1),:)];
    end

    mean_data_set = mean(testData.spikeratedata(x-(window_bins-1):x,:),1);
    
    if testData.velocbin(x,3) > 8
        states(x,1) = 1;
    end

%     states(x,2) = completeBayes.predict(data_set);
% 
%     states(x,3) = peakBayes.predict(mean_data_set);

    states(x,4) = 0 >= data_set*completeLDAcoeffL(1,2).linear + completeLDAcoeffL(1,2).const;

    states(x,5) = 0 >= mean_data_set*peakLDAcoeffL(1,2).linear + peakLDAcoeffL(1,2).const;

end

correct = zeros(1,5);
for x = 1:5
    correct(x) = 1 - sum(abs(states(:,1) - states(:,x)))/length(states);
end

end
