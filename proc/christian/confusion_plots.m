    correct = zeros(size(binnedData.states,2)-1,1);
    
    incorrect = zeros(size(binnedData.states,2)-1);
    false_hold = zeros(size(binnedData.states,2)-1);
    false_move = zeros(size(binnedData.states,2)-1);
    true_hold = zeros(size(binnedData.states,2)-1);
    true_move = zeros(size(binnedData.states,2)-1);
    
    confusion = zeros(2,2,size(binnedData.states,2)-1);
    confusion_perc= zeros(2,2,size(binnedData.states,2)-1);

for x = 1:size(binnedData.states,2)-1
    correct(x) = 1 - sum(abs(binnedData.states(:,1) - binnedData.states(:,x+1)))/length(binnedData.states);

    incorrect(x) = sum(abs(binnedData.states(:,1) - binnedData.states(:,x+1)));
    false_hold(x) = (sum(binnedData.states(:,1) - binnedData.states(:,x+1)) + incorrect(x)) / 2;
    false_move(x) = incorrect(x) - false_hold(x);
    true_hold(x) = length(binnedData.states) - sum(binnedData.states(:,1)) - false_move(x);
    true_move(x) = sum(binnedData.states(:,1)) - false_hold(x);
    
    confusion(:,:,x) = [true_hold(x) false_hold(x); false_move(x) true_move(x)];
    confusion_perc(:,:,x) = confusion(:,:,x)./length(binnedData.states);
    descriptor = ['true_hold ' 'false_hold'; 'false_move ' 'true_move'];
    
end

correct
confusion
confusion_perc

figure

subplot(2,2,1)
pie([confusion(1,:,1) confusion(2,:,1)])
title(binnedData.statemethods(2,:));
legend('true hold', 'false hold', 'false move', 'true move');

subplot(2,2,2)
pie([confusion(1,:,2) confusion(2,:,2)])
title(binnedData.statemethods(3,:));

subplot(2,2,3)
pie([confusion(1,:,3) confusion(2,:,3)])
title(binnedData.statemethods(4,:));

subplot(2,2,4)
pie([confusion(1,:,4) confusion(2,:,4)])
title(binnedData.statemethods(5,:));
