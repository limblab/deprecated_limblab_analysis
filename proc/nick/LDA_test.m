% have both 'bdf' and 'binnedData' loaded before running

classes = zeros(length(binnedData.timeframe),1);

[training, group] = build_LDA_training(bdf);

for x = 20:length(binnedData.timeframe)
    classes(x) = classify(binnedData.spikerate(x,:),training,group);
end

plot(binnedData.timeframe, binnedData.class, 'b', binnedData.timeframe, -classes, 'r')