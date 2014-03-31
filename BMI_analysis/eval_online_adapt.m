function [stats] = eval_online_adapt

% all_data is a matlab file containing structures of all the data files recorded during the adaptation process
% it also contains an array named 'file_type_idx', describing the length of type of behavior during each of
% these files in chronological order (which should also be alphabethical order of structure names).
% the behavior code in file_type_idx are
% 1- Hand Control
% 2- Brain Control with decoder trained offline
% 3- Brain Control with decoder trained online during adaptive process
% 4- Adaptive process (hand control and cursor assist)

workspace = 'base';
    
all_data = evalin(workspace,'who(''Jango*'')');
plot_flag = true;

%% adapt_data already loaded in workspace. Calculate Stats

num_files = length(all_data);

all_stats = cell(num_files,2);

for i = 1:num_files
    all_stats{i,1} = all_data{i};
    all_stats{i,2} = get_WF_stats(evalin(workspace,all_data{i}));
end

%% plot performance for brain-control blocks:
file_type_idx = evalin(workspace,'file_type_idx');
HC_idx = find(file_type_idx ==1);
BCoff_idx = find(file_type_idx ==2);
BCadapt_idx = find(file_type_idx ==3);
Adapt_idx = find(file_type_idx ==4);

succ_rate   = nan(num_files,1);
succ_per_min= nan(num_files,1);
succ_per_min_sd = nan(num_files,1);
path_length = nan(num_files,1);
time2target = nan(num_files,1);
num_reentries = nan(num_files,1);
path_length_sd = nan(num_files,1);
time2target_sd = nan(num_files,1);
num_reentries_sd = nan(num_files,1);

for i = 1:num_files
    succ_rate(i)        = all_stats{i,2}.succ_rate(9);
    succ_per_min(i)     = mean(all_stats{i,2}.succ_per_min{9});
    succ_per_min_sd(i)  = std(all_stats{i,2}.succ_per_min{9});
    path_length(i)      = mean(all_stats{i,2}.path_length{9});
    path_length_sd(i)   = std(all_stats{i,2}.path_length{9});
    time2target(i)      = mean(all_stats{i,2}.time2target{9});
    time2target_sd(i)   = std(all_stats{i,2}.time2target{9});
    num_reentries(i)    = mean(all_stats{i,2}.num_reentries{9});
    num_reentries_sd(i) = std(all_stats{i,2}.num_reentries{9});
end

% success rate
figure; hold on;
plot(HC_idx, succ_rate(HC_idx),'-ko','linewidth',2,'markerfacecolor','k');
ylim([0 1]);
xlim([0 num_files+1]);
plot(BCoff_idx, succ_rate(BCoff_idx),'-bo','linewidth',2,'markerfacecolor','b');
plot(BCadapt_idx, succ_rate(BCadapt_idx),'-ro','linewidth',2,'markerfacecolor','r');
ylabel('% success'); legend('Hand Control','BC - calculated decoder','BC - adaptive decoder');

% success per min
figure; hold on;
errorbar(HC_idx,succ_per_min(HC_idx),succ_per_min_sd(HC_idx),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(BCoff_idx,succ_per_min(BCoff_idx),succ_per_min_sd(BCoff_idx),'-bo','linewidth',2,'markerfacecolor','b');
errorbar(BCadapt_idx,succ_per_min(BCadapt_idx),succ_per_min_sd(BCadapt_idx),'-ro','linewidth',2,'markerfacecolor','r');
xlim([0 num_files+1]);
ylabel('rewards per minute'); legend('Hand control', 'BC - calculated decoder','BC - adaptive decoder');

% path length
figure; hold on;
errorbar(HC_idx,path_length(HC_idx),path_length_sd(HC_idx),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(BCoff_idx,path_length(BCoff_idx),path_length_sd(BCoff_idx),'-bo','linewidth',2,'markerfacecolor','b');
errorbar(BCadapt_idx,path_length(BCadapt_idx),path_length_sd(BCadapt_idx),'-ro','linewidth',2,'markerfacecolor','r');
xlim([0 num_files+1]);
ylabel('path length'); legend('Hand control', 'BC - calculated decoder','BC - adaptive decoder');

% time2target
figure; hold on;
errorbar(HC_idx,time2target(HC_idx),time2target_sd(HC_idx),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(BCoff_idx,time2target(BCoff_idx),time2target_sd(BCoff_idx),'-bo','linewidth',2,'markerfacecolor','b');
errorbar(BCadapt_idx,time2target(BCadapt_idx),time2target_sd(BCadapt_idx),'-ro','linewidth',2,'markerfacecolor','r');
xlim([0 num_files+1]);
ylabel('time to target'); legend('Hand control', 'BC - calculated decoder','BC - adaptive decoder');

% num_reentries
figure; hold on;
errorbar(HC_idx,num_reentries(HC_idx),num_reentries_sd(HC_idx),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(BCoff_idx,num_reentries(BCoff_idx),num_reentries_sd(BCoff_idx),'-bo','linewidth',2,'markerfacecolor','b');
errorbar(BCadapt_idx,num_reentries(BCadapt_idx),num_reentries_sd(BCadapt_idx),'-ro','linewidth',2,'markerfacecolor','r');
xlim([0 num_files+1]);
ylabel('number of re-entries per target'); legend('Hand control', 'BC - calculated decoder','BC - adaptive decoder');

%% eval pred accuracy during hand control trials (adapt_files):

figure; hold on; mse_stat_fig = gca; ylim([0 80]); title('Adaptive Decoder MSE during HC');
figure; hold on; R2_stat_fig = gca; ylim([0 1]); title('Adaptive Decoder R^2 during HC');
figure; hold on; vaf_stat_fig = gca; ylim([-5 1]); title('Adaptive Decoder VAF during HC');
x_trial_idx = 0;

for file = 1:length(Adapt_idx)
    
    adapt_file_label = strrep(all_data{Adapt_idx(file)},'_','\_');
    adapt_data = evalin(workspace,all_data{Adapt_idx(file)});
    
    offset_x = 6   + 0.25;
    offset_y = 1.6 + 0.25;
    cursgain = 55;
    
    figure; hold on; fig_x = gca;
    figure; hold on; fig_y = gca;
    
    % scale force to cursor pos
    actual_force = [adapt_data.forcedatabin(:,1)/cursgain+offset_x ...
        adapt_data.forcedatabin(:,2)/cursgain+offset_y];
    
    num_HC = sum(~adapt_data.trialtable(:,12));
    HC_idx    = find(~adapt_data.trialtable(:,12));
    
    num_trials= size(adapt_data.trialtable,1);
    
    % adapt_trial_times = [adapt_data.trialtable(adapt_data.trialtable(:,12)==1,1) ...
    %                       adapt_data.trialtable(adapt_data.trialtable(:,12)==1,8)];
    % adapt_idx = find(adapt_data.trialtable(:,12));
    
    HC_trials_start = adapt_data.trialtable(HC_idx,1);
    
    % Calculate stats until end of trial or beginning of next trial?
    if HC_idx(end) == num_trials
        last_stop = adapt_data.trialtable(HC_idx(end),8);
    else
        last_stop = adapt_data.trialtable(HC_idx(end)+1,1);
    end
    
    HC_trials_stop  = [adapt_data.trialtable(HC_idx(1:end-1)+1,1); last_stop];
    
    HC_trial_times = [HC_trials_start HC_trials_stop];
    
    stats = zeros(num_HC,3,2);
    %     offline_stats= zeros(num_HC,3,2);
    
    for i = 1:num_HC
        
        trial_bins = adapt_data.timeframe>HC_trial_times(i,1) & ...
            adapt_data.timeframe<HC_trial_times(i,2);
        
        act = double(actual_force(trial_bins,:));
        preds = adapt_data.cursor_preds(trial_bins,:);
        
        stats(i,1,:) = CalculateR2(act,preds);
        stats(i,2,:) = 1-  sum( (preds-act).^2 ) ./ sum( (act - repmat(mean(act),size(act,1),1)).^2);
        stats(i,3,:) = mean((preds-act).^2);
        
        %     offline_stats(i,1,:) = CalculateR2(act,off_preds);
        %     offline_stats(i,2,:) = 1-  sum( (off_preds-act).^2 ) ./ sum( (act - repmat(mean(act),size(act,1),1)).^2);
        %     offline_stats(i,3,:) = mean((off_preds-act).^2);
        %
        if plot_flag
            xx = adapt_data.timeframe(trial_bins);
            ytop = 15*ones(length(xx),1);
            ybot = -ytop;
            yarea = [ytop; ybot(end:-1:1)];
            xx = [xx; xx(end:-1:1)];
            area(fig_x,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
            area(fig_y,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        end
    end
    
    
    if plot_flag
        plot(fig_x, adapt_data.timeframe,adapt_data.cursorposbin(:,1),'g');
        plot(fig_x, adapt_data.timeframe,adapt_data.cursor_preds(:,1),'r');
        plot(fig_x,adapt_data.timeframe,actual_force(:,1),'k');
        %     plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
        title(fig_x,sprintf('Force X\n%s',adapt_file_label)); ylim([-15 15]);
        
        plot(fig_y, adapt_data.timeframe,adapt_data.cursorposbin(:,2),'g');
        plot(fig_y, adapt_data.timeframe,adapt_data.cursor_preds(:,2),'r');
        plot(fig_y,adapt_data.timeframe,actual_force(:,2),'k');
        %     plot(fig_y,offline_preds.timeframe,offline_preds.preddatabin(:,2),'r');
        title(fig_y,sprintf('Force Y\n%s',adapt_file_label)); ylim([-15 15]);
        
        % average x and y stats before plotting
        mas = nan(size(stats,1),3);
        %         mos = nan(size(offline_stats,1),3);
        for i = 1:3
            mas(:,i,:)= mean(stats(:,i,:),3);
            %             mos(:,i,:)= mean(offline_stats(:,i,:),3);
        end
        
        xx = x_trial_idx+(1:num_HC);
        x_trial_idx = xx(end);
        
        plot(R2_stat_fig,xx,stats(:,1),'b','LineWidth',2);
        plot(vaf_stat_fig,xx,stats(:,2),'b','LineWidth',2);
        plot(mse_stat_fig,xx,stats(:,3),'b','LineWidth',2);
        % plot vertical lines separating adapt sessions
        plot(R2_stat_fig,[xx(end) xx(end)],ylim,'--k');
        plot(vaf_stat_fig,[xx(end) xx(end)],ylim,'--k');
        plot(mse_stat_fig,[xx(end) xx(end)],ylim,'--k');
        %     plot_adapt_stats(smoothCE(mas),adapt_file_label);
        
        
        %     masR2 = mean(adapt_stats(:,1,:),3);
        %     mosR2 = mean(offline_stats(:,1,:),3);
        %
        %     % plot_adapt_stats(smooth(mos),smooth(mas));
        %     figure; plot([smoothCE(masR2) smoothCE(mosR2)]);
        %     title('smoothed R2');legend('online adapt','offline training');
        %     figure; plot(smoothCE(masR2)./smoothCE(mosR2));
        %     title('R2 ratio, adapt/training');
        
    end
    
end


% %%
%--------------------------------
% as = adapt_stats(1:end-4,:,:);
% os = offline_stats(1:end-4,:,:);
%
% mov_window = 5;
%
% mas = mean(as(:,1,:),3);
% mos = mean(os(:,1,:),3);
%
% % plot_adapt_stats(smooth(mos),smooth(mas));
% plot([smoothCE(mas) smoothCE(mos)]);
% figure; plot(smoothCE(mas)./smoothCE(mos));
%
% num_adapt = size(as,1);
%
% movav_adapt_stats   = zeros(num_adapt-mov_window,3,1);
% movav_offline_stats = zeros(num_adapt-mov_window,3,1);
%
% for i = 1:num_adapt-mov_window
% %     movav_adapt_stats(i,:,:)  = mean(mas(i:i+mov_window,:,:));
% %     movav_offline_stats(i,:,:)= mean(mos(i:i+mov_window,:,:));
%
%     movav_adapt_stats(i,:,:)  = mean(mas(i:i+mov_window,:,:));
%     movav_offline_stats(i,:,:)= mean(mos(i:i+mov_window,:,:));
%
% end
%
% plot_adapt_stats(movav_offline_stats,movav_adapt_stats);
