% 
% Plots the STA for a channel, as well as some of the metrics calculated in
% 'calculate_sta_metrics.m' 
%
%   function plot_sta( emg, sta_params, sta_metrics, varargin )
%
%       EMG: structure that contains the evoked EMG response (per stim) and
%       other EMG information
%       STA_PARAMS: structure that contains general information on the
%       experiment
%       STA_METRICS: metrics that characterize PSF: 1) Fetz' and Cheney's
%       MPSF; 2) Polyakov and Schiebert's statistics 
%
%       VARARGIN: ToDo
%
%


function plot_sta( emg, sta_params, sta_metrics, varargin )


t_emg                       = -sta_params.t_before:1/emg.fs*1000:sta_params.t_after;       % in ms
length_evoked_emg           = length(t_emg);



figure('units','normalized','outerposition',[0 0 1 1],'Name',['Electrode #' sta_params.bank num2str(sta_params.stim_elecs) ' - n = ' num2str(sta_metrics.nbr_stims)]);

for i = 1:emg.nbr_emgs
    
    if emg.nbr_emgs <= 4
        
        subplot(1,emg.nbr_emgs,i), hold on,
        disp('ToDo')
        pause;
        
    elseif emg.nbr_emgs == 6
        
        subplot(2,3,ii), hold on,
        disp('ToDo')
        pause;
        
    elseif emg.nbr_emgs <= 8
        
        subplot(2,4,i), hold on, plot(t_emg, procEmg), xlim([0 1]), title(['EMG ch #' num2str(i)], 'FontSize', 14);
        disp('ToDo')
        pause;
        
    elseif emg.nbr_emgs <= 12
        
        subplot(3,4,i), hold on,
        if sta_metrics.MPSF(i) > 0 
            plot(t_emg, sta_metrics.mean_emg(:,i),'r','linewidth',2)
        else
            plot(t_emg, sta_metrics.mean_emg(:,i),'k','linewidth',2)
        end
        set(gca,'FontSize',16), xlim([t_emg(1) t_emg(end)]), ylabel(emg.labels{i}(5:end),'FontSize',16);
        set(gca,'TickDir','out')
        plot(t_emg,(sta_metrics.mean_baseline_emg(i) + 2*sta_metrics.std_baseline_emg(i))*ones(length_evoked_emg,1),'-.k')
        %plot(t_emg,(mean_mean_baseline_emg(i) - 2*std_mean_baseline_emg(i))*ones(length_evoked_emg,1),'k')
        
        if i > 8 
           xlabel('time (ms)') 
        end
        
        if  sta_metrics.MPSF(i) > 0 && sta_metrics.P_Ztest(i) < 0.05
            title(['MPSF = ' num2str(sta_metrics.MPSF(i),3) ', P = ' num2str(sta_metrics.P_Ztest(i),3)],'color','r');
        elseif sta_metrics.MPSF(i) > 0 && sta_metrics.P_Ztest(i) > 0.05
            title(['MPSF = ' num2str(sta_metrics.MPSF(i),3) ', P = ' num2str(sta_metrics.P_Ztest(i),3)],'color','g');
        elseif  sta_metrics.MPSF(i) == 0 && sta_metrics.P_Ztest(i) < 0.05
            title(['MPSF = ' num2str(sta_metrics.MPSF(i),3) ', P = ' num2str(sta_metrics.P_Ztest(i),3)],'color','b');
        else
            title(['P = ' num2str(sta_metrics.P_Ztest(i),3)]);
        end
    end
end
