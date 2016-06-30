target_folder = ['D:\Jaco_8I1\Jaco_2016-02-10_RW_viscous_load_1\'];
params.file_prefix = 'Jaco_2016-02-10_RW_viscous_load_001';

% new_fs_vector = [500,1000,2000];
new_fs_vector = [1000,2000];
clear channel_subset;

for fs_idx = 1:length(new_fs_vector)
    new_fs = new_fs_vector(fs_idx);
    
    params.delete_raw = 1;
    params.rot_handle = 0;
    params.fig_handles = [];
    
    threshold_vector = 2:5;
    %
    if ~exist([target_folder '\' params.file_prefix '-NEVNSx.mat'],'file')
        NEVNSx = cerebus2NEVNSx(target_folder,params.file_prefix);
        % Subsample 2 kS/s data to 1 kS/s
        if ~isempty(NEVNSx.NS3)
            NEVNSx.NS2.Data = [NEVNSx.NS2.Data ; int16(resample(double(NEVNSx.NS3.Data)',1,2))'];
            NEVNSx.NS2.ElectrodesInfo = [NEVNSx.NS2.ElectrodesInfo NEVNSx.NS3.ElectrodesInfo];
            NEVNSx.NS3 = [];
        end
        save([target_folder '\' params.file_prefix '-NEVNSx'],'NEVNSx','-v7.3');
    else
        load([target_folder '\' params.file_prefix '-NEVNSx']);
    end
    
    %% Remove electrodes that don't match across data files
    nev_elec = unique(NEVNSx.NEV.Data.Spikes.Electrode);
    ns4_elec_id = [NEVNSx.NS4.ElectrodesInfo.ElectrodeID];
    
    electrodes = intersect(nev_elec,ns4_elec_id);
    rm_nev_electrodes = setxor(electrodes,nev_elec);
    rm_ns4_electrodes = setxor(electrodes,ns4_elec_id);
    
%     if ~exist('channel_subset','var')
%         channel_subset = randperm(length(electrodes));
%         %         channel_subset = sort(channel_subset(1:32));
%         channel_subset = sort(channel_subset(1:32));
%     end
%     channel_subset = electrodes;
%     rm_electrodes = setxor(electrodes,electrodes(channel_subset));
%     electrodes = electrodes(channel_subset);
%     
%     rm_nev_electrodes = sort([rm_nev_electrodes(:);rm_electrodes(:)]);
%     rm_ns4_electrodes = sort([rm_ns4_electrodes(:);rm_electrodes(:)]);
    
    rm_idx = [];
    for iElec = 1:length(rm_nev_electrodes)
        rm_idx = [rm_idx find(NEVNSx.NEV.Data.Spikes.Electrode == rm_nev_electrodes(iElec))];
    end
    NEVNSx.NEV.Data.Spikes.Electrode(rm_idx) = [];
    NEVNSx.NEV.Data.Spikes.TimeStamp(rm_idx) = [];
    NEVNSx.NEV.Data.Spikes.Unit(rm_idx) = [];
    NEVNSx.NEV.Data.Spikes.Waveform(:,rm_idx) = [];
    nev_elec = unique(NEVNSx.NEV.Data.Spikes.Electrode);
    
    NEVNSx.NS4.Data(ns4_elec_id(rm_ns4_electrodes),:) = [];
    NEVNSx.NS4.ElectrodesInfo(ns4_elec_id(rm_ns4_electrodes)) = [];
    NEVNSx.NS4.MetaTags.ChannelID(ns4_elec_id(rm_ns4_electrodes)) = [];
    NEVNSx.NS4.MetaTags.ChannelCount = size(NEVNSx.NS4.Data,1);
    
    % Find thresholds for each channel
    
    [b_high,a_high] = butter(2,250/(NEVNSx.NS4.MetaTags.SamplingFreq/2),'high');
    file_duration = NEVNSx.NS4.MetaTags.DataDurationSec;
    
    corr_coef_mat = zeros(length(electrodes),length(threshold_vector));
    num_spikes = zeros(1,length(electrodes));
    time_vector = 0.05:.05:file_duration;
    idx_offset = ([1:48]-12)';
    
    
    %%
    
    firing_rate_disc = zeros(length(electrodes),length(time_vector));
    firing_rate_cont = zeros(length(electrodes),length(time_vector));
    for iElec = 1:length(electrodes)
        iElec
        spike_disc_ts = double(NEVNSx.NEV.Data.Spikes.TimeStamp(NEVNSx.NEV.Data.Spikes.Electrode==nev_elec(iElec)))/30000;
        num_spikes(iElec) = length(spike_disc_ts);
        if length(spike_disc_ts)>1
            firing_rate_disc(iElec,:) = train2bins_mex(spike_disc_ts,time_vector)/.05;
        end
    end
    
    %%
    for iThres = 1:length(threshold_vector)
        NEVNSx_new = [];
        NEVNSx_new.NEV.Data.Spikes.TimeStamp = uint32([]);
        NEVNSx_new.NEV.Data.Spikes.Electrode = uint16([]);
        NEVNSx_new.NEV.Data.Spikes.Unit = uint8([]);
        NEVNSx_new.NEV.Data.Spikes.Waveform = uint16([]);
        NEVNSx_new.NEV.Data.Spikes.WaveformUnit = 'raw';
        for iElec = 1:length(electrodes)
            [fs_idx iThres iElec]
            raw_data_10k = double(NEVNSx.NS4.Data(iElec,:));
            raw_data_10k = filtfilt(b_high,a_high,raw_data_10k);
            %             temp_raw_data = raw_data_2k(iElec,:);
            temp_raw_data = raw_data_10k;
            if new_fs ~= 10000
                temp_raw_data = resample(temp_raw_data,new_fs,10000);
            end
            temp_raw_data = resample(temp_raw_data,30000,new_fs);
            
            threshold_new_fs = -rms(temp_raw_data)*threshold_vector(iThres);
            spikes_new_fs = find(temp_raw_data<threshold_new_fs & [0 diff(temp_raw_data-threshold_new_fs)] < 0);
            %             spikes_2k = spikes_2k*30000/10000;
            if ~isempty(spikes_new_fs)
                spike_cont_new_fs_ts = spikes_new_fs/30000;
                spike_cont_new_fs_ts(diff(spike_cont_new_fs_ts)<0.0016) = [];
                waveform_idx = repmat(spikes_new_fs,48,1) + repmat(idx_offset,1,length(spikes_new_fs));
                waveform_idx(waveform_idx>spikes_new_fs(end)) = spikes_new_fs(end);
                waveform_idx(waveform_idx<1) = 1;
                waveforms = reshape(temp_raw_data(waveform_idx),48,[]);
                
                NEVNSx_new.NEV.Data.Spikes.TimeStamp = [NEVNSx_new.NEV.Data.Spikes.TimeStamp uint32(spikes_new_fs)];
                NEVNSx_new.NEV.Data.Spikes.Electrode = [NEVNSx_new.NEV.Data.Spikes.Electrode uint16(repmat(electrodes(iElec),size(spikes_new_fs)))];
                NEVNSx_new.NEV.Data.Spikes.Unit = [NEVNSx_new.NEV.Data.Spikes.Unit uint8(zeros(size(spikes_new_fs)))];
                NEVNSx_new.NEV.Data.Spikes.Waveform = [NEVNSx_new.NEV.Data.Spikes.Waveform uint16(waveforms)];
                
                if length(spike_cont_new_fs_ts)>1
                    firing_rate_cont(iElec,:) = train2bins_mex(spike_cont_new_fs_ts,time_vector)/.05;
                    temp = corrcoef(firing_rate_cont(iElec,:),firing_rate_disc(iElec,:));
                    corr_coef_mat(iElec,iThres) = temp(2);
                end
            end
            
        end
        save([target_folder '\' params.file_prefix '-NEVNSx_' num2str(new_fs) '_new_' num2str(threshold_vector(iThres)) '_32chan'],'NEVNSx_new','-v7.3');
    end
    
    hf = figure; plot(threshold_vector,corr_coef_mat(num_spikes>NEVNSx.NS4.MetaTags.DataDurationSec,:)')
    xlabel('threshold (stds)')
    ylabel('R')
    title({'Crosscorrelation between firing rates at 30kHz and';'rate of threshold crossings at 2kHz'})
    saveas(hf,[target_folder 'Crosscorrelations ' num2str(new_fs) ' Hz 32chan'],'fig')
    
    %%
    NEVNSx_temp.NEV = NEVNSx.NEV;
    NEVNSx_temp.NS2 = NEVNSx.NS2;
    NEVNSx_temp.NS3 = NEVNSx.NS3;
    % NEVNSx_temp.NS2 = [];
    % NEVNSx_temp.NS3 = [];
    NEVNSx_temp.NS4 = [];
    NEVNSx_temp.NS5 = [];
    NEVNSx_temp.MetaTags = NEVNSx.MetaTags;
    bdf_0 = get_nev_mat_data(NEVNSx_temp,3);
    %%
    bdf_units = [];
    for iThres = 1:length(threshold_vector)
        [fs_idx iThres]
        load([target_folder params.file_prefix '-NEVNSx_' num2str(new_fs) '_new_' num2str(threshold_vector(iThres)) '_32chan'])
        NEVNSx_temp.NEV.Data.Spikes = NEVNSx_new.NEV.Data.Spikes;
        bdf_temp = get_nev_mat_data(NEVNSx_temp,3);
        bdf_units{iThres} = bdf_temp.units;
    end
    save([target_folder params.file_prefix '-bdfs_' num2str(new_fs) '_32chan'],'bdf_0','bdf_units','-v7.3')
    
    
    options = struct('binsize',0.05,'starttime',1,'stoptime',0,'FindStates',false,'Unsorted',true);
    mfxval_options = struct('fillen',.5,'PredVeloc',1,'PredEMGs',0);
    mfxval_options_emg = struct('fillen',.5,'PredVeloc',0,'PredEMGs',1);
    
    binnedData_0 = convertBDF2binned(bdf_0,options);
    
    rm_idx = find(sum(binnedData_0.spikeratedata)<binnedData_0.timeframe(end));
    binnedData_0.neuronIDs(rm_idx,:) = [];
    binnedData_0.spikeratedata(:,rm_idx) = [];
    
    %%
    %     if ~exist([target_folder params.file_prefix '-VAFs_vel_' num2str(new_fs) '_32chan.mat'],'file')
    
    chan_subset = [];
    binnedData_sub = binnedData_0;
    VAF_spikes = [];
    R2_spikes = [];
    MSE_spikes = [];
    VAF_spikes_EMG = [];
    MSE_spikes_EMG = [];
    R2_spikes_EMG = [];
    
    binnedData = [];
    bdf_temp = bdf_0;
    for iThres = 1:length(threshold_vector)
        bdf_temp.units = bdf_units{iThres};
        binnedData{iThres} = convertBDF2binned(bdf_temp,options);        
    end
    
    VAF = {};
    MSE = {};
    R2 = {};
    VAF_EMG = {};
    MSE_EMG = {};
    R2_EMG = {};
    for iPerm = 1:10
        temp = randperm(size(binnedData_0.spikeratedata,2));
        chan_subset = temp(1:32);
        binnedData_sub.spikeratedata = binnedData_0.spikeratedata(:,chan_subset);
        binnedData_sub.neuronIDs = binnedData_0.neuronIDs(chan_subset,:);
        [temp_R2, temp_VAF, temp_MSE] = mfxval(binnedData_sub,mfxval_options);
        VAF_spikes = [VAF_spikes ; temp_VAF];
        MSE_spikes = [MSE_spikes ; temp_MSE];
        R2_spikes = [R2_spikes ; temp_R2];
        
        if ~isempty(binnedData_sub.emgdatabin)
            [temp_R2, temp_VAF, temp_MSE] = mfxval(binnedData_sub,mfxval_options_emg);
            VAF_spikes_EMG = [VAF_spikes_EMG ; temp_VAF];
            MSE_spikes_EMG = [MSE_spikes_EMG ; temp_MSE];
            R2_spikes_EMG = [R2_spikes_EMG ; temp_R2];
        end
        
        for iThres = 1:length(threshold_vector)
            rm_idx = find(sum(binnedData{iThres}.spikeratedata)<binnedData{iThres}.timeframe(end));
            binnedData{iThres}.neuronIDs(rm_idx,:) = [];
            binnedData{iThres}.spikeratedata(:,rm_idx) = [];
            temp = randperm(size(binnedData{iThres}.spikeratedata,2));
            chan_subset = temp(1:32);
            binnedData_sub.spikeratedata = binnedData{iThres}.spikeratedata(:,chan_subset);
            binnedData_sub.neuronIDs = binnedData{iThres}.neuronIDs(chan_subset,:);
            [temp_R2, temp_VAF, temp_MSE] = mfxval(binnedData_sub,mfxval_options);
            if length(VAF)<iThres
                VAF{iThres} = [];
                MSE{iThres} = [];
                R2{iThres} = [];
                VAF_EMG{iThres} = [];
                MSE_EMG{iThres} = [];
                R2_EMG{iThres} = [];
            end
            VAF{iThres} = [VAF{iThres} ; temp_VAF];
            MSE{iThres} = [MSE{iThres} ; temp_MSE];
            R2{iThres} = [R2{iThres} ; temp_R2];
            
            if ~isempty(binnedData_sub.emgdatabin)
                [temp_R2, temp_VAF, temp_MSE] = mfxval(binnedData_sub,mfxval_options_emg);
                VAF_EMG{iThres} = [VAF_EMG{iThres} ; temp_VAF];
                MSE_EMG{iThres} = [MSE_EMG{iThres} ; temp_MSE];
                R2_EMG{iThres} = [R2_EMG{iThres} ; temp_R2];
            end
        end
    end
    emg_labels = binnedData{1}.emgguide;
    save([target_folder params.file_prefix '-VAFs_vel_' num2str(new_fs) '_32chan'],'VAF','VAF_spikes','R2','R2_spikes',...
        'MSE','MSE_spikes','threshold_vector','VAF_EMG','MSE_EMG','R2_EMG')
    %     else
    %         load([target_folder params.file_prefix '-VAFs_vel_' num2str(new_fs) '_32chan'])
    %     end
    
    hf = figure;
    hold on
    errorbar(-.2,mean(VAF_spikes(2:end,1)),std(VAF_spikes(2:end,1)),'b')
    errorbar(.2,mean(VAF_spikes(2:end,2)),std(VAF_spikes(2:end,2)),'r')
    
    for iThres = 1:length(threshold_vector)
        errorbar(threshold_vector(iThres)-.2,mean(VAF{iThres}(2:end,1)),std(VAF{iThres}(2:end,1)),'b')
        errorbar(threshold_vector(iThres)+.2,mean(VAF{iThres}(2:end,2)),std(VAF{iThres}(2:end,2)),'r')
    end
    
    xlabel('Threshold (stds)')
    ylabel('VAF')
    title(['Vel VAF as a function of threshold. Fs = ' num2str(new_fs)])
    legend('X vel','Y vel')
    ylim([0 1])
    saveas(hf,[target_folder 'VAF Vel ' num2str(new_fs) ' Hz 32chan'],'fig')
    
    hf = figure;
    hold on
    errorbar(-.2,mean(R2_spikes(2:end,1)),std(R2_spikes(2:end,1)),'b')
    errorbar(.2,mean(R2_spikes(2:end,2)),std(R2_spikes(2:end,2)),'r')
    
    for iThres = 1:length(threshold_vector)
        errorbar(threshold_vector(iThres)-.2,mean(R2{iThres}(2:end,1)),std(R2{iThres}(2:end,1)),'b')
        errorbar(threshold_vector(iThres)+.2,mean(R2{iThres}(2:end,2)),std(R2{iThres}(2:end,2)),'r')
    end
    
    xlabel('Threshold (stds)')
    ylabel('R2')
    title(['Vel R2 as a function of threshold. Fs = ' num2str(new_fs)])
    legend('X vel','Y vel')
    ylim([0 1])
    saveas(hf,[target_folder 'R2 Vel ' num2str(new_fs) ' Hz 32chan'],'fig')
    
    
    hf = figure;
    hold on
    errorbar(-.2,mean(VAF_spikes_EMG(2:end,1)),std(VAF_spikes_EMG(2:end,1)),'b')
    errorbar(.2,mean(VAF_spikes_EMG(2:end,2)),std(VAF_spikes_EMG(2:end,2)),'r')
    
    for iThres = 1:length(threshold_vector)
        errorbar(threshold_vector(iThres)-.2,mean(VAF_EMG{iThres}(2:end,1)),std(VAF_EMG{iThres}(2:end,1)),'b')
        errorbar(threshold_vector(iThres)+.2,mean(VAF_EMG{iThres}(2:end,2)),std(VAF_EMG{iThres}(2:end,2)),'r')
    end
    
    xlabel('Threshold (stds)')
    ylabel('VAF')
    title(['EMG VAF as a function of threshold. Fs = ' num2str(new_fs)])
    legend(emg_labels)
    ylim([0 1])
    saveas(hf,[target_folder 'VAF EMG ' num2str(new_fs) ' Hz 32chan'],'fig')
    
    hf = figure;
    hold on
    errorbar(-.2,mean(R2_spikes_EMG(2:end,1)),std(R2_spikes_EMG(2:end,1)),'b')
    errorbar(.2,mean(R2_spikes_EMG(2:end,2)),std(R2_spikes_EMG(2:end,2)),'r')
    
    for iThres = 1:length(threshold_vector)
        errorbar(threshold_vector(iThres)-.2,mean(R2_EMG{iThres}(2:end,1)),std(R2_EMG{iThres}(2:end,1)),'b')
        errorbar(threshold_vector(iThres)+.2,mean(R2_EMG{iThres}(2:end,2)),std(R2_EMG{iThres}(2:end,2)),'r')
    end
    
    xlabel('Threshold (stds)')
    ylabel('R2')
    title(['EMG R2 as a function of threshold. Fs = ' num2str(new_fs)])
    legend(emg_labels)
    ylim([0 1])
    saveas(hf,[target_folder 'R2 EMG ' num2str(new_fs) ' Hz 32chan'],'fig')
end
