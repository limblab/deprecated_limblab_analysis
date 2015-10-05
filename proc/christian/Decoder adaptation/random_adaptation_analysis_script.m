
%%---------------------------------------------------------------------------------%%
% Append column to all_data
empty_col = {[]; []; []; []; []; []; []; []; []; []};
all_data = [all_data dataset({empty_col, 'BC_opt'}) dataset({empty_col, 'BC_Adapt'})];
all_data = [all_data(:,1:10) dataset({empty_col, 'predsF_superv'}) all_data(:,14:end)];

%%---------------------------------------------------------------------------------%%
%% Optimization
for i = 1:6
    res = optimize_adapt_params(all_data.traindata{i},all_data.optimdata{i},'LR');
    all_data.optim_LR_res{i} = res;
end

%%---------------------------------------------------------------------------------%%
% Plot Optimization

all_lr = all_data.optim_LR_res{1}.LR;
all_del = all_data.optim_delay_res{1}.delay;
all_lr_mse = nan(length(all_lr),6);
all_del_mse = nan(length(all_del),6);

for i=1:6
    all_lr_mse(:,i) = all_data.optim_LR_res{i}.mse;
    all_del_mse(:,i) = all_data.optim_delay_res{i}.mse;
end

% plot all individual traces
figure; semilogx(all_lr,all_lr_mse,'o-');
xlim([5e-8 5e-6]); ylim([0 40]); pretty_fig(gca);
title('Iterative Parameter Search - LR');ylabel('MSE'); xlabel('Learning Rate');
legend(strrep(all_data.filename,'_','\_'));

figure; plot(all_del,all_del_mse,'o-');
xlim([0 1]); ylim([0 40]); pretty_fig(gca);
title('Iterative Parameter Search - Delay'); ylabel('MSE'); xlabel('Delay (s)'); legend(strrep(all_data.filename,'_','\_'));

% plot average and SD
figure; semilogx(all_lr,mean(all_lr_mse,2),'ko-'); hold on; plotShadedSD(all_lr,mean(all_lr_mse,2),std(all_lr_mse,0,2));
xlim([5e-8 5e-6]); ylim([0 40]); pretty_fig(gca);
title('Iterative Parameter Search - LR'); ylabel('average MSE'); xlabel('Learning Rate');
legend('mean','SD');

figure; plot(all_del,mean(all_del_mse,2),'ko-'); hold on; plotShadedSD(all_del,mean(all_del_mse,2),std(all_del_mse,0,2)); 
xlim([0 1]); ylim([0 40]); pretty_fig(gca);
title('Iterative Parameter Search - Delay'); ylabel('MSE'); xlabel('Delay (s)');
legend('mean','SD');


%%---------------------------------------------------------------------------------%%
%% Copy data from figure
idx = 6;
msedata = get(get(gca,'Children'),'YData')';
all_data.optim_delay_res{idx}.mse = msedata;
msedata = flip(msedata);

vafdata = get(get(gca,'Children'),'YData')';
all_data.optim_LR_res{idx}.vaf = [vafdata{3}' vafdata{2}'];


%% copy eval_offline results in all_data
td = {2.5000    5.0000    7.5000   10.0000   12.5000   15.0000   17.5000   20.0000};
tds= {2.5000    5.0000    7.5000   10.0000   12.5000   15.0000   17.5000};

train_duration = {td;td;td;td;td;td;tds;td;td;td};

for i = 1:10

    i = 4;
    res = eval_offline_preds(all_data.traindata{i},all_data.testdata{i},train_duration(i,:));
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

for i = 1:10;
all_data.results_norm{i}.train_duration = cell2mat(train_duration{i});
all_data.results_opt{i}.train_duration = cell2mat(train_duration{i});
all_data.results_opt_tgt{i}.train_duration = cell2mat(train_duration{i});
all_data.results_superv{i}.train_duration = cell2mat(train_duration{i});
end

%%---------------------------------------------------------------------------------%%
%% Plot all_mse (for max train_duration)

% 1-line plots of mse with time ----------------------

    % normal
    figure; hold on;
    for i=1:10
        plot(all_data.results_norm{i}.train_duration,all_data.results_norm{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 40]); title('MSE with training time; ''normal''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));

    %optimal
    figure; hold on;
    for i=1:10
        plot(all_data.results_opt{i}.train_duration,all_data.results_opt{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 40]); title('MSE with training time; ''optimal''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));    

    %opt-tgt
    figure; hold on;
    for i=1:10   
        plot(all_data.results_opt_tgt{i}.train_duration,all_data.results_opt_tgt{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 40]); title('MSE with training time; ''optimal-target''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));
    
    % supervised
    figure; hold on;
    for i=1:10   
        plot(all_data.results_superv{i}.train_duration,all_data.results_superv{i}.mse,'o-');
    end
    pretty_fig(gca); ylim([0 40]); title('MSE with training time; ''supervised''');
    ylabel('MSE'); xlabel('training duration'); legend(strrep(all_data.filename,'_','\_'));

% 2- bar plot with average mse after 20 min (or max train) and error bars ------------------------
    all_mse = nan(10,4); % 10 datasets, 4 conditions
    for i = 1:10
        all_mse(i,1) = all_data.results_opt{i}.mse(end)';
        all_mse(i,2) = all_data.results_opt_tgt{i}.mse(end)';
        all_mse(i,3) = all_data.results_superv{i}.mse(end)';
        all_mse(i,4) = all_data.results_norm{i}.mse(end)';
    end
    all_mse(isnan(all_mse))=0;
    figure;
    h = bar([all_mse;mean(all_mse)]);
    pretty_fig(gca);legend('opt','opt\_tgt','superv','normal');
    ylabel('MSE');
    for i=1:10
        set(gca,'XTickLabel',strrep([all_data.filename;{'Average'}],'_','\_'),'XTickLabelRotation',30);
    end
    % place 2*SE error bars on average bars
    hold on;
    for i= 1:4
        err_x = get(h(i),'xdata') + get(h(i),'xoffset');
        y_val = get(h(i),'ydata');
        err_y = std(all_mse(:,i))/sqrt(size(all_mse,1));
        errorbar(err_x(end),y_val(end),err_y,'k');
    end

    %%% All_vaf
    all_vaf = [];
    for i = 1:10
        all_vaf = [all_vaf; all_data.results_norm{i}.vaf(end,:)];
    end
    
%%---------------------------------------------------------------------------------%%
%% Plot EMG predictions vectors for each target along with optimal EMG patterns
opt_emgs = get_optim_emg_patterns(E2F_deRugy_PD(15),[0 1]);
opt_emgs = opt_emgs([2:end 1],:);
n_tgts = size(opt_emgs,1);
R = nan(n_tgts,10);
Rp= nan(n_tgts,10);
rho = nan(n_tgts,10);
tau = nan(n_tgts,10);
e2f = E2F_deRugy_PD;
n_emgs = length(e2f.emglabels);
n_datasets = 10;
delay_bins = 12;
save_path = '/Users/christianethier/Dropbox/Adaptation/Results/TrainDuration_[LR5e-7Delay600]/EMGPreds_vs_OptEMGPatterns/';
memg = zeros(n_tgts,n_emgs);
all_memg = zeros(n_tgts,n_emgs,n_datasets);

for dataset = 1:n_datasets
    
    predData = all_data.testdata{dataset};
    predData.emgdatabin = all_data.predsE_norm{dataset};

    predData.emgguide = e2f.emglabels;
    pred_stats = get_WF_stats(predData);
    
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
        R(tgt,dataset) = (Vopt*Vpred'/(norm(Vopt)*norm(Vpred)))^2;
        Rp(tgt,dataset) = corr(Vopt',Vpred','type','Pearson');
        rho(tgt,dataset) = corr(Vopt',Vpred','type','Spearman','rows','pairwise');
        tau(tgt,dataset) = corr(Vopt',Vpred','type','Kendall','rows','pairwise');
        
        % plot patterns
        if tgt == n_tgts
            ttl = sprintf('Center Target : R =%.2f',R(tgt,dataset));
            tgt_str = 'center';
        else
            ttl = sprintf('Target #%d : R=%.2f',tgt,R(tgt,dataset));
            tgt_str = ['tgt' num2str(tgt)];
        end
        title(ttl); axis square;
        mxy = 10; ylim([-mxy mxy]); xlim([-mxy mxy]);
        set(gca,'Box','Off',...
            'FontName','Arial','FontSize',16,'FontWeight','Bold','TickDir','Out');
        
        savefig(gcf,[save_path filesep all_data.filename{dataset} tgt_str ]);
    end
    all_memg(:,:,dataset) = memg;
    pause(1);
    close all;
end

all_opt   = repmat(opt_emgs,10,1);
all_memg2 = [];
for i = 1:n_datasets
    all_memg2 = [all_memg2; all_memg(:,:,i)];
end

Rp_all  = corr(all_opt,all_memg2);
rho_all = diag(corr(all_opt,all_memg2,'type','Spearman','rows','pairwise'));
tau_all = diag(corr(all_opt,all_memg2,'type','Kendall','rows','pairwise'));


%%---------------------------------------------------------------------------------%%
%% extract totals from online_stats and plot as bars
num_cond  = 3; % HC, BCopt, BCadapt
num_stats = 3; % RPM, T2T, PL
stats_name = {'RPM','T2T','PL'};

all_rpm = cell(1,num_cond);
all_t2t = cell(1,num_cond);
all_pl  = cell(1,num_cond);
stats_m = nan(num_stats,num_cond);
stats_se= nan(num_stats,num_cond);

for i = 1:size(online_stats,1)
    switch online_stats{i,3}
        case 'HC'
            all_rpm{1} = [all_rpm{1};online_stats{i,2}.succ_per_min{end}];
            all_t2t{1} = [all_t2t{1};online_stats{i,2}.time2target{end}];
            all_pl{1}  = [all_pl{1}; online_stats{i,2}.path_length{end}];
        case 'BCopt'
            all_rpm{2} = [all_rpm{2};online_stats{i,2}.succ_per_min{end}];
            all_t2t{2} = [all_t2t{2};online_stats{i,2}.time2target{end}];
            all_pl{2}  = [all_pl{2}; online_stats{i,2}.path_length{end}];
        case 'BCadapt'
            all_rpm{3} = [all_rpm{3};online_stats{i,2}.succ_per_min{end}];
            all_t2t{3} = [all_t2t{3};online_stats{i,2}.time2target{end}];
            all_pl{3}  = [all_pl{3}; online_stats{i,2}.path_length{end}];
    end
end

% ---------------
% ugly tweak to add pct_aborts, fail, succ, that were not calculated with
% eval_online_adapt.m (one value per condition, per dataset, instead of one
% value per file. There was typically 2 files for each condition per
% datasets).
num_stats = 6; % add pct_aborts, pct_fails, pct_succ
all_abort_pct = cell(1,num_cond);
all_fail_pct  = cell(1,num_cond);
all_succ_pct  = cell(1,num_cond);
stats_m = nan(num_stats,num_cond);
stats_se= nan(num_stats,num_cond);
stats_name = {'RPM','T2T','PL','Aborts','Fail','Succ'};

for ds = 7:10
    all_abort_pct{1} = [all_abort_pct{1};all_data.BC_HC{ds}.trials.n_aborts / ...
                                         all_data.BC_HC{ds}.trials.n_tot];
    all_fail_pct{1}  = [all_fail_pct{1}; all_data.BC_HC{ds}.trials.n_fail / ...
                                         all_data.BC_HC{ds}.trials.n_tot];
    all_succ_pct{1}  = [all_succ_pct{1}; all_data.BC_HC{ds}.trials.n_succ / ...
                                         all_data.BC_HC{ds}.trials.n_tot];
                                     
    all_abort_pct{2} = [all_abort_pct{2};all_data.BC_opt{ds}.trials.n_aborts / ...
                                         all_data.BC_opt{ds}.trials.n_tot];
    all_fail_pct{2}  = [all_fail_pct{2}; all_data.BC_opt{ds}.trials.n_fail / ...
                                         all_data.BC_opt{ds}.trials.n_tot];
    all_succ_pct{2}  = [all_succ_pct{2}; all_data.BC_opt{ds}.trials.n_succ / ...
                                         all_data.BC_opt{ds}.trials.n_tot];                                    
    
    all_abort_pct{3} = [all_abort_pct{3};all_data.BC_Adapt{ds}.trials.n_aborts / ...
                                         all_data.BC_Adapt{ds}.trials.n_tot];
    all_fail_pct{3}  = [all_fail_pct{3}; all_data.BC_Adapt{ds}.trials.n_fail / ...
                                         all_data.BC_Adapt{ds}.trials.n_tot];
    all_succ_pct{3}  = [all_succ_pct{3}; all_data.BC_Adapt{ds}.trials.n_succ / ...
                                         all_data.BC_Adapt{ds}.trials.n_tot];
end
% 
%---------
for i = 1:num_cond
    stats_m(:,i)  = [mean(all_rpm{i}); mean(all_t2t{i}); mean(all_pl{i}); ...
                     mean(all_abort_pct{i}); mean(all_fail_pct{i}); mean(all_succ_pct{i})];
    stats_se(:,i) = [ std(all_rpm{i})/sqrt(length(all_rpm{i}));...
                      std(all_t2t{i})/sqrt(length(all_t2t{i}));...
                      std(all_pl{i}) /sqrt(length(all_pl{i})) ;...
                      std(all_abort_pct{i})/sqrt(length(all_abort_pct{i}));...
                      std(all_fail_pct{i}) /sqrt(length(all_fail_pct{i}));...
                      std(all_succ_pct{i}) /sqrt(length(all_succ_pct{i}))    ];
end

 
% for i = 1:num_cond
%     stats_m(:,i)  = [mean(all_rpm{i}); mean(all_t2t{i}); mean(all_pl{i})];
%     stats_se(:,i) = [ std(all_rpm{i})/sqrt(length(all_rpm{i}));...
%                       std(all_t2t{i})/sqrt(length(all_t2t{i}));...
%                       std(all_pl{i}) /sqrt(length(all_pl{i})) ];
% end

for i = 1:num_stats
    figure;
    barwitherr(2*stats_se(i,:),stats_m(i,:));
    pretty_fig(gca);legend('Average','2xSE');
    set(gca,'XTickLabel',{'HC','BCopt','BCadapt'});
    title(stats_name{i});
end

%t-tests:
[H,P,CI,STATS] = ttest2(all_rpm{1}',all_rpm{2}');
[H,P,CI,STATS] = ttest2(all_rpm{2}',all_rpm{3}');

%% Calculate number of aborts and failures

Adapt_totals = struct('n_aborts',0,'n_fail',0,'n_succ',0,'n_tot',0);
HC_totals = struct('n_aborts',0,'n_fail',0,'n_succ',0,'n_tot',0);
opt_totals = struct('n_aborts',0,'n_fail',0,'n_succ',0,'n_tot',0);

for i = 7:10
    all_data.BC_Adapt{i}.trials.n_aborts = sum(all_data.BC_Adapt{i}.trialtable(:,9)==double('A'));
    all_data.BC_Adapt{i}.trials.n_fail   = sum(all_data.BC_Adapt{i}.trialtable(:,9)==double('F'));
    all_data.BC_Adapt{i}.trials.n_succ   = sum(all_data.BC_Adapt{i}.trialtable(:,9)==double('R'));
    all_data.BC_Adapt{i}.trials.n_tot    = size(all_data.BC_Adapt{i}.trialtable,1);
    
    Adapt_totals.n_aborts = Adapt_totals.n_aborts + all_data.BC_Adapt{i}.trials.n_aborts;
    Adapt_totals.n_fail   = Adapt_totals.n_fail + all_data.BC_Adapt{i}.trials.n_fail;
    Adapt_totals.n_succ   = Adapt_totals.n_succ + all_data.BC_Adapt{i}.trials.n_succ;
    Adapt_totals.n_tot    = Adapt_totals.n_tot + all_data.BC_Adapt{i}.trials.n_tot;
    
    all_data.BC_opt{i}.trials.n_aborts = sum(all_data.BC_opt{i}.trialtable(:,9)==double('A'));
    all_data.BC_opt{i}.trials.n_fail   = sum(all_data.BC_opt{i}.trialtable(:,9)==double('F'));
    all_data.BC_opt{i}.trials.n_succ   = sum(all_data.BC_opt{i}.trialtable(:,9)==double('R'));
    all_data.BC_opt{i}.trials.n_tot    = size(all_data.BC_opt{i}.trialtable,1);
    
    opt_totals.n_aborts = opt_totals.n_aborts + all_data.BC_opt{i}.trials.n_aborts;
    opt_totals.n_fail   = opt_totals.n_fail + all_data.BC_opt{i}.trials.n_fail;
    opt_totals.n_succ   = opt_totals.n_succ + all_data.BC_opt{i}.trials.n_succ;
    opt_totals.n_tot    = opt_totals.n_tot + all_data.BC_opt{i}.trials.n_tot;
    
    all_data.BC_HC{i}.trials.n_aborts = sum(all_data.BC_HC{i}.trialtable(:,9)==double('A'));
    all_data.BC_HC{i}.trials.n_fail   = sum(all_data.BC_HC{i}.trialtable(:,9)==double('F'));
    all_data.BC_HC{i}.trials.n_succ   = sum(all_data.BC_HC{i}.trialtable(:,9)==double('R'));
    all_data.BC_HC{i}.trials.n_tot    = size(all_data.BC_HC{i}.trialtable,1);
    
    HC_totals.n_aborts = HC_totals.n_aborts + all_data.BC_HC{i}.trials.n_aborts;
    HC_totals.n_fail   = HC_totals.n_fail + all_data.BC_HC{i}.trials.n_fail;
    HC_totals.n_succ   = HC_totals.n_succ + all_data.BC_HC{i}.trials.n_succ;
    HC_totals.n_tot    = HC_totals.n_tot + all_data.BC_HC{i}.trials.n_tot;
end

Adapt_totals.n_aborts_pct = Adapt_totals.n_aborts/Adapt_totals.n_tot;
Adapt_totals.n_fail_pct = Adapt_totals.n_fail/Adapt_totals.n_tot;
Adapt_totals.n_succ_pct = Adapt_totals.n_succ/Adapt_totals.n_tot;

opt_totals.n_aborts_pct = opt_totals.n_aborts/opt_totals.n_tot;
opt_totals.n_fail_pct = opt_totals.n_fail/opt_totals.n_tot;
opt_totals.n_succ_pct = opt_totals.n_succ/opt_totals.n_tot;

HC_totals.n_aborts_pct = HC_totals.n_aborts/HC_totals.n_tot;
HC_totals.n_fail_pct = HC_totals.n_fail/HC_totals.n_tot;
HC_totals.n_succ_pct = HC_totals.n_succ/HC_totals.n_tot;

%% Calculate gain difference

go = nan(10,2);
ga = nan(10,2);
fmin = 4;
for i = 1:10
    % magnitude
%     f_act = sqrt(sum(all_data.testdata{i}.cursorposbin.^2,2));
%     f_pred_o = sqrt(sum(all_data.predsF_opt{i}.^2,2));
%     f_pred_a = sqrt(sum(all_data.predsF_norm{i}.^2,2));

    % x vs y
%     f_act_x = all_data.testdata{i}.cursorposbin(:,1);
%     f_act_y = all_data.testdata{i}.cursorposbin(:,2);
%     f_pred_ox = all_data.predsF_opt{i}(:,1);
%     f_pred_oy = all_data.predsF_opt{i}(:,2);
%     f_pred_ax = all_data.predsF_norm{i}(:,1);
%     f_pred_ay = all_data.predsF_norm{i}(:,2);
    
    % x vs y for actual force > fmin
    f_act_x = all_data.testdata{i}.cursorposbin(abs(all_data.testdata{i}.cursorposbin(:,1))>fmin,1);
    f_act_y = all_data.testdata{i}.cursorposbin(abs(all_data.testdata{i}.cursorposbin(:,2))>fmin,2);
    f_pred_ox = all_data.predsF_opt{i}(abs(all_data.testdata{i}.cursorposbin(:,1))>fmin,1);
    f_pred_oy = all_data.predsF_opt{i}(abs(all_data.testdata{i}.cursorposbin(:,2))>fmin,2);
    f_pred_ax = all_data.predsF_norm{i}(abs(all_data.testdata{i}.cursorposbin(:,1))>fmin,1);
    f_pred_ay = all_data.predsF_norm{i}(abs(all_data.testdata{i}.cursorposbin(:,2))>fmin,2);
    
    Pox = fit(f_act_x,f_pred_ox,'poly1');
%     CI  = confint(Pox); 
    Poy = fit(f_act_y,f_pred_oy,'poly1');
    Pax = fit(f_act_x,f_pred_ax,'poly1');
    Pay = fit(f_act_y,f_pred_ay,'poly1');
    
    go(i,1) = Pox.p1;
    go(i,2) = Poy.p1;
    ga(i,1) = Pax.p1;
    ga(i,2) = Pay.p1;
end
    

%% Calculate pd distribution

N2F_lag = 3; %150ms
num_btstrp = 100; %num bootstrap rep
for i = 1:10   
    neural_tuning = compute_tuning_from_bin(all_data.traindata{i},'pos',N2F_lag,num_btstrp,'poisson');
    
    pd_table = get_pd_table(neural_tuning);
    all_data.pd_table{i} = pd_table;
%     pd_table_deg = pd_table;
%     pd_table_deg(pd_table_deg<0) = 2*pi()+pd_table_deg(pd_table_deg<0);
%     pd_table_deg = rad2deg(pd_table_deg);
   
    plot_pds(pd_table);
end

%% Prediction error for each target, all datasets

n_tgt  = 8;
ds     = [1:3 7:10];
n_ds   = length(ds);
mse_ot = nan(n_ds,n_tgt);
all_pds = [];
for i = 1:n_ds
    
    [~, ot_i, ~] = get_epochs_data_idx(all_data.testdata{ds(i)},0.6,0);
    
    for t = 1:n_tgt
        mse_ot(i,t) = mean(sum( (all_data.testdata{ds(i)}.cursorposbin(ot_i(:,t),:)-all_data.predsF_opt{ds(i)}(ot_i(:,t),:)).^2,2));
    end
    all_pds = [all_pds; all_data.pd_table{ds(i)}.dir];
end
% m_mse_ot = mean(mse_ot);
m_mse_ot = m_mse_ot*2; % to get similar scale as pds;

rose(all_pds);
hold on;
polar((0:8)*pi()/4,[m_mse_ot(1:end) m_mse_ot(1)],'o-r');

%% PD vs MSE for individual datasets
n_tgt  = 8;
n_ds   = 10;
mse_ot = nan(n_ds,n_tgt);
for i = 1:n_ds
    
    pds = all_data.pd_table{i}.dir;
    
    [~, ot_i, ~] = get_epochs_data_idx(all_data.testdata{i},0.6,0);
    for t = 1:n_tgt
        mse_ot(i,t) = mean(sum( (all_data.testdata{i}.cursorposbin(ot_i(:,t),:)-all_data.predsF_opt{i}(ot_i(:,t),:)).^2,2));
    end
    
    figure; hold on;
    polar((0:8)*pi()/4,[mse_ot(i,1:end)/2 mse_ot(i,1)/2],'o-r');
    rose(pds);
    title(sprintf('dataset %d',i));
end    


