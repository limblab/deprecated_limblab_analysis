close all;
clc;
clear;

tune_windows = {'onpeak'};
% tune_windows = {'initial','peak','final'};

for iWin = 1:length(tune_windows)
    
    tune_window = tune_windows{iWin};
    
    nm = repmat(struct(),1,6);
    stam = repmat(struct(),1,6);
    
    %%
    % tuning day 1
    bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30];
    % bankC_stim_elecs = 1:31;
    bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30];
    
    bankA_elec_IDs = 0+bankA_stim_elecs;
    bankC_elec_IDs = 64+bankC_stim_elecs;
    all_elec_IDs = [bankA_elec_IDs, bankC_elec_IDs];
    
    load(['F:\Jaco\Processed\2016-01-27\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-01-27.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
    end
    nm(1).pds = tuning.boot_pds(idx,:);
    nm(1).mds = tuning.boot_mds(idx,:);
    nm(1).bos = tuning.boot_bos(idx,:);
    nm(1).r2 = tuning.r_squared(idx,:);
    
    % stim day 1
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_27\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30_20160127_170019_CO_TTA.mat');
    stam_a = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_27\Jaco_A_1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31_20160127_172136_CO_TTA.mat');
    stam_c = calculate_sta_metrics_matt(force,ttap);
    
    stam(1).mean_force = cat(3,stam_a.force.mean_detrended_force,stam_c.force.mean_detrended_force(:,:,bankC_stim_elecs));
    stam(1).std_force = cat(3,stam_a.force.std_detrended_force,stam_c.force.std_detrended_force(:,:,bankC_stim_elecs));
    stam(1).evoked_force = cat(4,stam_a.force.detrend_evoked_force,stam_c.force.detrend_evoked_force(:,:,:,bankC_stim_elecs));
    
    %%
    % tuning day 2
    bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30];
    bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30];
    
    bankA_elec_IDs = 0+bankA_stim_elecs;
    bankC_elec_IDs = 64+bankC_stim_elecs;
    all_elec_IDs = [bankA_elec_IDs, bankC_elec_IDs];
    
    load(['F:\Jaco\Processed\2016-01-28\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-01-28.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
    end
    nm(2).pds = tuning.boot_pds(idx,:);
    nm(2).mds = tuning.boot_mds(idx,:);
    nm(2).bos = tuning.boot_bos(idx,:);
    nm(2).r2 = tuning.r_squared(idx,:);
    
    % stim day 2
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_28\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30_20160128_122955_CO_TTA.mat')
    stam_a = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_28\Jaco_A_1   2   3   4   6   7   8   9  10  20  21  23  25  28  29  30_20160128_125158_CO_TTA.mat')
    stam_c = calculate_sta_metrics_matt(force,ttap);
    stam(2).mean_force = cat(3,stam_a.force.mean_detrended_force,stam_c.force.mean_detrended_force);
    stam(2).std_force = cat(3,stam_a.force.std_detrended_force,stam_c.force.std_detrended_force);
    stam(2).evoked_force = cat(4,stam_a.force.detrend_evoked_force,stam_c.force.detrend_evoked_force);
    
    %%
    % tuning day 3
    bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30];
    bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30];
    
    bankA_elec_IDs = 0+bankA_stim_elecs;
    bankC_elec_IDs = 64+bankC_stim_elecs;
    all_elec_IDs = [bankA_elec_IDs, bankC_elec_IDs];
    
    load(['F:\Jaco\Processed\2016-01-29\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-01-29.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        try
            idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
            nm(3).pds(i) = tuning.boot_pds(idx(i),:);
            nm(3).mds(i) = tuning.boot_mds(idx(i),:);
            nm(3).bos(i) = tuning.boot_bos(idx(i),:);
            nm(3).r2(i) = tuning.r_squared(idx(i),:);
        catch
            idx(i) = NaN;
            nm(3).pds(i) = NaN;
            nm(3).mds(i) = NaN;
            nm(3).bos(i) = NaN;
            nm(3).r2(i) = NaN;
        end
    end
    
    % stim day 3
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_29\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30_20160129_123500_CO_TTA.mat')
    stam_a = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_01_29\Jaco_A_1   2   3   4   6   7   8   9  10  20  21  23  25  28  29  30_20160129_130033_CO_TTA.mat')
    stam_c = calculate_sta_metrics_matt(force,ttap);
    stam(3).mean_force = cat(3,stam_a.force.mean_detrended_force,stam_c.force.mean_detrended_force);
    stam(3).std_force = cat(3,stam_a.force.std_detrended_force,stam_c.force.std_detrended_force);
    stam(3).evoked_force = cat(4,stam_a.force.detrend_evoked_force,stam_c.force.detrend_evoked_force);
    
    
    %%
    % tuning day 4
    bankB_stim_elecs = 1:31;
    
    bankB_elec_IDs = 32+bankB_stim_elecs;
    all_elec_IDs = bankB_elec_IDs;
    
    load(['F:\Jaco\Processed\2016-02-02\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-02-02.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        try
            idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
            nm(4).pds(i) = tuning.boot_pds(idx(i),:);
            nm(4).mds(i) = tuning.boot_mds(idx(i),:);
            nm(4).bos(i) = tuning.boot_bos(idx(i),:);
            nm(4).r2(i) = tuning.r_squared(idx(i),:);
        catch
            idx(i) = NaN;
            nm(4).pds(i) = NaN;
            nm(4).mds(i) = NaN;
            nm(4).bos(i) = NaN;
            nm(4).r2(i) = NaN;
        end
    end
    
    % stim day 4
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_02\Jaco_B_1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31_20160202_141138_CO_TTA.mat')
    stam_b = calculate_sta_metrics_matt(force,ttap);
    stam(4).mean_force = stam_b.force.mean_detrended_force;
    stam(4).std_force = stam_b.force.std_detrended_force;
    stam(4).evoked_force = stam_b.force.detrend_evoked_force;
    
    %%
    % tuning day 5
    bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30,2,6,15,26];
    bankB_stim_elecs = [1,2,3,5,6,7,8,9,11,12,13,16,18,19,20,21,22,23,25,26,27,28];
    bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30,27];
    
    bankA_elec_IDs = 0+bankA_stim_elecs;
    bankB_elec_IDs = 32+bankB_stim_elecs;
    bankC_elec_IDs = 64+bankC_stim_elecs;
    all_elec_IDs = [bankA_elec_IDs, bankB_elec_IDs, bankC_elec_IDs];
    
    load(['F:\Jaco\Processed\2016-02-03\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-02-03.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        try
            idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
            nm(5).pds(i) = tuning.boot_pds(idx(i),:);
            nm(5).mds(i) = tuning.boot_mds(idx(i),:);
            nm(5).bos(i) = tuning.boot_bos(idx(i),:);
            nm(5).r2(i) = tuning.r_squared(idx(i),:);
        catch
            idx(i) = NaN;
            nm(5).pds(i) = NaN;
            nm(5).mds(i) = NaN;
            nm(5).bos(i) = NaN;
            nm(5).r2(i) = NaN;
        end
    end
    
    % stim day 5
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_03\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30   2   6  15  26_20160203_135059_CO_TTA.mat');
    stam_a = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_03\Jaco_B_1   2   3   5   6   7   8   9  11  12  13  16  18  19  20  21  22  23  25  26  27  28_20160203_132453_CO_TTA.mat');
    stam_b = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_03\Jaco_C_1   2   3   4   6   7   8   9  10  20  21  23  25  28  29  30  27_20160203_141830_CO_TTA.mat');
    stam_c = calculate_sta_metrics_matt(force,ttap);
    stam(5).mean_force = cat(3,stam_a.force.mean_detrended_force,stam_b.force.mean_detrended_force,stam_c.force.mean_detrended_force);
    stam(5).std_force = cat(3,stam_a.force.std_detrended_force,stam_b.force.std_detrended_force,stam_c.force.std_detrended_force);
    stam(5).evoked_force = cat(4,stam_a.force.detrend_evoked_force,stam_b.force.detrend_evoked_force,stam_c.force.detrend_evoked_force);
    
    %%
    % tuning day 6
    bankA_stim_elecs = [1,7,10,11,13,14,17,18,19,20,22,23,24,25,27,28,29,30,2,6,15,26];
    bankB_stim_elecs = [1,2,3,5,6,7,8,9,11,12,13,16,18,19,20,21,22,23,25,26,27,28];
    bankC_stim_elecs = [1,2,3,4,6,7,8,9,10,20,21,23,25,28,29,30,27];
    
    bankA_elec_IDs = 0+bankA_stim_elecs;
    bankB_elec_IDs = 32+bankB_stim_elecs;
    bankC_elec_IDs = 64+bankC_stim_elecs;
    all_elec_IDs = [bankA_elec_IDs, bankB_elec_IDs, bankC_elec_IDs];
    
    load(['F:\Jaco\Processed\2016-02-04\M1_tuning\CO_CS_movement_regression_' tune_window '_2016-02-04.mat']);
    idx = zeros(size(all_elec_IDs));
    for i = 1:length(all_elec_IDs)
        try
            idx(i) = find(tuning.sg(:,1)==all_elec_IDs(i));
            nm(6).pds(i) = tuning.boot_pds(idx(i),:);
            nm(6).mds(i) = tuning.boot_mds(idx(i),:);
            nm(6).bos(i) = tuning.boot_bos(idx(i),:);
            nm(6).r2(i) = tuning.r_squared(idx(i),:);
        catch
            idx(i) = NaN;
            nm(6).pds(i) = NaN;
            nm(6).mds(i) = NaN;
            nm(6).bos(i) = NaN;
            nm(6).r2(i) = NaN;
        end
    end
    
    % stim day 6
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_04\Jaco_A_1   7  10  11  13  14  17  18  19  20  22  23  24  25  27  28  29  30   2   6  15  26_20160204_134953_CO_TTA.mat');
    stam_a = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_04\Jaco_B_1   2   3   5   6   7   8   9  11  12  13  16  18  19  20  21  22  23  25  26  27  28_20160204_132412_CO_TTA.mat');
    stam_b = calculate_sta_metrics_matt(force,ttap);
    load('F:\Jaco\ICMS_testing\TTA_data_2016_02_04\Jaco_C_1   2   3   4   6   7   8   9  10  20  21  23  25  28  29  30  27_20160204_141532_CO_TTA.mat');
    stam_c = calculate_sta_metrics_matt(force,ttap);
    stam(5).mean_force = cat(3,stam_a.force.mean_detrended_force,stam_b.force.mean_detrended_force,stam_c.force.mean_detrended_force);
    stam(5).std_force = cat(3,stam_a.force.std_detrended_force,stam_b.force.std_detrended_force,stam_c.force.std_detrended_force);
    stam(5).evoked_force = cat(4,stam_a.force.detrend_evoked_force,stam_b.force.detrend_evoked_force,stam_c.force.detrend_evoked_force);

    
    %%
    t_force                     = -ttap.t_before:1/force.fs*1000:ttap.t_after;       % in ms
    
    clear move_pd twitch_pd move_r2 twitch_snr end_pd end_r2;
    count = 0;
    for idx_day = 1:6
        
        num_elecs = size(stam(idx_day).mean_force,3);
        
        for idx_elec = 1:num_elecs
            % only if cell is tuned
            if ~isnan(nm(idx_day).r2(idx_elec))
                
                f = squeeze(stam(idx_day).mean_force(:,:,idx_elec));
                fs = squeeze(stam(idx_day).std_force(:,:,idx_elec));
                ef = squeeze(stam(idx_day).evoked_force(:,:,:,idx_elec));
                
                ef = ef(:,:,~isnan(squeeze(ef(1,1,:))));
                
                if size(ef,3) > 0
                    count = count + 1;
                    t = t_force >= 0  & t_force <= 56;
                    
%                     % get mean and std dev of all twitches
%                     fm = hypot(f(t,1),f(t,2));
%                     fsm = hypot(fs(t,1),fs(t,2));
%                     % compare each twitch against these for outliers
%                     outlier_twitches = zeros(1,size(ef,3));
%                     for i = 1:size(ef,3)
%                         outlier_twitches(i) = sum(hypot(squeeze(ef(t,1,i)),squeeze(ef(t,2,i))) > fm+8*fsm) > 5;
%                     end
%                     ef = ef(:,:,~outlier_twitches);
                    
                    % get PD
                    move_pds(count,:) = nm(idx_day).pds(idx_elec,:);
                    move_r2s(count,:) = nm(idx_day).r2(idx_elec,:);
                    
                    f_max = max([max(squeeze(ef(t,1,:))),max(squeeze(ef(t,2,:)))]);
%                     figure('Position',[100 50 800 900]);
%                     subplot(3,2,1); % all x force traces
%                     hold all;
%                     plot(squeeze(ef(t ,1,:)));
%                     plot(mean(squeeze(ef(t,1,:)),2),'k','LineWidth',3);
%                     axis('tight');
%                     set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-f_max,f_max]);
%                     xlabel('Time after stim','FontSize',14);
%                     title('X Force Raw','FontSize',14);
%                     subplot(3,2,2); % all y force traces
%                     hold all;
%                     plot(squeeze(ef(t,2,:)));
%                     plot(mean(squeeze(ef(t,2,:)),2),'k','LineWidth',3);
%                     axis('tight');
%                     set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-f_max,f_max]);
%                     title('Y Force Raw','FontSize',14);
%                     subplot(3,2,3); % all rms force traces
%                     hold all;
%                     plot(hypot(squeeze(ef(t ,1,:)),squeeze(ef(t ,2,:))));
%                     plot(mean(hypot(squeeze(ef(t ,1,:)),squeeze(ef(t ,2,:))),2),'k','LineWidth',3);
%                     axis('tight');
%                     V = axis;
%                     set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[0,V(4)]);
%                     title('Mag Force Raw','FontSize',14);
                    
                    % do some statistics for twitches
                    t_peak = zeros(1,size(ef,3));
                    pd = zeros(1,size(ef,3));
                    for i = 1:2000
                        
                        idx = randi(size(ef,3),20,1);
                        
                        mean_ef = mean(ef(t,:,idx),3);
                        
                        [~,t_peak(i)] = max(hypot(mean_ef(:,1),mean_ef(:,2)));
%                         pd(i) = atan2(squeeze(mean_ef(t_peak(i),2)),squeeze(mean_ef(t_peak(i),1)));
                        pd(i) = atan2(squeeze(mean_ef(30,2)),squeeze(mean_ef(30,1)));
                        
%                         subplot(3,2,4); % plot all bootstrapped RMS averages
%                         hold all;
%                         plot(hypot(mean_ef(:,1),mean_ef(:,2)));
%                         plot(t_peak(i),hypot(mean_ef(t_peak(i),1),mean_ef(t_peak(i),2)),'ko');
                    end
                    
                    twitch_pds(count,:) = pd;
                    
%                     axis('tight');
%                     set(gca,'Box','off','TickDir','out','FontSize',14);
%                     title('Mag Force Boot','FontSize',14);
%                     
%                     subplot(3,2,5); % histogram of peak times
%                     hist(t_peak,0:2:56);
%                     axis('tight');
%                     set(gca,'Box','off','TickDir','out','FontSize',14);
%                     xlabel('Time relative to stim','FontSize',14);
%                     title('Boot Peak Times','FontSize',14);
%                     subplot(3,2,6); % histogram of PDs
%                     hist(180/pi*pd,180/pi*(-pi:pi/20:pi));
%                     set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',180/pi*[-pi,pi]);
%                     xlabel('Direction (Deg)','FontSize',14);
%                     title('Boot Directions','FontSize',14);
%                     pause;
                    
%                     figure; plot(t_peak,180/pi*pd,'o','LineWidth',2); set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 56],'YLim',[-180 180]); xlabel('Time to Peak','FontSize',14); ylabel('Twitch Direction','FontSize',14);
%                                         saveas(gcf,['F:\Jaco\ICMS_testing\figures\' num2str(count) '.png']);
                    close all;
                end
            end
        end
    end
    
end
% set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 4]);

%%
sort_pds=sort(twitch_pds,2);
ms = circular_mean(twitch_pds,[],2);
temp=sort_pds - repmat(ms,1,size(sort_pds,2));
temp(temp < -pi) = temp(temp < -pi) + 2*pi;
temp(temp > pi) = temp(temp > pi) - 2*pi;

twitch_cbs = prctile(temp,[2.5 97.5],2);

sort_pds=sort(move_pds,2);
ms = circular_mean(move_pds,[],2);
temp=sort_pds - repmat(ms,1,size(sort_pds,2));
temp(temp < -pi) = temp(temp < -pi) + 2*pi;
temp(temp > pi) = temp(temp > pi) - 2*pi;

move_cbs = prctile(temp,[2.5 97.5],2);


tune_elecs = abs(diff(move_cbs,[],2)) <= 45*pi/180;
% tune_elecs = abs(diff(twitch_cbs,[],2)) <= 45*pi/180 & abs(diff(move_cbs,[],2)) <= 45*pi/180;
%%


%%
% figure;
% subplot(3,1,1);
% plot(move_r2(good_cells),dpd(good_cells),'o');
% xlabel('PD R-Squared','FontSize',14);
% ylabel('Change in Angle','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% subplot(3,1,2);
% plot(twitch_snr(good_cells),dpd(good_cells),'o');
% xlabel('Twitch SNR','FontSize',14);
% ylabel('Change in Angle','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
% subplot(3,1,3);
% plot(move_r2(good_cells),twitch_snr(good_cells),'o');
% xlabel('PD R-Squared','FontSize',14);
% ylabel('Twitch SNR','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
%
% figure;
% plot(move_pd(good_cells),twitch_pd(good_cells),'o');
% xlabel('Movement PD','FontSize',14);
% ylabel('Twitch Direction','FontSize',14);
% set(gca,'Box','off','TickDir','out','FontSize',14);
