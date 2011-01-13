% with o1 NaiveBayes already created and binnedData loaded

classes = zeros(length(binnedData.timeframe),1);

for x = 4:length(binnedData.timeframe)
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,:),1));
end

figure
plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3), 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)