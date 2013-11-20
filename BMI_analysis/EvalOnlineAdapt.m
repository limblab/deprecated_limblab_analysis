function [adapt_stats,offline_stats] = EvalOnlineAdapt(binnedData, varargin)

offset_x = 6;
offset_y = 1.55;
cursgain = 55;
plotflag = 1;

neural_control_pct = [0.5 0.5 0.75 1 1];
npc_times = [12 23 35 47 59]*60;

if nargin >1
    plotflag = varargin{1};
end
% scale force to cursor pos
actual_force    = [binnedData.forcedatabin(:,1)/cursgain+offset_x ...
                    binnedData.forcedatabin(:,2)/cursgain+offset_y]; 
binnedData.forcedatabin = actual_force;
                
if nargin>2
    offline_decoder = varargin{2};
    if isfield(offline_decoder,'H')
       offline_preds   = predictSignals(offline_decoder,binnedData);
    else
        %offline predictions are provided instead of decoder
        offline_preds = varargin{2};
    end
    clear offline_decoder;
else
%     binnedData = set_catch_states(binnedData);
%     options.PredCursPos = 1; options.Use_SD = 1;
%     OfflineDecoder = BuildSDModel(binnedData, options);
%     offline_decoder = OfflineDecoder{1};
    options = [];
    options.PredForce = 1;
    offline_decoder = BuildModel(binnedData,options);   
    offline_preds   = predictSignals(offline_decoder,binnedData);
%     [offR2, offvaf, offmse, offline_preds] = mfxval(binnedData,options); 
end

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
        
%     ncp = neural_control_pct(ceil(catch_trial_times(i,1)/(adapt_dur+fixed_dur)));
    time = catch_trial_times(i,1);
    
    ncp = neural_control_pct(find(npc_times>time,1,'first'));
        
    act_catch_idx = binnedData.timeframe>catch_trial_times(i,1) & ...
                binnedData.timeframe<catch_trial_times(i,2);
    
    %delay one bin?        
%     act_catch_idx = [false; act_catch_idx(1:end-1)];
    
    Act = double(actual_force(act_catch_idx,:));
    
    Curs= binnedData.cursorposbin(act_catch_idx,:);
    
    online_preds = (Curs - Act*(1-ncp))/ncp;
    
    off_catch_idx = offline_preds.timeframe>catch_trial_times(i,1) & ...
                offline_preds.timeframe<catch_trial_times(i,2);
        
    %delay one bin?        
%     off_catch_idx = [false; off_catch_idx(1:end-1)];
            
    Preds= offline_preds.preddatabin(off_catch_idx,:);
            
    adapt_stats(i,1,:) = CalculateR2(Act,online_preds);
    adapt_stats(i,2,:) = 1-  sum( (online_preds-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
    adapt_stats(i,3,:) = mean((online_preds-Act).^2);
    
    offline_stats(i,1,:) = CalculateR2(Act,Preds);
    offline_stats(i,2,:) = 1-  sum( (Preds-Act).^2 ) ./ sum( (Act - repmat(mean(Act),size(Act,1),1)).^2);
    offline_stats(i,3,:) = mean((Preds-Act).^2);
    
    if plotflag
        xx = binnedData.timeframe(act_catch_idx);
        ytop = 10*ones(length(xx),1);
        ybot = -ytop;
        yarea = [ytop; ybot(end:-1:1)];
        xx = [xx; xx(end:-1:1)];
        area(fig_x,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        area(fig_y,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        
        plot(fig_x, binnedData.timeframe(act_catch_idx),binnedData.cursorposbin(act_catch_idx,1),'b');
        plot(fig_x, binnedData.timeframe(act_catch_idx),online_preds(:,1),'m');
        plot(fig_y, binnedData.timeframe(act_catch_idx),binnedData.cursorposbin(act_catch_idx,2),'b');
        plot(fig_y, binnedData.timeframe(act_catch_idx),online_preds(:,2),'m');
    
    end
end

if plotflag
    
    plot(fig_x,binnedData.timeframe,actual_force(:,1),'k'); title(fig_x,'Force X');
    plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
    plot(fig_y,binnedData.timeframe,actual_force(:,2),'k'); title(fig_y,'Force Y');
    plot(fig_y,offline_preds.timeframe,offline_preds.preddatabin(:,2),'r');

    

    mas = nan(size(adapt_stats,1),3);
    mos = nan(size(offline_stats,1),3);
    for i = 1:3        
        mas(:,i,:)= mean(adapt_stats(:,i,:),3);
        mos(:,i,:)= mean(offline_stats(:,i,:),3);
    end
%     plot_adapt_stats(offline_stats,adapt_stats);
    plot_adapt_stats(smoothCE(mos),smoothCE(mas));
% 
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
