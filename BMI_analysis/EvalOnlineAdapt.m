function [adapt_stats,offline_stats] = EvalOnlineAdapt(binnedData, varargin)

offset_x = 6;
offset_y = 1.55;
cursgain = 55;
fix_time = 1188;
plotflag = 1;

if nargin >1
    plotflag = varargin{1};
end
if nargin>2
    offline_decoder = varargin{2};
else
    binnedData = set_catch_states(binnedData);
    options.PredCursPos = 1; options.Use_SD = 1;
    OfflineDecoder = BuildSDModel(binnedData, options);
    offline_decoder = OfflineDecoder{1};
end

offline_preds   = predictSignals(offline_decoder,binnedData);

% scale force to cursor pos
actual_force    = [binnedData.forcedatabin(:,1)/cursgain+offset_x ...
                    binnedData.forcedatabin(:,2)/cursgain+offset_y];
 

num_adapt = sum(binnedData.trialtable(:,12));
num_trials= size(binnedData.trialtable,1);

catch_trial_times = [binnedData.trialtable(binnedData.trialtable(:,12)==1,1) ... 
                      binnedData.trialtable(binnedData.trialtable(:,12)==1,8)];             
                  
adapt_stats = zeros(num_adapt,3,2);
offline_stats= zeros(num_adapt,3,2);

if plotflag
    figure; hold on; fig_x = gca;
    figure; hold on; fig_y = gca;
end
    
for i = 1:num_adapt
    catch_idx = binnedData.timeframe>catch_trial_times(i,1) & ...
                binnedData.timeframe<catch_trial_times(i,2);
    Act = actual_force(catch_idx,:);
    
    Curs= binnedData.cursorposbin(catch_idx,:);
    
    catch_idx = offline_preds.timeframe>=catch_trial_times(i,1) & ...
                offline_preds.timeframe<=catch_trial_times(i,2);
            
    Preds= offline_preds.preddatabin(catch_idx,:);
            
    adapt_stats(i,1,:) = CalculateR2(Act,Curs);
    adapt_stats(i,2,:) = 1-  sum( (Curs-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
    adapt_stats(i,3,:) = mean((Curs-Act).^2);
    
    offline_stats(i,1,:) = CalculateR2(Act,Preds);
    offline_stats(i,2,:) = 1-  sum( (Preds-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
    offline_stats(i,3,:) = mean((Preds-Act).^2);
    
    if plotflag
        xx = binnedData.timeframe(catch_idx);
        ytop = 10*ones(length(xx),1);
        ybot = -ytop;
        yarea = [ytop; ybot(end:-1:1)];
        xx = [xx; xx(end:-1:1)];
        area(fig_x,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        area(fig_y,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        
        plot(fig_x, binnedData.timeframe(catch_idx),binnedData.cursorposbin(catch_idx,1),'b');
        plot(fig_y, binnedData.timeframe(catch_idx),binnedData.cursorposbin(catch_idx,2),'b');
    
    end
end

if plotflag
    plot(fig_x,binnedData.timeframe,actual_force(:,1),'k'); title(fig_x,'Force X');
    plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
    plot(fig_y,binnedData.timeframe,actual_force(:,2),'k'); title(fig_y,'Force Y');
    plot(fig_y,offline_preds.timeframe,offline_preds.preddatabin(:,2),'r');

    last_adapt_trial = find(catch_trial_times(:,2)<=fix_time,1,'last');
    plot(fig_x,[catch_trial_times(last_adapt_trial,2) catch_trial_times(last_adapt_trial,2)],...
          ylim(),'k--','LineWidth',2);
%       legend(fig_x,'online adapt preds','actual force','offline predictions');
    plot(fig_y,[catch_trial_times(last_adapt_trial,2) catch_trial_times(last_adapt_trial,2)],...
          ylim(),'k--','LineWidth',2);  
%       legend(fig_y,'online adapt preds','actual force','offline predictions');

    figure; x_vaf =gca; hold on;
    plot(x_vaf,1:num_adapt,offline_stats(:,2,1),'ro-','LineWidth',2); title('vaf X');
    plot(x_vaf,1:num_adapt,adapt_stats(:,2,1),'bo-','LineWidth',2);
    plot(x_vaf,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; y_vaf = gca; hold on;
    plot(y_vaf,1:num_adapt,offline_stats(:,2,2),'ro-','LineWidth',2); title('vaf Y');
    plot(y_vaf,1:num_adapt,adapt_stats(:,2,2),'bo-','LineWidth',2);
    plot(y_vaf,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; x_R2 =gca; hold on;
    plot(x_R2,1:num_adapt,offline_stats(:,1,1),'ro-','LineWidth',2); title('R^2 X');
    plot(x_R2,1:num_adapt,adapt_stats(:,1,1),'bo-','LineWidth',2);
    plot(x_R2,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; y_R2 = gca; hold on;
    plot(y_R2,1:num_adapt,offline_stats(:,1,2),'ro-','LineWidth',2); title('R^2 Y');
    plot(y_R2,1:num_adapt,adapt_stats(:,1,2),'bo-','LineWidth',2);
    plot(y_R2,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; x_mse =gca; hold on;
    plot(x_mse,1:num_adapt,offline_stats(:,3,1),'ro-','LineWidth',2); title('mse X');
    plot(x_mse,1:num_adapt,adapt_stats(:,3,1),'bo-','LineWidth',2);
    plot(x_mse,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
    
    figure; y_mse = gca; hold on;
    plot(y_mse,1:num_adapt,offline_stats(:,3,2),'ro-','LineWidth',2); title('mse Y');
    plot(y_mse,1:num_adapt,adapt_stats(:,3,2),'bo-','LineWidth',2);
    plot(y_mse,[last_adapt_trial last_adapt_trial],ylim(),'k--','LineWidth',2);
    legend('offline training','online adaptation');
end

% 
% for i = 1:num_trials-num_catch
%     norm_idx = binnedData.timeframe>=normal_trial_times(i,1) & ...
%                 binnedData.timeframe<=normal_trial_times(i,2);
%     Act = actual_force(norm_idx,:);
%     
%     norm_idx = offline_preds.timeframe>=normal_trial_times(i,1) & ...
%                 offline_preds.timeframe<=normal_trial_times(i,2);
%     Pred= offline_preds.preddatabin(norm_idx,:);
%             
%     normal_stats(i,1,:) = CalculateR2(Act,Pred);
%     normal_stats(i,2,:) = 1-  sum( (Pred-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
% end