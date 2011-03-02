% Calculate classification coefficients from model data

clear peak_training_set
clear peak_group

window = 0.500; % in seconds (for spike averaging) should match training

bin = double(modelData.timeframe(2) - modelData.timeframe(1));
window_bins = floor(window/bin);

complete_training_set = zeros(length(modelData.timeframe),length(modelData.spikeguide)*window_bins);
observation = zeros(1,length(modelData.spikeguide)*window_bins);
group = zeros(length(complete_training_set),1);

for x = window_bins:length(modelData.timeframe)
    for y = 1:window_bins
        observation((y-1)*length(modelData.spikeguide)+1:y*length(modelData.spikeguide)) = modelData.spikeratedata(x-(y-1),:);
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

data_set = zeros(1,length(modelData.spikeguide)*window_bins);

for y = 1:window_bins
    data_set((y-1)*length(modelData.spikeguide)+1:y*length(modelData.spikeguide)) = modelData.spikeratedata(window_bins-(y-1),:);
end

mean_data_set = mean(modelData.spikeratedata(1:window_bins,:),1);

completeBayes = NaiveBayes.fit(complete_training_set(window_bins:end,:), group(window_bins:end));
% meanBayes = NaiveBayes.fit(mean_training_set(window_bins:end,:), group(window_bins:end));
peakBayes = NaiveBayes.fit(peak_training_set, peak_group);

% [~,~,~,~,completeLDAcoeffQ] = classify(data_set,complete_training_set(window_bins:end,:),group(window_bins:end),'quadratic');
% [~,~,~,~,meanLDAcoeffQ] = classify(mean_data_set,mean_training_set(window_bins:end,:),group(window_bins:end),'quadratic');
% [~,~,~,~,peakLDAcoeffQ] = classify(mean_data_set,peak_training_set,peak_group,'quadratic');

[~,~,~,~,completeLDAcoeffL] = classify(data_set,complete_training_set(window_bins:end,:),group(window_bins:end),'linear');
% [~,~,~,~,meanLDAcoeffL] = classify(mean_data_set,mean_training_set(window_bins:end,:),group(window_bins:end),'linear');
[~,~,~,~,peakLDAcoeffL] = classify(mean_data_set,peak_training_set,peak_group,'linear');

% Classify test data according to coefficients

states = zeros(length(testData.timeframe),5);

for x = window_bins:length(testData.timeframe)

    for y = 1:window_bins
        data_set((y-1)*length(testData.spikeguide)+1:y*length(testData.spikeguide)) = testData.spikeratedata(x-(y-1),:);
    end

    mean_data_set = mean(testData.spikeratedata(x-(window_bins-1):x,:),1);
    
    if testData.velocbin(x,3) > 8
        states(x,1) = 1;
    end

    states(x,2) = completeBayes.predict(data_set);

%     binnedData.states(x,3) = meanBayes.predict(mean_data_set);

    states(x,3) = peakBayes.predict(mean_data_set);

%     binnedData.states(x,5) = 0 >= data_set*completeLDAcoeffQ(1,2).quadratic*data_set' + data_set*completeLDAcoeffQ(1,2).linear + completeLDAcoeffQ(1,2).const;

%     binnedData.states(x,6) = 0 >= mean_data_set*meanLDAcoeffQ(1,2).quadratic*mean_data_set' + mean_data_set*meanLDAcoeffQ(1,2).linear + meanLDAcoeffQ(1,2).const;

%     binnedData.states(x,7) = 0 >= mean_data_set*peakLDAcoeffQ(1,2).quadratic*mean_data_set' + mean_data_set*peakLDAcoeffQ(1,2).linear + peakLDAcoeffQ(1,2).const;

    states(x,4) = 0 >= data_set*completeLDAcoeffL(1,2).linear + completeLDAcoeffL(1,2).const;

%     binnedData.states(x,9) = 0 >= mean_data_set*meanLDAcoeffL(1,2).linear + meanLDAcoeffL(1,2).const;

    states(x,5) = 0 >= mean_data_set*peakLDAcoeffL(1,2).linear + peakLDAcoeffL(1,2).const;

end


