% with training_set and group already created and binnedData already loaded

priors = [0.66 0.34]; % for default set to [0.5 0.5]

classes = zeros(length(binnedData.timeframe),1);

for x = 4:length(binnedData.timeframe)
    classes(x) = classify(mean(binnedData.spikeratedata(x-3:x,:),1),training_set,group);
%     classes(x) = classify(mean(binnedData.spikeratedata(x-3:x,:),1),training_set,group,'linear',priors);
end

figure
plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)