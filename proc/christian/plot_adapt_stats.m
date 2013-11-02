function plot_adapt_stats(offline_stats,adapt_stats)

    num_adapt = size(adapt_stats,1);
    num_dim =   size(adapt_stats,3);

    for i = 1:num_dim
    figure;  hold on;
    plot(1:num_adapt,offline_stats(:,1,i),'ro-','LineWidth',2); title(sprintf('R^2 dim %d',i));
    plot(1:num_adapt,adapt_stats(:,1,i),'bo-','LineWidth',2);
%     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; hold on;
    plot(1:num_adapt,offline_stats(:,2,i),'ro-','LineWidth',2); title(sprintf('vaf dim %d',i));
    plot(1:num_adapt,adapt_stats(:,2,i),'bo-','LineWidth',2);
%     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; x_mse =gca; hold on;
    plot(1:num_adapt,offline_stats(:,3,i),'ro-','LineWidth',2); title(sprintf('mse dim %d',i));
    plot(1:num_adapt,adapt_stats(:,3,i),'bo-','LineWidth',2);
%     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    end
end
%     figure; x_vaf =gca; hold on;
%     plot(x_vaf,1:num_adapt,offline_stats(:,2,1),'ro-','LineWidth',2); title('vaf X');
%     plot(x_vaf,1:num_adapt,adapt_stats(:,2,1),'bo-','LineWidth',2);
%     plot(x_vaf,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');
%     
%     figure; y_vaf = gca; hold on;
%     plot(y_vaf,1:num_adapt,offline_stats(:,2,2),'ro-','LineWidth',2); title('vaf Y');
%     plot(y_vaf,1:num_adapt,adapt_stats(:,2,2),'bo-','LineWidth',2);
%     plot(y_vaf,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');
%     
%     figure; x_R2 =gca; hold on;
%     plot(x_R2,1:num_adapt,offline_stats(:,1,1),'ro-','LineWidth',2); title('R^2 X');
%     plot(x_R2,1:num_adapt,adapt_stats(:,1,1),'bo-','LineWidth',2);
%     plot(x_R2,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');
%     
%     figure; y_R2 = gca; hold on;
%     plot(y_R2,1:num_adapt,offline_stats(:,1,2),'ro-','LineWidth',2); title('R^2 Y');
%     plot(y_R2,1:num_adapt,adapt_stats(:,1,2),'bo-','LineWidth',2);
%     plot(y_R2,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');
%     
%     figure; x_mse =gca; hold on;
%     plot(x_mse,1:num_adapt,offline_stats(:,3,1),'ro-','LineWidth',2); title('mse X');
%     plot(x_mse,1:num_adapt,adapt_stats(:,3,1),'bo-','LineWidth',2);
%     plot(x_mse,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');
%     
%     figure; y_mse = gca; hold on;
%     plot(y_mse,1:num_adapt,offline_stats(:,3,2),'ro-','LineWidth',2); title('mse Y');
%     plot(y_mse,1:num_adapt,adapt_stats(:,3,2),'bo-','LineWidth',2);
%     plot(y_mse,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
%     legend('offline training','online adaptation');