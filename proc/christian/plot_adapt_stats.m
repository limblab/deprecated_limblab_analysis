function plot_adapt_stats(offline_stats,adapt_stats)

    num_adapt = size(adapt_stats,1);
    num_dim =   size(adapt_stats,3);

    for i = 1:num_dim
        figure;  hold on;
        plot(1:num_adapt,offline_stats(:,1,i),'r','LineWidth',2); title(sprintf('R^2 dim %d',i));
        plot(1:num_adapt,adapt_stats(:,1,i),'b','LineWidth',2);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');

        figure; hold on;
        plot(1:num_adapt,offline_stats(:,2,i),'r','LineWidth',2); title(sprintf('vaf dim %d',i));
        plot(1:num_adapt,adapt_stats(:,2,i),'b','LineWidth',2);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');

        figure; x_mse =gca; hold on;
        plot(1:num_adapt,offline_stats(:,3,i),'r','LineWidth',2); title(sprintf('mse dim %d',i));
        plot(1:num_adapt,adapt_stats(:,3,i),'b','LineWidth',2);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');
    
    end
end
