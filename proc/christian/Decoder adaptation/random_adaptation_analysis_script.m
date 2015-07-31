
%%---------------------------------------------------------------------------------%%
% Append column to all_data
empty_col = {[]; []; []; []; []; []; []; []; []};
all_data = [all_data dataset({empty_col, 'results_superv'})];
all_data = [all_data(:,1:10) dataset({empty_col, 'predsF_superv'}) all_data(:,14:end)];

%%---------------------------------------------------------------------------------%%
% Optimization
for i = 1:6
    res = optimize_adapt_params(E2F,all_data.traindata{i},all_data.optimdata{1},'LR');
    all_data.optim_LR_res{i} = res;
end


%%---------------------------------------------------------------------------------%%
%Copy data from figure
idx = 6;
msedata = get(get(gca,'Children'),'YData')';
all_data.optim_delay_res{idx}.mse = msedata;
msedata = flip(msedata);

vafdata = get(get(gca,'Children'),'YData')';
all_data.optim_LR_res{idx}.vaf = [vafdata{3}' vafdata{2}'];


%%---------------------------------------------------------------------------------%%
%copy eval_offline results in all_data
td = [2.5000    5.0000    7.5000   10.0000   12.5000   15.0000   17.5000   20.0000];
tds= [2.5000    5.0000    7.5000   10.0000   12.5000   15.0000   17.5000   18];

train_duration = [repmat(td,6,1);tds;td;td];

for i = 1:9
%     res = eval_offline_preds(all_data.traindata{i},all_data.testdata{i},train_duration(i,:));
    i = 10;
    decoder = eval([['results_' all_data.filename{i} '_normal'] '.decoders(end)']);
    decoder = [decoder;{E2F_deRugy_PD}];
    [~,~,~,~,predsE]            = plot_predsF(all_data.testdata{i},decoder,'emg_cascade',0);
    all_data.predsE_norm{i}     = predsE;
    all_data.predsF_norm{i}     = eval([['results_' all_data.filename{i} '_normal'] '.preds(:,:,end)']);
    all_data.predsF_opt{i}      = eval([['results_' all_data.filename{i} '_optimal'] '.preds(:,:,end)']);
    all_data.predsF_opt_tgt{i}  = eval([['results_' all_data.filename{i} '_optimal_target'] '.preds(:,:,end)']);
    all_data.predsF_superv{i}   = eval([['results_' all_data.filename{i} '_supervised'] '.preds(:,:,end)']);
    all_data.results_norm{i}    = eval(['results_' all_data.filename{i} '_normal']);
    all_data.results_opt{i}     = eval(['results_' all_data.filename{i} '_optimal']);
    all_data.results_opt_tgt{i} = eval(['results_' all_data.filename{i} '_optimal_target']);
    all_data.results_superv{i}  = eval(['results_' all_data.filename{i} '_supervised']);
end
for i = 1:9
    all_data.results_superv{i} = eval(['results_' all_data.filename{i} '_supervised']);
end
for i = 1:9
    all_data.predsF_superv{i} = all_data.results_superv(i).preds(:,:,end);
end


%%---------------------------------------------------------------------------------%%
%% Plot all_mse (for max train_duration)

% 1-line plots of mse with time ----------------------

    % normal
    figure; hold on;
    for i=1:9
        plot(all_data.results_norm{i}.train_duration,all_data.results_norm{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 50]); title('MSE with training time; ''normal''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));

    %optimal
    figure; hold on;
    for i=1:9
        plot(all_data.results_opt{i}.train_duration,all_data.results_opt{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 50]); title('MSE with training time; ''optimal''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));    

    %opt-tgt
    figure; hold on;
    for i=1:9    
        plot(all_data.results_opt_tgt{i}.train_duration,all_data.results_opt_tgt{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 50]); title('MSE with training time; ''optimal-target''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));
    
    % supervised
    figure; hold on;
    for i=1:9    
        plot(all_data.results_superv{i}.train_duration,all_data.results_superv{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 50]); title('MSE with training time; ''supervised''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));

% 2- bar plot with average mse after 20 min (or max train) and error bars ------------------------
    all_mse = nan(9,4); % 9 datasets, 3 conditions
    for i = 1:9
        all_mse(i,4) = all_data.results_norm{i}.mse(end)';
        all_mse(i,1) = all_data.results_opt{i}.mse(end)';
        all_mse(i,2) = all_data.results_opt_tgt{i}.mse(end)';
        all_mse(i,3) = all_data.results_superv{i}.mse(end)';
    end
    all_mse(isnan(all_mse))=0;
    figure;
    h = bar([all_mse;mean(all_mse)]);
    pretty_fig(gca);legend('opt','opt\_tgt','superv','normal');
    ylabel('MSE');
    for i=1:9
        set(gca,'XTickLabel',strrep([all_data.filename;{'Average'}],'_','\_'),'XTickLabelRotation',30);
    end
    % place SD error bars on average bars
    hold on;
    for i= 1:4
        err_x = get(h(i),'xdata') + get(h(i),'xoffset');
        y_val = get(h(i),'ydata');
        err_y = std(all_mse(:,i));
        errorbar(err_x(end),y_val(end),err_y,'k');
    end

%%---------------------------------------------------------------------------------%%
%% Plot EMG predictions vectors for each target along with optimal EMG patterns

R2 = nan(n_tgts,9);
for dataset = 7:9
    
    predData = all_data.testdata{dataset};
    predData.emgdatabin = all_data.predsE_norm{dataset};
    e2f = E2F_deRugy_PD;
    predData.emgguide = e2f.emglabels;
    pred_stats = get_WF_stats(predData);
    
    n_emgs = length(e2f.emglabels);
    
    opt_emgs = get_optim_emg_patterns(E2F_deRugy_PD(15),[0 1]);
    opt_emgs = opt_emgs([2:end 1],:);
    
    n_tgts = size(opt_emgs,1);
    
    delay_bins = 12;
    save_path = '/Users/christianethier/Dropbox/Adaptation/Results/EMGPreds_vs_OptEMGPatterns';
    memg = zeros(n_tgts,n_emgs);
    
    for tgt  = 1:n_tgts
        
        n_trials       = size(pred_stats.emgs{tgt},1);
        n_valid_trials = 0;
        for trial = 1:n_trials
            if size(pred_stats.emgs{tgt}{trial},1)>delay_bins
                n_valid_trials = n_valid_trials+1;
                memg(tgt,:) = memg(tgt,:)*(n_valid_trials-1)/n_valid_trials ...
                    + mean(pred_stats.emgs{tgt}{trial}((delay_bins+1):end,:),1,'omitnan')/n_valid_trials;
            end
        end
        
        figure; hold on;
        for i = 1:n_emgs
            %plot optimal
            V = e2f.H(i,:)*opt_emgs(tgt,i);
            plot([0 V(1)],[0 V(2)],'k-','LineWidth',7,'MarkerFaceColor','k');
            %plot predictions
            V = e2f.H(i,:)*memg(tgt,i);
            plot([0 V(1)],[0 V(2)],'-','LineWidth',3);
        end
        
        % calculate Pearson's R
        Vopt = detrend(opt_emgs(tgt,:),'constant');
        Vpred= detrend(memg(tgt,:),'constant');
        R2(tgt,dataset) = (Vopt*Vpred'/(norm(Vopt)*norm(Vpred)))^2;
        
        if tgt == n_tgts
            ttl = sprintf('Center Target : R =%.2f',R2(tgt,dataset));
            tgt_str = 'center';
        else
            ttl = sprintf('Target #%d : R=%.2f',tgt,R2(tgt,dataset));
            tgt_str = ['tgt' num2str(tgt)];
        end
        title(ttl); axis square;
        mxy = 10; ylim([-mxy mxy]); xlim([-mxy mxy]);
        set(gca,'Box','Off',...
            'FontName','Arial','FontSize',16,'FontWeight','Bold','TickDir','Out');
        
        savefig(gcf,[save_path filesep all_data.filename{dataset} tgt_str ]);
    end
    pause;
    close all;
end