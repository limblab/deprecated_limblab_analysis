% have both 'bdf' and 'binnedData' loaded before running

classes = zeros(length(binnedData.timeframe),1);

[training, group] = build_LDA_training2(bdf);

% grouping = [1:25]';

% priors = [1/3 1/24 1/24 1/24 1/24 1/24 1/24 1/24 1/24 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48 1/48];
priors = [0.85 0.15]';


for x = 4:length(binnedData.timeframe)
    classes(x) = classify(mean(binnedData.spikeratedata(x-3:x,1:69),1),training(:,1:69),group,'quadratic',priors);
%     classes(x) = classify(mean(binnedData.spikeratedata(x-3:x,1:69),1),training(:,1:69),grouping);
%     if classes(x) <= 9
%         classes(x) = 0;
%     else
%         classes(x) = 1;
%     end
end

plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/30, 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)