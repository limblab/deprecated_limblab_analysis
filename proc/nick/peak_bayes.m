clear training_set;
clear group;

window = 0.200; % in seconds (for spike averaging)
cutoff = 5; % in Hz (for velocity low pass filtering)

bin = double(binnedData.timeframe(2) - binnedData.timeframe(1));
window_bins = floor(window/bin);

speed = double(binnedData.velocbin(:,3));
[B,A] = butter(4,cutoff*bin/2,'low');
speed_filt = filtfilt(B,A,speed);

figure
plot(binnedData.timeframe, speed, 'b', binnedData.timeframe, speed_filt, 'r')
axis([0 max(binnedData.timeframe) min(speed_filt) max(speed)])
title(['Velocity filtering to get peaks (low pass = ', num2str(cutoff), ' Hz)']);
legend('measured velocity', 'filtered velocity');
xlabel('time (s)');
ylabel('velocity magnitude (cm/s)');

observation = 0;
for x = window_bins:length(binnedData.timeframe)-1 % default
% for x = window_bins:floor(length(binnedData.timeframe)/2) % use first half of data
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

o1 = NaiveBayes.fit(training_set, group); % default
% o1 = NaiveBayes.fit(training_set(:,1:69), group); % for Keedoo 12/14
% o1 = NaiveBayes.fit(training_set(:,[1:48 53:97]), group); % for first half Keedoo 11/11

classes = zeros(length(binnedData.timeframe),1);

for x = window_bins:length(binnedData.timeframe)
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)); % default
%     classes(x) = o1.predict(mean(binnedData.spikeratedata(x-(window_bins-1):x,1:69),1)); % for Keedoo 12/14
%     classes(x) = o1.predict(mean(binnedData.spikeratedata(x-(window_bins-1):x,[1:48 53:97]),1)); % for first half Keedoo 11/11
end

figure
area(binnedData.timeframe, binnedData.states(:,1), 'FaceColor', [208 255 255]./255, 'LineStyle', 'none')
hold on
plot(binnedData.timeframe, classes, 'k', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'r')
axis([0 max(binnedData.timeframe) -1 2])
title('Predicted classification');
legend('movement classes', 'predicted classes', 'normalized velocity');
xlabel('time (s)');
ylabel('state 1 = movement, state 0 = hold');

% figure
% plot(binnedData.timeframe, classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
% axis([0 max(binnedData.timeframe) -1 2])
% title('Predicted classification');
% legend('predicted classes', 'normalized velocity');
% xlabel('time (s)');
% ylabel('state 1 = movement, state 0 = hold');

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
