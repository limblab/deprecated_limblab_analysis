function [adapt_stats,offline_stats] = eval_online_adapt(adapt_data, varargin)
% adapt_data is a standard 'binnedData' structure with the additional fields:
%           spikes     : the binned firing rates saved during the online adaptation
%           emg_preds  : the corresponding emg_predictions
%           cursor_pos : cursor position (different than preds if cursor moved automatically)
%           cursor_pred: cursor predictions
%           params     : structure with parameters for that file
adapt_file_label = strrep(inputname(1),'_','\_');

offset_x = 6;
offset_y = 1.55;
cursgain = 55;
plotflag = true;

if nargin >1
    plotflag = varargin{1};
end

% scale force to cursor pos
actual_force = [adapt_data.forcedatabin(:,1)/cursgain+offset_x ...
                    adapt_data.forcedatabin(:,2)/cursgain+offset_y];
                    
% if nargin>2
%     offline_decoder = varargin{2};
%     if isfield(offline_decoder,'H')
%        offline_preds   = predictSignals(offline_decoder,adapt_data);
%     else
%         %offline predictions are provided instead of decoder
%         offline_preds = varargin{2};
%     end
%     clear offline_decoder;
% else
% %     binnedData = set_catch_states(binnedData);
% %     options.PredCursPos = 1; options.Use_SD = 1;
% %     OfflineDecoder = BuildSDModel(binnedData, options);
% %     offline_decoder = OfflineDecoder{1};
%     options = [];
%     options.PredForce = 1;
%     offline_decoder = BuildModel(binnedData,options);   
%     offline_preds   = predictSignals(offline_decoder,binnedData);
% %     [offR2, offvaf, offmse, offline_preds] = mfxval(binnedData,options); 
% end

num_adapt = sum(adapt_data.trialtable(:,12));
adapt_idx = find(adapt_data.trialtable(:,12));

num_trials= size(adapt_data.trialtable,1);

% adapt_trial_times = [adapt_data.trialtable(adapt_data.trialtable(:,12)==1,1) ... 
%                       adapt_data.trialtable(adapt_data.trialtable(:,12)==1,8)];             

adapt_trials_start = adapt_data.trialtable(adapt_idx,1);
if adapt_idx(end) == num_trials
    last_stop = adapt_data.trialtable(adapt_idx(end),8);
else
    last_stop = adapt_data.trialtable(adapt_idx(end)+1,1);
end

adapt_trials_stop  = [adapt_data.trialtable(adapt_idx(1:end-1)+1,1); last_stop];

adapt_trial_times = [adapt_trials_start adapt_trials_stop];
                  
adapt_stats = zeros(num_adapt,3,2);
offline_stats= zeros(num_adapt,3,2);

if plotflag
    figure; hold on; fig_x = gca;
    figure; hold on; fig_y = gca;
end
    
for i = 1:num_adapt
               
    catch_idx = adapt_data.timeframe>adapt_trial_times(i,1) & ...
                adapt_data.timeframe<adapt_trial_times(i,2);
    
    act = double(actual_force(catch_idx,:));
    preds = adapt_data.cursor_preds(catch_idx,:);
                
    adapt_stats(i,1,:) = CalculateR2(act,preds);
    adapt_stats(i,2,:) = 1-  sum( (preds-act).^2 ) ./ sum( (act - repmat(mean(act),size(act,1),1)).^2);
    adapt_stats(i,3,:) = mean((preds-act).^2);

    
    
%     offline_stats(i,1,:) = CalculateR2(act,off_preds);
%     offline_stats(i,2,:) = 1-  sum( (off_preds-act).^2 ) ./ sum( (act - repmat(mean(act),size(act,1),1)).^2);
%     offline_stats(i,3,:) = mean((off_preds-act).^2);
%     
    if plotflag
        xx = adapt_data.timeframe(catch_idx);
        ytop = 10*ones(length(xx),1);
        ybot = -ytop;
        yarea = [ytop; ybot(end:-1:1)];
        xx = [xx; xx(end:-1:1)];
        area(fig_x,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        area(fig_y,xx,yarea,'Facecolor',[.5 .5 .5],'LineStyle','none');
        
        plot(fig_x, adapt_data.timeframe(catch_idx),adapt_data.cursorposbin(catch_idx,1),'b');
        plot(fig_x, adapt_data.timeframe(catch_idx),preds(:,1),'m');
        plot(fig_y, adapt_data.timeframe(catch_idx),adapt_data.cursorposbin(catch_idx,2),'b');
        plot(fig_y, adapt_data.timeframe(catch_idx),preds(:,2),'m');
    
    end
end

if plotflag
    
    plot(fig_x,adapt_data.timeframe,actual_force(:,1),'k');
%     plot(fig_x,offline_preds.timeframe,offline_preds.preddatabin(:,1),'r');
    title(fig_x,sprintf('Force X\n%s',adapt_file_label)); ylim([-15 15]);
    

    plot(fig_y,adapt_data.timeframe,actual_force(:,2),'k');
%     plot(fig_y,offline_preds.timeframe,offline_preds.preddatabin(:,2),'r');
    title(fig_y,sprintf('Force Y\n%s',adapt_file_label)); ylim([-15 15]);

    % average x and y stats before plotting
    mas = nan(size(adapt_stats,1),3);
    mos = nan(size(offline_stats,1),3);
    for i = 1:3        
        mas(:,i,:)= mean(adapt_stats(:,i,:),3);
        mos(:,i,:)= mean(offline_stats(:,i,:),3);
    end
    
%     varname = @(x) inputname(1);
    plot_adapt_stats(smoothCE(mos),smoothCE(mas),adapt_file_label);

    
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
