function raw_stim_plots(stims,params)

use_signal = params.use_signal;
mark_bad_trials = params.mark_bad_trials; % plot bad trials as red
font_size = params.font_size;
zoom_window = params.zoom_window; % time window for plotting zoomed data
kin_samp_freq = params.kin_samp_freq;
time_before = params.time_before; % time before sync pulse in sec
time_after = params.time_after; % time after sync pulse in sec

t = -floor(time_before*kin_samp_freq):floor(time_after*kin_samp_freq);
t_zoom = -floor(zoom_window(1)*kin_samp_freq):floor(zoom_window(2)*kin_samp_freq);
idx_peak = find(t_zoom >= 100,1,'first');

% Start the loops!
scrsz = get(groot,'ScreenSize');

% loop along epochs
for i = 1:length(stims)
    
    bank = stims(i).bank;
    elec = stims(i).elec;
    pin = stims(i).pin;
    all_f = stims(i).(use_signal);
    all_f_detrend = stims(i).([use_signal '_detrend']);
    bad_stims = stims(i).bad_stims;
    
    max_f = max(max(hypot( squeeze(all_f(:,:,1)), squeeze(all_f(:,:,2)) )));
    max_f_detrend = max(max(hypot( squeeze(all_f_detrend(1,:,1)), squeeze(all_f_detrend(1,:,2)) )));
    
    
    figure('Position',[scrsz(3)/4 scrsz(4)/4 3*scrsz(3)/5 2*scrsz(4)/3],'Name',[bank num2str(pin)])
    % plot shaded box showing zoomed in area
    subplot(2,3,1);
    patch([floor((-zoom_window(1))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((-zoom_window(1))*kin_samp_freq)], ...
        [-max_f_detrend -max_f_detrend max_f_detrend max_f_detrend],'b','FaceAlpha',0.3,'EdgeAlpha',0);
    subplot(2,3,2);
    patch([floor((-zoom_window(1))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((-zoom_window(1))*kin_samp_freq)], ...
        [-max_f_detrend -max_f_detrend max_f_detrend max_f_detrend],'b','FaceAlpha',0.3,'EdgeAlpha',0);
    subplot(2,3,3);
    patch([floor((-zoom_window(1))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((zoom_window(2))*kin_samp_freq),floor((-zoom_window(1))*kin_samp_freq)], ...
        [0 0 max_f_detrend max_f_detrend],'b','FaceAlpha',0.3,'EdgeAlpha',0);
    
    for j = 1:size(all_f,1)
        
        if ~mark_bad_trials && bad_stims(j)
            % skip
        else
            if mark_bad_trials && bad_stims(j)
                plot_color = 'r';
            else
                plot_color = 'k';
            end
            
            f = squeeze(all_f(j,:,:));
            % plot all data
            subplot(2,3,1);
            hold all;
            plot(t,f(:,1),'Color',plot_color);
            subplot(2,3,2);
            hold all;
            plot(t,f(:,2),'Color',plot_color);
            subplot(2,3,3);
            hold all;
            plot(t,hypot(f(:,1),f(:,2)),'Color',plot_color);
            
            f = squeeze(all_f_detrend(j,:,:));
            % plot detrended zoomed data
            subplot(2,3,4);
            hold all;
            plot(t_zoom,f(:,1),'Color',plot_color);
            subplot(2,3,5);
            hold all;
            plot(t_zoom,f(:,2),'Color',plot_color);
            subplot(2,3,6);
            hold all;
            plot(t_zoom,hypot(f(:,1),f(:,2)),'Color',plot_color);
        end
    end
    
    subplot(2,3,1);
    axis('tight');
    plot([0,0],[-max_f,max_f],'LineWidth',2);
    plot([0,0]+0.04*kin_samp_freq,[-max_f,max_f],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-max_f,max_f]);
    title(['X ' use_signal],'FontSize',14);
    ylabel('Raw Data','FontSize',16);
    
    subplot(2,3,2);
    axis('tight');
    plot([0,0],[-max_f,max_f],'LineWidth',2);
    plot([0,0]+0.04*kin_samp_freq,[-max_f,max_f],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-max_f,max_f]);
    title(['Y ' use_signal],'FontSize',14);
    
    subplot(2,3,3);
    axis('tight');
    plot([0,0],[0,max_f],'LineWidth',2);
    plot([0,0]+0.04*kin_samp_freq,[0,max_f],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[0,max_f]);
    xlabel('Time (msec)','FontSize',14);
    title(['Magnitude ' use_signal],'FontSize',14);
    
    subplot(2,3,4);
    axis('tight');
    plot([0,0],[-max_f_detrend,max_f_detrend],'LineWidth',2);
    plot([0,0] + 0.04*kin_samp_freq,[-max_f_detrend,max_f_detrend],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-max_f_detrend,max_f_detrend]);
    ylabel('Zoomed and Detrended','FontSize',16);
    
    subplot(2,3,5);
    axis('tight');
    plot([0,0],[-max_f_detrend,max_f_detrend],'LineWidth',2);
    plot([0,0] + 0.04*kin_samp_freq,[-max_f_detrend,max_f_detrend],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-max_f_detrend,max_f_detrend]);
    
    subplot(2,3,6);
    axis('tight');
    plot([0,0],[0,max_f_detrend],'LineWidth',2);
    plot([0,0] + 0.04*kin_samp_freq,[0,max_f_detrend],'LineWidth',2);
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[0,max_f_detrend]);
    xlabel('Time (msec)','FontSize',14);
    
    
    %%%%%%%%%%%%%%%
    % plot directionality stuff
    
    theta = stims(i).directions(~bad_stims);
    
    figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2 2*scrsz(4)/3],'Name',[bank num2str(pin)])
    
    subplot(2,2,1);
    hold all;
    for j = 1:size(all_f_detrend,1)
        if ~bad_stims(j)
            f = squeeze(all_f_detrend(j,:,:));
            plot(f(:,1),f(:,2));
            plot(f(idx_peak,1),f(idx_peak,2),'ko','LineWidth',2);
        end
    end
    plot([0 0],[-max_f_detrend,max_f_detrend],'k--','LineWidth',2);
    plot([-max_f_detrend,max_f_detrend],[0 0],'k--','LineWidth',2);
    axis('square');
    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-max_f_detrend,max_f_detrend],'YLim',[-max_f_detrend,max_f_detrend]);
    xlabel(['X ' use_signal],'FontSize',14);
    ylabel(['Y ' use_signal],'FontSize',14);
    title('2-D Twitch Traces','FontSize',14);
    
    subplot(2,2,2);
    rose(theta,50);
    set(gca,'Box','off','TickDir','out','FontSize',14);
    title('Twitch Directions','FontSize',14);
    xlabel(['95% CI on mean: ' num2str(circular_confmean(theta')*180/pi) ' deg'],'FontSize',14);
    
    subplot(2,2,3);
    plot(theta*180/pi,'ko','LineWidth',2);
    axis('tight');
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-180,180]);
    xlabel('Stimulation attempts','FontSize',14);
    ylabel('Twitch Direction (Deg)','FontSize',14);
    title('Direction over time','FontSize',14);
    
    % plot confidence interval of mean as function of number of stimulations
    stim_counts = 5:length(theta);
    num_rand_samps = 20;
    cm = zeros(length(stim_counts),num_rand_samps);
    for j = 1:length(stim_counts)
        for k = 1:num_rand_samps
            idx = randi(length(theta),1,stim_counts(j));
            cm(j,k) = circular_confmean(theta(idx)');
        end
    end
    
    subplot(2,2,4);
    plot(stim_counts,nanmean(cm,2)*180/pi,'LineWidth',2);
    axis('tight');
    set(gca,'Box','off','TickDir','out','FontSize',14);
    xlabel('Number of stimulations','FontSize',14);
    ylabel('95% confidence on mean','FontSize',14);
    title('Confidence with stim count','FontSize',14);
end
clear i pdci pds cm theta V t f plot_color bank elec bad_stims all_f all_f_detrend max_f max_f_detrend scrsz;