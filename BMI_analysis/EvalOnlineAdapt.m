function [adapt_stats,offline_stats] = EvalOnlineAdapt(binnedData, varargin)

offset_x = 6;
offset_y = 1.55;
cursgain = 55;
fix_time = 1188;
plotflag = 1;

if nargin >1
    plotflag = varargin{1};
end

binnedData = set_catch_states(binnedData);

options.PredCursPos = 1; options.Use_SD = 1;
OfflineDecoder = BuildSDModel(binnedData, options);

offline_decoder = OfflineDecoder{2};

offline_preds   = predictSignals(offline_decoder,binnedData);

% scale force to cursor pos
actual_force    = [binnedData.forcedatabin(:,1)/cursgain+offset_x ...
                    binnedData.forcedatabin(:,2)/cursgain+offset_y];
 

num_catch = sum(binnedData.trialtable(:,12));
num_trials= size(binnedData.trialtable,1);

catch_trial_times = [binnedData.trialtable(binnedData.trialtable(:,11)==1,7) ... 
                      binnedData.trialtable(binnedData.trialtable(:,11)==1,8)];

adapt_stats = zeros(num_catch,2,2);
offline_stats= zeros(num_trials-num_catch,2,2);

if plotflag
    fig_x = figure; hold on;
    fig_y = figure; hold on;

    plot(fig_x,binnedData.timeframe,actual_force(:,1),'k'); title(figx,'Force X');
    plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
    plot(fig_y,binnedData.timeframe,actual_force(:,2),'k'); title(figx,'Force Y');
    plot(fig_y,offline_preds.timeframe,offline_preds.preddatabin(:,2),'r');
end
    
for i = 1:num_catch
    catch_idx = binnedData.timeframe>=catch_trial_times(i,1) & ...
                binnedData.timeframe<=catch_trial_times(i,2);
    Act = actual_force(catch_idx,:);
    
    Curs= binnedData.cursorposbin(catch_idx,:);
    
    catch_idx = offline_preds.timeframe>=catch_trial_times(i,1) & ...
                offline_preds.timeframe<=catch_trial_times(i,2);
            
    Preds= offline_preds.preddatabin(catch_idx,:);
            
    adapt_stats(i,1,:) = CalculateR2(Act,Curs);
    adapt_stats(i,2,:) = 1-  sum( (Curs-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
       
    offline_stats(i,1,:) = CalculateR2(Act,Preds);
    offline_stats(i,2,:) = 1-  sum( (Preds-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
    
    if plotflag
        plot(fig_x, binnedData.timeframe(catch_idx),binnedData.cursorposbin(catch_idx,1),'b');
        plot(fig_y, binnedData.timeframe(catch_idx),binnedData.cursorposbin(catch_idx,2),'b');
        
        xx = binnedData.timeframe(catch_idx);
        ytop = 10*ones(length(xx));
        ybot = -ytop;
        yarea = [ytop; ybot(end:-1:1)];
        area(fig_x,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        area(fig_y,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
    end
end

if plotflag
    last_adapt_trial = find(catch_trial_times(:,2)<=fix_time,1,'last');
    plot(fig_x,[catch_trial_times(last_adapt_trial,2) catch_trial_times(last_adapt_trial,2)],...
          [12 -12],'k--','linewidth',2);
    plot(fig_x,[catch_trial_times(last_adapt_trial,2) catch_trial_times(last_adapt_trial,2)],...
          [12 -12],'k--','linewidth',2);  

    x_vaf = figure; hold on;
    plot(x_vaf,offline_stats(:,2,1),'ro-',linewidth,'2'); title('vaf X');
    plot(x_vaf,adapt_stats(:,2,1),'bo-',linewidth,'2');
    plot(x_vaf,[last_adapt_trial last_adapt_trial],[0 1],'k--','linewidth',2);
 
    
    y_vaf= figure; hold on;
    plot(y_vaf,offline_stats(:,2,2),'ro-',linewidth,'2'); title('vaf Y');
    plot(y_vaf,adapt_stats(:,2,y),'bo-',linewidth,'2');
    plot(y_vaf,[last_adapt_trial last_adapt_trial],[0 1],'k--','linewidth',2);
    
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