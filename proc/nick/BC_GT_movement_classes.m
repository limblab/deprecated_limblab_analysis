% load brain control binnedData file

binnedData.states = zeros(length(binnedData.timeframe),1);

move_times = binnedData.words([false; (binnedData.words(1:end-2,2)==18); false],1);
move_times(:,2) = binnedData.words([false; false; (binnedData.words(1:end-2,2)==18)],1);

posture_times = binnedData.words((binnedData.words(:,2)==32),1);
posture_times = repmat(posture_times,1,2);
posture_times(:,1) = posture_times(:,1)-1;

move_index = 1;
posture_index = 1;

for x = 1:length(binnedData.timeframe)
    
    if binnedData.timeframe(x) > posture_times(posture_index,1) && binnedData.timeframe(x) < posture_times(posture_index,2)
        binnedData.states(x) = 0;
    elseif binnedData.timeframe(x) > move_times(move_index,1) && binnedData.timeframe(x) < move_times(move_index,2)
        binnedData.states(x) = 1;
    else
        binnedData.states(x) = 2;
    end
    
    if binnedData.timeframe(x) > posture_times(posture_index,2) && posture_index < length(posture_times)
        posture_index = posture_index + 1;
    end
    
    if binnedData.timeframe(x) > move_times(move_index,2) && move_index < length(move_times)
        move_index = move_index + 1;
    end

end    