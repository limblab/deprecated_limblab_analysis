function results = get_force_direction(filenames,params)


detrend_data = true;

file_dir = params.file_dir;
monkey = params.monkey;
time_before = params.time_before;
time_after = params.time_after;
kin_samp_freq = params.kin_samp_freq;
zoom_window = params.zoom_window;
detrend_window = params.detrend_window;

t = -floor(time_before*kin_samp_freq):floor(time_after*kin_samp_freq);
t_zoom = -floor(zoom_window(1)*kin_samp_freq):floor(zoom_window(2)*kin_samp_freq);

idx_peak = find(t_zoom >= 100,1,'first');

%%
filename = filenames{1};
cerebus_number = filenames{2};
epoch = filenames{3};

switch lower(monkey)
    case 'jaco'
        bank = filename(6);
end

switch lower(bank)
    case 'a', bank_offset = 0;
    case 'b', bank_offset = 32;
    case 'c', bank_offset = 64;
end

load(fullfile(file_dir,[filename cerebus_number '_stim_data.mat']),'stim_data');
channels = unique([stim_data.channel]);

for i = 1:length(channels)
    
    use_chans = find([stim_data.channel] == channels(i));
    
    all_f = zeros(length(use_chans),length(t),2);
    all_f_detrend = zeros(length(use_chans),length(t_zoom),2);
    
    all_v = zeros(length(use_chans),length(t),2);
    all_v_detrend = zeros(length(use_chans),length(t_zoom),2);
    % get data
    for j = 1:length(use_chans)
        
        f = stim_data(use_chans(j)).force;
        
        all_f(j,:,:) = f;
        
        % detrend
        zoom_idx = [floor((time_before-zoom_window(1))*kin_samp_freq),floor((time_before+zoom_window(2))*kin_samp_freq)];
        detrend_idx = [floor((time_before-detrend_window(1))*kin_samp_freq),floor((time_before+detrend_window(2))*kin_samp_freq)];
        
        v = stim_data(use_chans(j)).vel;
        all_v(j,:,:) = v;
        all_v_detrend(j,:,:) = v(zoom_idx(1):zoom_idx(2),:);
        
        if detrend_idx(1) == 0, detrend_idx(1) = 1; end
        
        if detrend_data
            b1 = regress(stim_data(use_chans(j)).force(detrend_idx(1):detrend_idx(2),1),[ones(1+detrend_idx(2)-detrend_idx(1),1), (1:1+detrend_idx(2)-detrend_idx(1))']);
            b2 = regress(stim_data(use_chans(j)).force(detrend_idx(1):detrend_idx(2),2),[ones(1+detrend_idx(2)-detrend_idx(1),1), (1:1+detrend_idx(2)-detrend_idx(1))']);
            f = [stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),1) - (b1(1) + b1(2)*(1:length(stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),1))))', stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),2) - (b2(1) + b2(2)*(1:length(stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),2))))'];
        else
            b1 = mean(stim_data(use_chans(j)).force(detrend_idx(1):detrend_idx(2),1));
            b2 = mean(stim_data(use_chans(j)).force(detrend_idx(1):detrend_idx(2),2));
            f = [stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),1)-b1, stim_data(use_chans(j)).force(zoom_idx(1):zoom_idx(2),2)-b2];
        end
        
        % store all zoomed traces for use later
        all_f_detrend(j,:,:) = f;
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
    results(i).bank = bank;
    results(i).pin = channels(i);
    results(i).elec = bank_offset + channels(i);
    results(i).epoch = epoch;
    results(i).directions = theta;
    results(i).vel = all_v;
    results(i).vel_detrend = all_v_detrend;
    results(i).force = all_f;
    results(i).force_detrend = all_f_detrend;
end
