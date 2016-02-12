window = 0.200; % in seconds (for spike averaging) should match training

bin = double(binnedData.timeframe(2) - binnedData.timeframe(1));
window_bins = floor(window/bin);

training_set = zeros(length(binnedData.timeframe)-(window_bins-1),length(binnedData.spikeguide));
group = zeros(length(training_set),1);


for x = window_bins:length(binnedData.timeframe)
    training_set(x,:) = mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1);
    group(x) = binnedData.states(x,1);
end

o1 = NaiveBayes.fit(training_set, group); % default
% o1 = NaiveBayes.fit(training_set(:,1:69), group); % for Keedoo 12/14

classes = zeros(length(binnedData.timeframe),1);

for x = window_bins:length(binnedData.timeframe)
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)); % default
%     classes(x) = o1.predict(mean(binnedData.spikeratedata(x-(window_bins-1):x,1:69),1)); % for Keedoo 12/14
end

figure
plot(binnedData.timeframe, classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
axis([0 max(binnedData.timeframe) -1 2])
title(['Predicted classification, priors [hold movement] = [', num2str(o1.Prior,3), ']']);
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

incorrect = sum(abs(binnedData.states(:,1) - classes(:,1)));
false_hold = (sum(binnedData.states(:,1) - classes(:,1)) + incorrect) / 2;
false_move = incorrect - false_hold;
true_hold = length(binnedData.states) - sum(binnedData.states(:,1)) - false_move;
true_move = sum(binnedData.states(:,1)) - false_hold;
confusion = [true_hold false_hold; false_move true_move]
descriptor = ['true_hold ' 'false_hold'; 'false_move ' 'true_move']
