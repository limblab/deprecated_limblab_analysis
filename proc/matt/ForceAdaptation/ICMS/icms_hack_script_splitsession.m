load('Y:\Jaco_8I1\Matt\ICMS_testing\TTA_data_2016_02_05\Jaco_A_11  13  19  20  27  28  30_20160205_123438_CO_TTA.mat')
% load('Y:\Jaco_8I1\Matt\ICMS_testing\TTA_data_2016_02_05\Jaco_A_11  28  30_20160205_131813_CO_TTA.mat')
% load('Y:\Jaco_8I1\Matt\ICMS_testing\TTA_data_2016_02_05\Jaco_A_11  28  30_20160205_132517_CO_TTA.mat')
stam = calculate_sta_metrics_matt(force,ttap);
t_force                     = -ttap.t_before:1/force.fs*1000:ttap.t_after;       % in ms

num_stims = 1:1:99;

clear pds cbs single_twitch_pds;
for idx_stims = 1:length(num_stims)
    count = 0;
    for idx_elec = 1:length(ttap.stim_elec)
        ef = squeeze(stam.force.detrend_evoked_force(:,:,:,idx_elec));
        
        ef = ef(:,:,~isnan(squeeze(ef(1,1,:))));
        
        try
            ef = ef(:,:,num_stims(idx_stims));
        end
            
        
        if size(ef,3) > 0
            count = count + 1;
            t = t_force >= 0  & t_force <= 56;
            
            % do some statistics for twitches
            t_peak = zeros(1,1);
            pd = zeros(1,1);
            for i = 1
                
                idx = randi(size(ef,3),size(ef,3),1);
                
                mean_ef = mean(ef(t,:,idx),3);
                
                [~,t_peak(i)] = max(hypot(mean_ef(:,1),mean_ef(:,2)));
                %                         pd(i) = atan2(squeeze(mean_ef(t_peak(i),2)),squeeze(mean_ef(t_peak(i),1)));
                %pd(i) = mean(atan2(squeeze(mean_ef(15:30,2)),squeeze(mean_ef(15:30,1))));
                pd(i) = atan2(mean(squeeze(mean_ef(15:30,2))),mean(squeeze(mean_ef(15:30,1))));
                
                %                         subplot(3,2,4); % plot all bootstrapped RMS averages
                %                         hold all;
                %                         plot(hypot(mean_ef(:,1),mean_ef(:,2)));
                %                         plot(t_peak(i),hypot(mean_ef(t_peak(i),1),mean_ef(t_peak(i),2)),'ko');
            end
            
            single_twitch_pds(count,idx_stims) = pd;
        end
    end
end