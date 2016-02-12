for trial = 1:2

window = 0.050*trial; % in seconds (for spike averaging) should match training

bin = double(binnedData.timeframe(2) - binnedData.timeframe(1));
window_bins = floor(window/bin);

training_set = zeros(length(binnedData.timeframe)-(window_bins-1),length(binnedData.spikeguide));
group = zeros(length(training_set),1);

for x = window_bins:length(binnedData.timeframe)
%     observation = [];
%     for y = 1:window_bins
%         observation = [observation binnedData.spikeratedata(x-(window_bins-1):x,:)];
%     end
%     training_set(x,:) = observation;
    training_set(x,:) = mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1);
    group(x) = binnedData.states(x,1);
end

classes = zeros(length(binnedData.timeframe),1);

classes_p = zeros(length(binnedData.timeframe),1);

classes_q = zeros(length(binnedData.timeframe),1);

classes_qp = zeros(length(binnedData.timeframe),1);

[~,~,~,~,coeff] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group);

[~,~,~,~,coeff0] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group,'linear',[0.7 0.3]);

[~,~,~,~,coeff1] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group,'linear',[0.4 0.6]);

[~,~,~,~,coeffq] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group,'quadratic');

[~,~,~,~,coeffq0] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group,'quadratic',[0.7 0.3]);

[~,~,~,~,coeffq1] = classify(mean(binnedData.spikeratedata(1:window_bins,:),1),training_set,group,'quadratic',[0.4 0.6]);

for x = window_bins:length(binnedData.timeframe)
    classes(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeff(1,2).linear + coeff(1,2).const; % default (no priors)
end

for x = window_bins:length(binnedData.timeframe)
    if x-1 == 0
        classes_p(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeff0(1,2).linear + coeff0(1,2).const;
    elseif classes_p(x-1) == 0
        classes_p(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeff0(1,2).linear + coeff0(1,2).const;
    else
        classes_p(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeff1(1,2).linear + coeff1(1,2).const;
    end
end

for x = window_bins:length(binnedData.timeframe)
    classes_q(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq(1,2).quadratic*mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)' + mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq(1,2).linear + coeffq(1,2).const;
end

for x = window_bins:length(binnedData.timeframe)
    if x-1 == 0
        classes_qp(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq0(1,2).quadratic*mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)' + mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq0(1,2).linear + coeffq0(1,2).const;
    elseif classes_qp(x-1) == 0
        classes_qp(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq0(1,2).quadratic*mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)' + mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq0(1,2).linear + coeffq0(1,2).const;
    else
        classes_qp(x) = 0 >= mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq1(1,2).quadratic*mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)' + mean(binnedData.spikeratedata(x-(window_bins-1):x,:),1)*coeffq1(1,2).linear + coeffq1(1,2).const;
    end
end

correct(trial) = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes);

correct_p(trial) = 1 - sum(abs(binnedData.states(:,1) - classes_p(:,1)))/length(classes);

correct_q(trial) = 1 - sum(abs(binnedData.states(:,1) - classes_q(:,1)))/length(classes);

correct_qp(trial) = 1 - sum(abs(binnedData.states(:,1) - classes_qp(:,1)))/length(classes);

end

plot([0.05:0.05:1],correct,[0.05:0.05:1],correct_p,[0.05:0.05:1],correct_q,[0.05:0.05:1],correct_qp)
legend('linear','linear priors','quadratic','quadratic priors')

% figure
% plot(binnedData.timeframe, classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
% axis([0 max(binnedData.timeframe) -1 2])
% title(['Predicted classification, priors [hold movement] = [', num2str(o1.Prior,3), ']']);
% legend('predicted classes', 'normalized velocity');
% xlabel('time (s)');
% ylabel('state 1 = movement, state 0 = hold');
% 
% correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes);
% 
% figure
% plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/max(binnedData.velocbin(:,3)), 'k')
% axis([0 max(binnedData.timeframe) -2 2])
% title(['Classification accuracy = ', num2str(correct,3)]);
% legend('movement classes', 'predicted classes', 'normalized velocity');
% xlabel('time (s)');
% ylabel('state (+/-)1 = movement, state 0 = hold');
% 
% figure
% plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
% axis([0 max(binnedData.timeframe) -1 2]);
% title('Classification errors');
% xlabel('time (s)');
% ylabel('1 = error, 0 = correct');
