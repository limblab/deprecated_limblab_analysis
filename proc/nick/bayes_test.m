holds = zeros(1,69);
moves = zeros(1,69);
hold_count = 0;
move_count = 0;

for x = 1:725
    if group(x) == 0
        holds = holds + training(x,1:69);
        hold_count = hold_count + 1;
    else
        moves = moves + training(x,1:69);
        move_count = move_count + 1;
    end
end

holds = holds/hold_count;
moves = moves/move_count;

% o1 = NaiveBayes.fit([holds; moves],[0; 1]);
o1 = NaiveBayes.fit(training(:,1:69), group);

classes = zeros(length(binnedData.timeframe),1);

for x = 4:length(binnedData.timeframe)
    classes(x) = o1.predict(mean(binnedData.spikeratedata(x-3:x,1:69),1));
end

plot(binnedData.timeframe, binnedData.states(:,1), 'b', binnedData.timeframe, -classes, 'r', binnedData.timeframe, binnedData.velocbin(:,3)/30, 'k')
axis([0 max(binnedData.timeframe) -2 2])

figure
plot(binnedData.timeframe, abs(binnedData.states(:,1) - classes(:,1)))
axis([0 max(binnedData.timeframe) -2 2])

correct = 1 - sum(abs(binnedData.states(:,1) - classes(:,1)))/length(classes)