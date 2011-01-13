clear training_set;
clear group;

bin = double(binnedData.timeframe(2) - binnedData.timeframe(1));

speed = double(binnedData.velocbin(:,3));

cutoff = 5; % in Hz

[B,A] = butter(4,cutoff*bin/2,'low');
speed_filt = filtfilt(B,A,speed);

figure
plot(binnedData.timeframe, speed, 'b', binnedData.timeframe, speed_filt, 'r')
axis([0 max(binnedData.timeframe) min(speed_filt) max(speed)])

observation = 0;
for x = 4:length(binnedData.timeframe)-1
    if (speed_filt(x-1) < speed_filt(x)) && (speed_filt(x) > speed_filt(x+1)) % local max
        observation = observation + 1;
        training_set(observation,:) = mean(binnedData.spikeratedata(x-3:x,:),1);
        group(observation) = 1; % movement
    elseif (speed_filt(x-1) > speed_filt(x)) && (speed_filt(x) < speed_filt(x+1)) % local min
        observation = observation + 1;
        training_set(observation,:) = mean(binnedData.spikeratedata(x-3:x,:),1);
        group(observation) = 0; % hold
    end
end

% o1 = NaiveBayes.fit(training_set(:,1:69), group); % for Keedoo 12/14
o1 = NaiveBayes.fit(training_set, group);

classes = zeros(length(binnedData.timeframe),1);

for x = 4:length(binnedData.timeframe)
%     classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,1:69),1)); % for Keedoo 12/14
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,:),1));
end

figure
plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3), 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)