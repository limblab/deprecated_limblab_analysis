target_count = 1;
target_x(1) = 99;
target_y(1) = 99;
target_time(1) = 0;
num_targets = binnedData.targets.centers(1,2);
first_start = find(binnedData.words(:,2) == 18, 1);

for w = first_start:length(binnedData.words)
    
    if binnedData.words(w,2) == 18
        trial_time = binnedData.words(w,1);
        target_row = find(binnedData.targets.centers(:,1) > trial_time, 1);
        target = 0;
    end
    
    if binnedData.words(w,2) == 49 && (binnedData.words(w-1,2) == 18 || ((binnedData.words(w,1) - binnedData.words(w-1,1)) > 0.8))
        target_count = target_count + 1;
        target = target + 1;
        if target > 3
            target = 3;
        end
        target_x(target_count) = binnedData.targets.centers(target_row, 2*target+1);
        target_y(target_count) = binnedData.targets.centers(target_row, 2*target+2);
        target_time(target_count) = binnedData.words(w,1);
    end

%     if binnedData.words(w,2) == 32
%         target_count = target_count + 1;
%         target_x(target_count) = 99;
%         target_y(target_count) = 99;
%         target_time(target_count) = binnedData.words(w,1);
%     end
    
end

for bin = 1:length(binnedData.cursorposbin)
    
    targ_index = find(target_time < binnedData.timeframe(bin), 1, 'last');
    x_pos = binnedData.cursorposbin(bin,1) + 5;
    y_pos = binnedData.cursorposbin(bin,2) + 33;
    distance2target(bin) = sqrt((target_x(targ_index) - x_pos)^2 + (target_y(targ_index) - y_pos)^2);
        
end

binnedData.cursorposbin(:,3) = distance2target;