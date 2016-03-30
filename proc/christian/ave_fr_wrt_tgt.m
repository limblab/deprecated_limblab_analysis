function [varargout] = ave_fr_wrt_tgt(binnedData,time_before,time_after,varargin)
% Calculate the average firing rate, cursor path and emgs around outer target onset
% for task Wrist Flexion
% cursor path and EMG outputs are optional
% inputs: 
%   binnedData  = standard binnedData structure
%   time_before = in seconds, positive time before outer target onset
%   time_after  = in seconds, positive time after  outer target onset
%   varargin    = {outs_to_ave,plot_flag,save_path}
%       outs_to_ave=  0 - firing rate only
%                     1 - firing rate and cursor path
%                     2 - firing rate and emg
%                     3 - firing rate, paths and emgs
%       plot_flag  =  plots outs_to_ave for all targets
%       save_path  =  if present, saves figures as .png and .pdf in save_path
%
% outputs:
%   varargout   = {ave_global_fr,ave_unit_fr,ave_path,ave_emg}
%       ave_global_fr = average global firing rate wrt each target during time window
%                       specified by [ OT_on-time_before, OT_on+time_after];
%       ave_unit_fr   = average firing rate for each target over the whole
%                       time window
%       ave_path      = average X and Y cursor position
%       ave_emg       = average emgs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outs_to_ave = 0;
plot_flag   = false;
save_flag   = false;

if nargin > 3 %#ok<ALIGN>
    outs_to_ave = varargin{1};
if nargin > 4 %#ok<ALIGN>
    plot_flag   = varargin{2};
if nargin > 5
    save_figs_path   = varargin{3};
    save_flag   = true;
end;end;end;
            
if save_flag
    save_figs_name = binnedData.meta.filename;
end

targets      = sort(unique(binnedData.trialtable(:,10)));
num_targets  = length(targets);
num_units    = size(binnedData.spikeratedata,2);
successes    = find(binnedData.trialtable(:,9)==double('R'));
ave_duration = mean(binnedData.trialtable(successes,8)-binnedData.trialtable(successes,7));
std_duration = std(binnedData.trialtable(successes,8)-binnedData.trialtable(successes,7));
binsize      = binnedData.timeframe(2)-binnedData.timeframe(1);
num_bins     = round((time_before+time_after)/binsize) + 1;

if isfield(binnedData,'emgdatabin') 
    num_emgs = size(binnedData.emgdatabin,2);
else
    num_emgs = 0;
end

ave_path     = nan(num_bins,2,num_targets);
ave_emg      = nan(num_bins,num_emgs,num_targets);
ave_g_fr     = nan(num_bins,num_targets);
ave_u_fr     = nan(num_targets,num_units);
g_fr_sd      = nan(num_bins,num_targets);
u_fr_sd      = nan(num_targets,num_units);

for tgt = 1:num_targets
    
    tgt_idx       = find(binnedData.trialtable(:,10)==targets(tgt));
    succ_idx      = intersect(tgt_idx,successes);
    num_succ      = length(succ_idx);
    tmp_g_fr      = nan(num_succ,num_bins);
    tmp_u_fr      = nan(num_succ,num_units);
    
    if outs_to_ave == 1 || outs_to_ave ==3
        tmp_path     = nan(num_succ,num_bins,2);
    end
    if outs_to_ave == 2 || outs_to_ave ==3
        tmp_emg      = nan(num_succ,num_bins,num_emgs);
    end
        
    for trial = 1:num_succ

        % starting 'time_before' sec before tgt onset:
        binstart = find(binnedData.timeframe<=binnedData.trialtable(succ_idx(trial),7)-time_before,1,'last');
        % until 'time_after' sec after tgt onset:
        binstop  = binstart + num_bins-1;
        if binstop > size(binnedData.spikeratedata,1)
            tmp_g_fr = tmp_g_fr(1:end-1,:);
            tmp_u_fr = tmp_u_fr(1:end-1,:);
            if outs_to_ave == 1 || outs_to_ave ==3
                tmp_path     = tmp_path(1:end-1,:,:);
            end
            if outs_to_ave == 2 || outs_to_ave ==3
                tmp_emg      = tmp_emg(1:end-1,:,:);
            end
            continue;
        end
        tmp_g_fr(trial,:)      = mean(binnedData.spikeratedata(binstart:binstop,:),2);
        tmp_u_fr(trial,:)      = mean(binnedData.spikeratedata(binstart:binstop,:),1);
        
        if outs_to_ave == 1 || outs_to_ave ==3
            tmp_path(trial,:,:) = binnedData.cursorposbin(binstart:binstop,:);
        end
        if outs_to_ave == 2 || outs_to_ave ==3
            tmp_emg(trial,:,:)    = binnedData.emgdatabin(binstart:binstop,:);
        end
    end
    
    ave_g_fr(:,tgt)   = mean(tmp_g_fr   ,1);
    ave_u_fr(tgt,:)   = mean(tmp_u_fr   ,1);
    g_fr_sd(:,tgt)    = std(tmp_g_fr    ,1);
    u_fr_sd(tgt,:)    = std(tmp_u_fr    ,1);
    
    if outs_to_ave == 1 || outs_to_ave ==3
        ave_path(:,:,tgt) = mean(tmp_path,1);
    end
    if outs_to_ave == 2 || outs_to_ave ==3
        ave_emg(:,:,tgt)  = mean(tmp_emg ,1);
    end
    
    if plot_flag        
        xvec = -time_before:binsize:time_after;
        figure; hold on;  
        switch outs_to_ave
            case 0
                fig_h       = plot(xvec,ave_g_fr(:,tgt),'r','LineWidth',3);
                leg         = {'ave FR'};
            case 1
                [ax,h1,h2]  = plotyy(xvec,ave_g_fr(:,tgt),xvec,ave_path(:,:,tgt));
                set(h1,'Color','r','LineWidth',3); set(ax(1),'YColor','r');set(get(ax(1),'YLabel'),'string','Ave FR');
                set(h2(1),'Color','b','LineWidth',3); set(ax(2),'YColor','b');set(get(ax(2),'YLabel'),'string','Ave Cursor');
                set(h2(2),'Color','g','LineWidth',3);
                fig_h       = [h1;h2];
                leg         = [{'ave FR'} strrep(binnedData.cursorposlabels,'_','\_')];
            case 2
                [ax,h1,h2]  = plotyy(xvec,ave_g_fr(:,tgt),xvec,ave_emg(:,:,tgt));
                set(h1,'Color','r','LineWidth',3); set(ax(1),'YColor','r');set(get(ax(1),'YLabel'),'string','Ave FR');
                set(ax(2),'YColor','k'); set(get(ax(2),'YLabel'),'string','Ave EMG');
                fig_h       = [h1,h2];
                leg         = [{'ave FR'} strrep(binnedData.emgguide       ,'_','\_')];
            case 3
                [ax,fig_h]  = plotyyy(xvec,ave_g_fr(:,tgt),xvec,ave_path(:,:,tgt),...
                                      xvec,ave_emg(:,:,tgt),{'Ave FR';'Ave Cursor';'Ave EMG'});
                set(fig_h(1),'Color','r','LineWidth',3);set(ax(1),'YColor','r');
                set(fig_h(2),'Color','b','LineWidth',3);set(ax(2),'YColor','b');
                set(fig_h(3),'Color','g','LineWidth',3);set(ax(3),'YColor','k');
                leg         = [{'ave FR'} strrep(binnedData.cursorposlabels,'_','\_'),...
                                          strrep(binnedData.emgguide       ,'_','\_')];
        end

%         %plot fr SD
%         ylow   = ave_fr(:,tgt) - fr_sd(:,tgt);
%         yhi    = ave_fr(:,tgt) + fr_sd(:,tgt);
%         hold on;
%         h = shadedplot(xvec', ylow', yhi', 'b', 'b');
%         xarea  = [xvec xvec(end:-1:1)];
%         yarea  = [yhi; ylow(end:-1:1)];
%         h      = area(xarea,yarea,'FaceColor',[1 0 0],'EdgeColor','none'); alpha(0.5);
%         fig_h  = [fig_h;h];
%         leg    = [leg {'FR SD'}];
%         
%         % plot reward area
%         [yrange] = ylim;
%         h_rew    = plot([ave_duration ave_duration],yrange,'k--');
%         leg      = [leg{'Ave Reward'}];
%         xlow     = ave_duration-std_duration;
%         xhi      = ave_duration+std_duration;
%         xarea    = [xlow xhi xhi xlow];
%         yarea    = [yrange(1) yrange(1) yrange(2) yrange(2)];
%         h        = area(xarea,yarea,'FaceColor',[.5 .5 .5],'EdgeColor','none'); alpha(0.5);
%         fig_h    = [fig_h;h_rew;h];
%         leg      = [leg {'Reward SD'}];

        yrange   = ylim;
        h_rew    = plot([ave_duration ave_duration],yrange,'k--');
        fig_h    = [fig_h;h_rew];
        
        title(sprintf('target %d',tgt));
        xlabel('time relative to outer target onset (sec)');
        legend(fig_h,leg);
        grid on;
        
  
    end
    if save_flag
        fn = [fullfile(save_figs_path,save_figs_name) sprintf('_aveFR_tgt%d',tgt)];
        export_fig(fn,'-transparent',gcf);
    end
end
varargout = {ave_g_fr,ave_u_fr,ave_path,ave_emg};
end