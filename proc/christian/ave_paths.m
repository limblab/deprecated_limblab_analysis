function [ave_path,ave_fr] = ave_paths(binnedData,time_before,time_after,plot_flag,save_flag)
% Calculate the average cursor path and average firing rate around outer target onset
% for task Wrist Flexion

if save_flag
    save_figs_path = '/Users/christianethier/Dropbox/Adaptation/ave_FR_figs/';
    save_figs_name = 'Jango_WF_20140707_HC_002_';
end

targets      = sort(unique(binnedData.trialtable(:,10)));
num_targets   = length(targets);
successes    = find(binnedData.trialtable(:,9)==double('R'));
ave_duration = mean(binnedData.trialtable(successes,8)-binnedData.trialtable(successes,7));
std_duration = std(binnedData.trialtable(successes,8)-binnedData.trialtable(successes,7));
binsize      = binnedData.timeframe(2)-binnedData.timeframe(1);
num_bins     = round((time_before+time_after)/binsize) + 1;

ave_path     = nan(num_bins,2,num_targets);
ave_fr       = nan(num_bins,num_targets);
fr_sd        = nan(num_bins,num_targets);

for tgt = 1:num_targets
    
    tgt_idx       = find(binnedData.trialtable(:,10)==targets(tgt));
    succ_idx      = intersect(tgt_idx,successes);
    num_succ      = length(succ_idx);
    tmp_paths     = nan(num_succ,num_bins,2);
    tmp_FR        = nan(num_succ,num_bins);
        
    for trial = 1:num_succ

        % starting 'time_before' sec before tgt onset:
        binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),7)-1,1,'last');
        % until 'time_after' sec after tgt onset:
        binstop  = binstart + num_bins-1;

        tmp_paths(trial,:,:) = binnedData.cursorposbin(binstart:binstop,:);
        tmp_FR(trial,:)      = mean(binnedData.spikeratedata(binstart:binstop,:),2);
    end
    
    ave_path(:,:,tgt) = mean(tmp_paths,1);
    ave_fr(:,tgt)     = mean(tmp_FR   ,1); 
    fr_sd(:,tgt)      = std(tmp_FR    ,1);
    
    if plot_flag        
        xvec = -time_before:binsize:time_after;
               
        
        figure; hold on;
%         [ax,h1,h2]=plotyy(xvec,ave_path(:,:,tgt),xvec,ave_fr(:,tgt));
        plot(xvec,ave_fr(:,tgt));
        %plot fr SD
        ylow   = ave_fr(:,tgt) - fr_sd(:,tgt);
        yhi    = ave_fr(:,tgt) + fr_sd(:,tgt);
        xarea  = [xvec xvec(end:-1:1)];
        yarea  = [yhi; ylow(end:-1:1)];
        area(xarea,yarea,'FaceColor',[1 0 0],'EdgeColor','none'); alpha(0.5);
        
        title(sprintf('target %d',tgt));
        xlabel('time relative to outer target onset (sec)');
        
        % plot reward area
        [yrange] = ylim;
        plot([ave_duration ave_duration],yrange,'k--');
        xlow = ave_duration-std_duration;
        xhi  = ave_duration+std_duration;
        xarea= [xlow xhi xhi xlow];
        yarea= [yrange(1) yrange(1) yrange(2) yrange(2)];
        area(xarea,yarea,'FaceColor',[.5 .5 .5],'EdgeColor','none'); alpha(0.5);
%         legend([h1;h2;h3;h4;h5],'force x','force y','ave FR','FR SD','ave reward','reward SD');
        legend('ave FR','FR SD','ave reward','reward SD');
        grid on;
        
    end
    if save_flag
        fn = [fullfile(save_figs_path,save_figs_name) sprintf('tgt%d',tgt)];
        export_fig(fn,'-transparent',gcf);
    end
end
end