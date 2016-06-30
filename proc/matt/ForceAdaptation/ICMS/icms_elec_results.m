% Look at tuning of each channel and rank them
if compare_tuning
    load(tuning_filename);
    
    r = mean(tuning.r_squared,2);
    temp = isnan(r);
    r(temp) = 0;
    [s,I] = sort(r,1,'descend');
    s(temp(I)) = NaN;
    
    ids = tuning.sg(I,1);
    
    % 1: bank
    % 2: electrode number
    % 3: tuning r^2
    % 4: twitch confidence
    elec_info = cell(length(ids),4);
    for i = 1:length(ids)
        if ids(i) <= 32
            elec_info{i,1} = 'A';
            elec_info{i,2} = ids(i);
        elseif ids(i) > 64
            elec_info{i,1} = 'C';
            elec_info{i,2} = ids(i)-64;
        else
            elec_info{i,1} = 'B';
            elec_info{i,2} = ids(i)-32;
        end
        elec_info{i,3} = s(i);
    end
else
    elec_info = [];
end
clear r temp s I ids i;

t = -floor(time_before*kin_samp_freq):floor(time_after*kin_samp_freq);
t_zoom = -floor(zoom_window(1)*kin_samp_freq):floor(zoom_window(2)*kin_samp_freq);

idx_peak = find(t_zoom >= 100,1,'first');

count = 0;
clear elec_results;
for iFile = 1:size(filenames,1)
    filename = filenames{iFile,1};
    cerebus_number = filenames{iFile,2};
    switch lower(monkey)
        case 'jaco'
            bank = filename(6);
    end
    
    load(fullfile(file_dir,[filename cerebus_number '_stim_data.mat']),'stim_data');
    channels = unique([stim_data.channel]);
    
    for i = 1:length(channels)
        count = count+1;
        
        use_chans = find([stim_data.channel] == channels(i));
        
        all_f = zeros(length(use_chans),length(t),2);
        all_f_detrend = zeros(length(use_chans),length(t_zoom),2);
        % get data
        for j = 1:length(use_chans)
            
            f = stim_data(use_chans(j)).(use_signal);
            all_f(j,:,:) = f;
            
            % detrend
            zoom_idx = [floor((time_before-zoom_window(1))*kin_samp_freq),floor((time_before+zoom_window(2))*kin_samp_freq)];
            detrend_idx = [floor((time_before-detrend_window(1))*kin_samp_freq),floor((time_before+detrend_window(2))*kin_samp_freq)];
            if detrend_idx(1) == 0, detrend_idx(1) = 1; end
            
            if detrend_data
                b1 = regress(stim_data(use_chans(j)).(use_signal)(detrend_idx(1):detrend_idx(2),1),[ones(1+detrend_idx(2)-detrend_idx(1),1), (1:1+detrend_idx(2)-detrend_idx(1))']);
                b2 = regress(stim_data(use_chans(j)).(use_signal)(detrend_idx(1):detrend_idx(2),2),[ones(1+detrend_idx(2)-detrend_idx(1),1), (1:1+detrend_idx(2)-detrend_idx(1))']);
                f = [stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),1) - (b1(1) + b1(2)*(1:length(stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),1))))', stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),2) - (b2(1) + b2(2)*(1:length(stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),2))))'];
            else
                b1 = mean(stim_data(use_chans(j)).(use_signal)(detrend_idx(1):detrend_idx(2),1));
                b2 = mean(stim_data(use_chans(j)).(use_signal)(detrend_idx(1):detrend_idx(2),2));
                f = [stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),1)-b1, stim_data(use_chans(j)).(use_signal)(zoom_idx(1):zoom_idx(2),2)-b2];
            end
            
            % store all zoomed traces for use later
            all_f_detrend(j,:,:) = f;
        end
        
        % Look for bad trials!
        bad_stims = zeros(1,size(all_f,1));
        if mark_bad_trials
            % look for outlier trials right after stim train begins
            m = zeros(1,size(all_f_detrend,1));
            for j = 1:size(all_f_detrend,1)
                f = squeeze(all_f_detrend(j,:,:));
                
                % filter out bad trials if outlier pre/post stim
                idx = t_zoom >= 0 & t_zoom <= bad_trial_window*kin_samp_freq;
                m(j) = mean(hypot(f(idx,1),f(idx,2)));
            end
            baseline_noise = mean(m)+3*std(m);
            bad_stims = bad_stims | (m > mean(m)+3*std(m) | m < mean(m)-3*std(m));
            
            % look for outlier trials in middle
            m = zeros(1,size(all_f_detrend,1));
            for j = 1:size(all_f_detrend,1)
                f = squeeze(all_f_detrend(j,:,:));
                idx = t_zoom >= 100 - bad_trial_window*kin_samp_freq/2 & t_zoom <= 100 + bad_trial_window*kin_samp_freq/2;
                m(j) = mean(hypot(f(idx,1),f(idx,2)));
            end
            bad_stims = bad_stims | (m > mean(m)+3*std(m) | m < mean(m)-3*std(m));
            
            % look for outlier trials at end
            m = zeros(1,size(all_f_detrend,1));
            for j = 1:size(all_f_detrend,1)
                f = squeeze(all_f_detrend(j,:,:));
                
                % filter out bad trials if outlier pre/post stim
                idx = t_zoom >= t_zoom(end) - bad_trial_window*kin_samp_freq;
                m(j) = mean(hypot(f(idx,1),f(idx,2)));
            end
            bad_stims = bad_stims | (m > mean(m)+3*std(m) | m < mean(m)-3*std(m));
            
            % look for trials with no response
            m = zeros(1,size(all_f_detrend,1));
            for j = 1:size(all_f_detrend,1)
                f = squeeze(all_f_detrend(j,:,:));
                m(j) = max(hypot(f(:,1),f(:,2)));
            end
            bad_stims = bad_stims | (m < baseline_noise); %0.25
        end
        
        % now do some directionality stuff
        theta = zeros(1,size(all_f_detrend,1));
        for j = 1:size(all_f_detrend,1)
            f = squeeze(all_f_detrend(j,:,:));
            % get time of peak from magnitude
            %[~,idx_peak] = max(hypot(f(:,1),f(:,2)));
            
            % get force at peak and find angle
            theta(j) = atan2(f(idx_peak,2),f(idx_peak,1));
        end
        
        % add to a master data struct
        
        elec_results(count).bank = bank;
        elec_results(count).elec = channels(i);
        elec_results(count).stim.bad_stims = bad_stims;
        elec_results(count).stim.directions = theta;
        elec_results(count).stim.force = all_f;
        elec_results(count).stim.force_detrend = all_f_detrend;
        
        if compare_tuning
            idx = strcmpi(elec_info(:,1),bank) & cell2mat(elec_info(:,2))==channels(i);
            elec_info{idx,4} = circular_confmean(theta(~bad_stims)').*180/pi;
            
            if strcmpi(bank,'A')
                bank_offset = 0;
            elseif strcmpi(bank,'B')
                bank_offset = 32;
            elseif strcmpi(bank,'C')
                bank_offset = 64;
            end
            
            elec_idx = channels(i)+bank_offset;
            idx = tuning.sg(:,1)==elec_idx;
            elec_results(count).tuning.cosine = [tuning.boot_bos(idx,:); tuning.boot_mds(idx,:); tuning.boot_pds(idx,:)];
            elec_results(count).tuning.r_squared = tuning.r_squared(idx,:);
            elec_results(count).tuning.fr = tuning.fr(:,idx)';
        end
    end
end
save(fullfile(file_dir,'elec_results.mat'),'elec_results','elec_info');
clear iFile i bank_offset elec_idx idx j theta channels bank all_f_detrend all_f theta bad_stims f m b1 b2 zoom_idx detrend_idx use_chans count filename cerebus_number;

