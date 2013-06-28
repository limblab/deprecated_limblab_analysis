for x = 1:10
    hyb_srt_num_entries_y(x) = length(find(hyb_srt_num_entries == x))/length(hyb_srt_num_entries);
    std_srt_num_entries_y(x) = length(find(std_srt_num_entries == x))/length(std_srt_num_entries);
    hyb_cosh_num_entries_y(x) = length(find(hyb_cosh_num_entries == x))/length(hyb_cosh_num_entries);
    std_cosh_num_entries_y(x) = length(find(std_cosh_num_entries == x))/length(std_cosh_num_entries);
    hyb_colh_num_entries_y(x) = length(find(hyb_colh_num_entries == x))/length(hyb_colh_num_entries);
    std_colh_num_entries_y(x) = length(find(std_colh_num_entries == x))/length(std_colh_num_entries);
end

figure;
set(gca,'TickDir','out')
hold on; plot(0:10,[0 hyb_srt_num_entries_y],'k',0:10,[0 std_srt_num_entries_y],'k--')
hold on; plot(0:10,[0 hyb_cosh_num_entries_y],'c',0:10,[0 std_cosh_num_entries_y],'c--')
hold on; plot(0:10,[0 hyb_colh_num_entries_y],'r',0:10,[0 std_colh_num_entries_y],'r--')
title('Target Entries per Trial')
ylabel('Occurrence Rate')
xlabel('Number of Target Entries')
axis([0 10 0 1])
legend('SRT Hybrid','SRT Standard','COsh Hybrid','COsh Standard','COlh Hybrid','COlh Standard')

set(gca,'FontName','Arial','FontSize',10)

sum(hyb_srt_dial_in == 0)




% For calculating RW distance to target
binnedData.targetpos = NaN * ones(length(binnedData.timeframe),2);
trial = 1;
for x = 1:length(binnedData.timeframe)
    if trial < length(binnedData.targets.centers)
        if binnedData.targets.centers(trial,1) < binnedData.timeframe(x)
            binnedData.targetpos(x,:) = [binnedData.targets.centers(trial,3) binnedData.targets.centers(trial,4)];
            if binnedData.targets.centers(trial+1,1) < binnedData.timeframe(x)
                trial = trial + 1;
            end
        end
    end
end

binnedData.targetdist = sqrt((binnedData.cursorposbin(:,1)-binnedData.targetpos(:,1)).^2 + (binnedData.cursorposbin(:,2)-binnedData.targetpos(:,2)).^2);

figure; plot(0.05*(1:length(binnedData.timeframe)),binnedData.targetdist)
hold on; plot(0.05*(1:length(binnedData.timeframe)),2,'r')



% For calculating VS distance to target
binnedData.targetpos = NaN * ones(length(binnedData.timeframe),2);
trial = 1;
for x = 1:length(binnedData.timeframe)
    if trial <= length(binnedData.trialtable)
        if binnedData.trialtable(trial,3) < binnedData.timeframe(x)
            binnedData.targetpos(x,:) = [0 0];
            if binnedData.trialtable(trial,5) < binnedData.timeframe(x)
                binnedData.targetpos(x,:) = 8*[sin(binnedData.trialtable(trial,2)*pi/8) cos(binnedData.trialtable(trial,2)*pi/8)];
                if binnedData.trialtable(trial,9) < binnedData.timeframe(x)
                    trial = trial + 1;
                end
            end
        end
    end
end

binnedData.targetdist = sqrt((binnedData.cursorposbin(:,1)-binnedData.targetpos(:,1)).^2 + (binnedData.cursorposbin(:,2)-binnedData.targetpos(:,2)).^2);

figure; plot(0.05*(1:length(binnedData.timeframe)),binnedData.targetdist)
hold on; plot(0.05*(1:length(binnedData.timeframe)),0.9,'r')