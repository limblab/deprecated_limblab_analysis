function plot_adapt_stats(varargin)

    if nargin == 2
        adapt_stats = varargin{1};
        labels      = varargin{2};
        plot_adapt_stats_online(adapt_stats,labels);
    elseif nargin == 3
        offline_stats = varargin{1};
        adapt_stats   = varargin{2};
        labels        = varargin{3};
        plot_adapt_stats_online_vs_offline(offline_stats,adapt_stats,labels);
    else
        disp('wrong number of argument to plot_adapt_stats');
    end
end

function plot_adapt_stats_online_vs_offline(offline_stats,adapt_stats,labels)

    num_adapt = size(adapt_stats,1);
    num_dim =   size(adapt_stats,3);

    for i = 1:num_dim
        figure;  hold on;
        plot(1:num_adapt,offline_stats(:,1,i),'r','LineWidth',2); title(sprintf('R^2 dim %d\n%s',i,labels));
        plot(1:num_adapt,adapt_stats(:,1,i),'b','LineWidth',2);
        ylim([0 1]);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');

        figure; hold on;
        plot(1:num_adapt,offline_stats(:,2,i),'r','LineWidth',2); title(sprintf('vaf dim %d\n%s',i,labels));
        plot(1:num_adapt,adapt_stats(:,2,i),'b','LineWidth',2);
        ylim([-2 1]);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');

        figure; hold on;
        plot(1:num_adapt,offline_stats(:,3,i),'r','LineWidth',2); title(sprintf('mse dim %d\n%s',i,labels));
        plot(1:num_adapt,adapt_stats(:,3,i),'b','LineWidth',2);
        ylim([0 40]);
    %     plot([last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
        legend('offline training','online adaptation');
    
    end
end

function plot_adapt_stats_online(adapt_stats,labels)

    num_adapt = size(adapt_stats,1);
    num_dim =   size(adapt_stats,3);

    for i = 1:num_dim
        figure;  hold on;
        plot(1:num_adapt,adapt_stats(:,1,i),'b','LineWidth',2); title(sprintf('R^2 dim %d\n%s',i,labels));
        ylim([0 1]); legend('Adaptive Decoder R2 during HC');

        figure; hold on;
        plot(1:num_adapt,adapt_stats(:,2,i),'b','LineWidth',2); title(sprintf('vaf dim %d\n%s',i,labels));
        ylim([-2 1]);  legend('Adaptive Decoder vaf during HC');

        figure; hold on;
        plot(1:num_adapt,adapt_stats(:,3,i),'b','LineWidth',2); title(sprintf('mse dim %d\n%s',i,labels));
        ylim([0 40]); legend('Adaptive Decoder MSE during HC');
    end
end
