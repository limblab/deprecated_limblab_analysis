training_set = zeros(length(binnedData.timeframe)-3,length(binnedData.spikeguide));
group = zeros(length(training_set),1);

for x = 4:length(binnedData.timeframe)
    training_set(x,:) = mean(binnedData.spikeratedata(x-3:x,:),1);
    group(x) = binnedData.states(x,1);
end

% o1 = NaiveBayes.fit(training_set(:,1:69), group); % for Keedoo 12/14
o1 = NaiveBayes.fit(training_set, group);

classes = zeros(length(binnedData.timeframe),1);

for x = 4:length(binnedData.timeframe)
%     classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,1:69),1)); % for Keedoo 12/14
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,:),1));
end

plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3), 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

priors = o1.Prior

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)