% with training_set and group already created and binnedData already loaded

window = 0.200; % in seconds (for spike averaging) should match training
priors = [0.66 0.34]; % for default set to [0.5 0.5]

bin = double(binnedData.timeframe(2) - binnedData.timeframe(1));
window_bins = floor(window/bin);

classes = zeros(length(binnedData.timeframe),1);

for x = window_bins:length(binnedData.timeframe)
    classes(x) = classify(mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1),training_set,group); % default (no priors)
%     classes(x) = classify(mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1),training_set,group,'linear',priors);
end

figure
plot(binnedData.timeframe, classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
axis([0 max(binnedData.timeframe) -1 2])
title('Predicted classification');
legend('predicted classes', 'normalized velocity');
xlabel('time (s)');
ylabel('state 1 = movement, state 0 = hold');

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes);

figure
plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
axis([0 max(binnedData.timeframe) -2 2])
title(['Classification accuracy = ', num2str(correct,3)]);
legend('movement classes', 'predicted classes', 'normalized velocity');
xlabel('time (s)');
ylabel('state (+/-)1 = movement, state 0 = hold');

% figure
% plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
% axis([0 max(binnedData.timeframe) -1 2]);
% title('Classification errors');
% xlabel('time (s)');
% ylabel('1 = error, 0 = correct');
