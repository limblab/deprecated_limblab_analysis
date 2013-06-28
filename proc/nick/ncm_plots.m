for x = 1:9

    [states{x}, perform{x}] = mfxvalClass(eval(['binnedData' num2str(x)]), 60, 8);

    tot_corr(x) = (sum(perform{x}.true_post) + sum(perform{x}.true_move)) / (sum(perform{x}.true_post) + sum(perform{x}.true_move) + sum(perform{x}.false_post) + sum(perform{x}.false_move));
    corr_post(x) = sum(perform{x}.true_post) / (sum(perform{x}.true_post) + sum(perform{x}.false_move));
    corr_move(x) = sum(perform{x}.true_move) / (sum(perform{x}.true_move) + sum(perform{x}.false_post));

end

mean(tot_corr)
mean(corr_post)
mean(corr_move)

std(tot_corr)
std(corr_post)
std(corr_move)






figure
bar([1 5],[90.4 94.3],0.25,'c')
hold on
bar([2 6],[80.5 88.0],0.25,'r')
bar([3 7],[87.8 92.9],0.25,'g')

errorbar([1 5],[90.4 94.3],[1.3 0.6],[1.3 0.6],'k','linestyle','none')
errorbar([2 6],[80.5 88.0],[2.0 1.0],[2.0 1.0],'k','linestyle','none')
errorbar([3 7],[87.8 92.9],[1.4 0.6],[1.4 0.6],'k','linestyle','none')

title('Classifier Performance')
ylabel('Percent Correct')

legend('Posture','Movement','Overall')



figure
bar([1 4 8 11],[3.0 5.2 5.8 6.8],1/3,'c')
hold on
bar([2 5 9 12],[5.3 8.5 8.0 11.4],1/3,'r')

errorbar([1 4 8 11],[3.0 5.2 5.8 6.8],[1.8 1.1 2.1 2.7],[1.8 1.1 2.1 2.7],'k','linestyle','none')
errorbar([2 5 9 12],[5.3 8.5 8.0 11.4],[1.8 3.2 2.4 2.6],[1.8 3.2 2.4 2.6],'k','linestyle','none')

title('BMI Performance')
ylabel('Targets Acquired / min')

legend('Linear Decoder','Dual Decoder')




figure
bar([1 5 10 14],[66.0 60.0 74.0 71.0],1/4,'m')
hold on
bar([2 6 11 15],[70.5 59.9 81.8 77.2],1/4,'c')
bar([3 7 12 16],[80.0 74.5 85.8 83.8],1/4,'g')

errorbar([1 5 10 14],[66.0 60.0 74.0 71.0],[10.3 13.4 6.2 7.7],[10.3 13.4 6.2 7.7],'k','linestyle','none')
errorbar([2 6 11 15],[70.5 59.9 81.8 77.2],[11.7 23.6 6.0 7.5],[11.7 23.6 6.0 7.5],'k','linestyle','none')
errorbar([3 7 12 16],[80.0 74.5 85.8 83.8],[6.9 10.8 3.1 4.2],[6.9 10.8 3.1 4.2],'k','linestyle','none')

title('Velocity Prediction Performance')
ylabel('Percent VAF')

legend('Linear','Rank Order','State Dependent')
