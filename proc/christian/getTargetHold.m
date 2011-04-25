
leave_center_words = (binnedData.words(:,2) >=64 & binnedData.words(:,2) < 80); % create a logical array with indices of all words that represent outter target appearance
reward_words = binnedData.words(:,2) == 32; % create a logical array with indices of all words that represent rewards (successful trials)
rel_times = [binnedData.words(leave_center_words,1); binnedData.words(reward_words,1)];

binnedData.targetHold = false(length(binnedData.timeframe),1);
for x = 1:length(rel_times)
    for y = 1:length(binnedData.timeframe)
        if binnedData.timeframe(y) > rel_times(x)
            break
        elseif rel_times(x) - binnedData.timeframe(y) < 0.5
            binnedData.targetHold(y,1) = true;
        end
    end
end

clear leave_center_words rel_times reward_words x y;