function [stats] = eval_online_adapt(varargin)

if nargin
    all_data_filename = varargin{1};
    load(all_data_filename);
end

all_data = who;

%% adapt_data already loaded in workspace. Calculate Stats

num_files = length(all_data); 

all_stats = cell(num_files,2);

for i = 1:num_files
    all_stats{i,1} = all_data{i};
    all_stats{i,2} = get_WF_stats(eval(all_data{i}));
end

%% plot performance for brain-control blocks:
BC_file_idx = [2 4 5 7 9 10 12 14 15 17 19];

num_Adapt_BC_files = length(BC_file_idx);

succ_rate   = nan(num_Adapt_BC_files,1);
succ_per_min= nan(num_Adapt_BC_files,1);
succ_per_min_sd = nan(num_Adapt_BC_files,1);
path_length = nan(num_Adapt_BC_files,1);
time2target = nan(num_Adapt_BC_files,1);
num_reentries = nan(num_Adapt_BC_files,1);
path_length_sd = nan(num_Adapt_BC_files,1);
time2target_sd = nan(num_Adapt_BC_files,1);
num_reentries_sd = nan(num_Adapt_BC_files,1);

for i = 1:num_Adapt_BC_files 
    succ_rate(i)        = all_stats{BC_file_idx(i),2}.succ_rate(9);
    succ_per_min(i)     = mean(all_stats{BC_file_idx(i),2}.succ_per_min{9});
    succ_per_min_sd(i)  = std(all_stats{BC_file_idx(i),2}.succ_per_min{9});
    path_length(i)      = mean(all_stats{BC_file_idx(i),2}.path_length{9});
    path_length_sd(i)   = std(all_stats{BC_file_idx(i),2}.path_length{9});
    time2target(i)      = mean(all_stats{BC_file_idx(i),2}.time2target{9});
    time2target_sd(i)   = std(all_stats{BC_file_idx(i),2}.time2target{9});
    num_reentries(i)    = mean(all_stats{BC_file_idx(i),2}.num_reentries{9});
    num_reentries_sd(i) = std(all_stats{BC_file_idx(i),2}.num_reentries{9});
end

xx = 1:num_Adapt_BC_files;

% success rate
figure; hold on;
plot(0, HC_stats.succ_rate(9),'-ko','linewidth',2,'markerfacecolor','k');
ylim([0 1]);
xlim([-1 num_Adapt_BC_files+1]);
plot(0, BCoff_stats.succ_rate(9),'-bo','linewidth',2,'markerfacecolor','b');
plot(xx, succ_rate,'-ro','linewidth',2,'markerfacecolor','r');
ylabel('% success'); legend('Hand Control','BC - calculated decoder','BC - adaptive decoder');

% success per min
figure; hold on;
errorbar(xx,succ_per_min,succ_per_min_sd,'-rs','linewidth',2,'markerfacecolor','r');
xlim([-1 num_Adapt_BC_files+1]);
errorbar(0, mean(HC_stats.succ_per_min{9}),std(HC_stats.succ_per_min{9}),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(0, mean(BCoff_stats.succ_per_min{9}),std(BCoff_stats.succ_per_min{9}),'-bo','linewidth',2,'markerfacecolor','b');
ylabel('rewards per minute'); legend('BC - adaptive decoder','Hand Control','BC - calculated decoder');

% path length
figure; hold on;
errorbar(xx,path_length,path_length_sd,'-rs','linewidth',2,'markerfacecolor','r');
xlim([-1 num_Adapt_BC_files+1]);
errorbar(0, mean(HC_stats.path_length{9}),std(HC_stats.path_length{9}),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(0, mean(BCoff_stats.path_length{9}),std(BCoff_stats.path_length{9}),'-bo','linewidth',2,'markerfacecolor','b');
ylabel('path length'); legend('BC - adaptive decoder','Hand Control','BC - calculated decoder');

% time2target
figure; hold on;
errorbar(xx,time2target,time2target_sd,'-rs','linewidth',2,'markerfacecolor','r');
xlim([-1 num_Adapt_BC_files+1]);
errorbar(0, mean(HC_stats.time2target{9}),std(HC_stats.time2target{9}),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(0, mean(BCoff_stats.time2target{9}),std(BCoff_stats.time2target{9}),'-bo','linewidth',2,'markerfacecolor','b');
ylabel('time to target'); legend('BC - adaptive decoder','Hand Control','BC - calculated decoder');

% num_reentries
figure; hold on;
errorbar(xx,num_reentries,num_reentries_sd,'-rs','linewidth',2,'markerfacecolor','r');
xlim([-1 num_Adapt_BC_files+1]);
errorbar(0, mean(HC_stats.num_reentries{9}),std(HC_stats.num_reentries{9}),'-ko','linewidth',2,'markerfacecolor','k');
errorbar(0, mean(BCoff_stats.num_reentries{9}),std(BCoff_stats.num_reentries{9}),'-bo','linewidth',2,'markerfacecolor','b');
ylabel('number of re-entries per target'); legend('BC - adaptive decoder','Hand Control','BC - calculated decoder');

%% eval pred accuracy during hand control trials (adapt_files):
Adapt_file_idx = find(~ismember(1:19,BC_file_idx));
plot_flag = true;

for file = 1:length(Adapt_file_idx)
    
    adapt_file_label = strrep(all_data{Adapt_file_idx(file)},'_','\_');
    adapt_data = eval(all_data{Adapt_file_idx(file)});
    
    offset_x = 8   + 0.25;
    offset_y = 1.6 + 0.25;
    cursgain = 55;
    
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
    
    if HC_idx(end) == num_trials
        last_stop = adapt_data.trialtable(HC_idx(end),8);
    else
        last_stop = adapt_data.trialtable(HC_idx(end)+1,1);
    end
    
    HC_trials_stop  = [adapt_data.trialtable(HC_idx(1:end-1)+1,1); last_stop];
    
    HC_trial_times = [HC_trials_start HC_trials_stop];
    
    stats = zeros(num_HC,3,2);
%     offline_stats= zeros(num_HC,3,2);
    
    if plot_flag
        figure; hold on; fig_x = gca;
        figure; hold on; fig_y = gca;
    end
    
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
            
            plot(fig_x, adapt_data.timeframe(trial_bins),adapt_data.cursorposbin(trial_bins,1),'b');
            plot(fig_x, adapt_data.timeframe(trial_bins),preds(:,1),'m');
            plot(fig_y, adapt_data.timeframe(trial_bins),adapt_data.cursorposbin(trial_bins,2),'b');
            plot(fig_y, adapt_data.timeframe(trial_bins),preds(:,2),'m');
            
        end
    end
    
    if plot_flag
        
        plot(fig_x,adapt_data.timeframe,actual_force(:,1),'k');
        %     plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
        title(fig_x,sprintf('Force X\n%s',adapt_file_label)); ylim([-15 15]);
        
        
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
        
        plot_adapt_stats(smoothCE(mas),adapt_file_label);
        
        
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
