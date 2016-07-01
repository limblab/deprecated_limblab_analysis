% % 

%-------------------------------------------------------------------------------------
means = [mean(EpochMeansDifference_Tgt1) mean(EpochMeansDifference_Tgt2)];
ste1 = (std(EpochMeansDifference_Tgt1))/(sqrt(length(EpochMeansDifference_Tgt1)));
ste2 = (std(EpochMeansDifference_Tgt2))/(sqrt(length(EpochMeansDifference_Tgt2)));

STEs = [ste1 ste2]

if n == 3
    means = [mean(EpochMeansDifference_Tgt1) mean(EpochMeansDifference_Tgt2) mean(EpochMeansDifference_Tgt3)]
    ste3 = (std(EpochMeansDifference_Tgt3))/(sqrt(length(EpochMeansDifference_Tgt3)))
    STEs = [ste1 ste2]
end

figure
errorbar(means,stes,'x','MarkerSize', 10, 'LineWidth', 2)
title('03-10-14 | Epoch Means Difference | 3FL decoder on 2FL data')
xlabel('Target Number')
 set(gca,'XTick', [1 2])
ylim([-50 60])
set(gca,'TickDir','out')


