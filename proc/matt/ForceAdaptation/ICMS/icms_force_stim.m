%%
close all;
clear;
clc;

%% define filename and parameters
params.root_dir = 'F:\';
params.monkey = 'Jaco';
params.dates = {'2016-02-22','2016-02-24','2016-02-25','2016-03-01','2016-03-02'};
epochs = {'BL','AD','WO'};

% processing parameters
params.use_signal = 'force';
params.pulse_thresh   = 1000;       % sync pulse threshold
params.sync_samp_freq = 10000;      % sync pulse sampling frequency (Hz)
params.kin_samp_freq  = 1000;       % kinematics sampling frequency (Hz)
params.time_before    = 0.8;        % time before sync pulse in sec
params.time_after     = 0.8;        % time after sync pulse in sec
params.detrend_window = [0.1,0];    % time window for detrending or mean [before,after]
params.zoom_window    = [0.1,0.15]; % time window for plotting zoomed data

% plotting parameters
params.mark_bad_trials = true;
params.font_size = 14;

results = [];
for idx_date = 1:length(params.dates)
    params.date = params.dates{idx_date};
    
    switch params.date
        case '2016-02-22'
            file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_22\';
            filenames = {'Jaco_A_19  20_20160222_154317_CO_TTA','001','BL'; ...
                %             'Jaco_A_19  20_20160222_160919_CO_TTA','002'; ...
                'Jaco_A_19  20_20160222_161548_CO_TTA','003','AD'; ...
                'Jaco_A_19  20_20160222_163204_CO_TTA','004','AD'; ...
                'Jaco_A_19  20_20160222_164532_CO_TTA','005','AD'; ...
                'Jaco_A_19  20_20160222_165814_CO_TTA','006','WO'};
        case '2016-02-24'
            filenames = {'Jaco_C_10  28_20160224_133438_CO_TTA','001','BL'; ...
                'Jaco_C_10_20160224_134917_CO_TTA','002','AD'; ...
                'Jaco_C_10_20160224_143328_CO_TTA','003','AD'; ...
                'Jaco_C_10_20160224_144205_CO_TTA','004','AD'; ...
                'Jaco_C_10_20160224_144638_CO_TTA','005','WO'; ...
                'Jaco_C_10_20160224_145858_CO_TTA','006','WO'};
        case '2016-02-25'
            filenames = {'Jaco_C_6   9  13_20160225_104957_CO_TTA','001','BL'; ...
                'Jaco_C_6  13_20160225_110219_CO_TTA','002','AD'; ...
                'Jaco_C_6  13_20160225_115422_CO_TTA','003','WO'; ...
                'Jaco_C_6  13_20160225_121040_CO_TTA','004','WO'};
        case '2016-02-26'
            file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_02_26\';
            filenames = {'Jaco_C_1  14  15  16  17  18  19  20  21  22  24  26  27  28  29  30  31_20160226_132112_CO_TTA','001','BL'; ...
                'Jaco_A_1   2   4   6   9  10  11  12  13  14  16  18  19  22  23  24  27  30_20160226_135648_CO_TTA','002','BL'; ...
                'Jaco_B_25  26  27  28  31_20160226_143513_CO_TTA','003','BL'};
        case '2016-03-01'
            file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_03_01\';
            filenames = {'Jaco_C_21  19  20  18_20160301_135208_CO_TTA','001','BL'; ...
                'Jaco_C_21  19  20  18_20160301_135421_CO_TTA','002','BL'; ...
                'Jaco_C_21  19  20  18_20160301_141507_CO_TTA','003','AD'; ...
                'Jaco_C_21  19  20  18_20160301_152150_CO_TTA','004','WO'; ...
                'Jaco_C_21  19  20  18_20160301_154839_CO_TTA','005','WO'};
        case '2016-03-02'
            file_dir = 'F:\Jaco\ICMS_testing\TTA_data_2016_03_02\';
            filenames = {'Jaco_C_2   3   4   5   6   7   8   9  10  11  12  13  23  25_20160302_121948_CO_TTA','001','BL'; ...
                'Jaco_C_4   5  21_20160302_122826_CO_TTA','002','BL'; ...
                'Jaco_C_9_20160302_123334_CO_TTA','003','BL'; ...
                'Jaco_C_5   9  21_20160302_123532_CO_TTA','004','BL'; ...
                'Jaco_C_5   9  21_20160302_124752_CO_TTA','005','AD'; ...
                'Jaco_C_5   9  21_20160302_131706_CO_TTA','006','AD'; ...
                'Jaco_C_5   9  21_20160302_133205_CO_TTA','007','AD'; ...
                'Jaco_C_5   9  21_20160302_133717_CO_TTA','008','WO'; ...
                'Jaco_C_5   9  21_20160302_135047_CO_TTA','009','WO'};
    end
    
    %
    y = params.date(1:4); m = params.date(6:7); d = params.date(9:10);
    params.file_dir = fullfile(params.root_dir,params.monkey,'ICMS_testing',['TTA_data_' y '_' m '_' d]);
    
    %
    icms_read_nev(filenames,params);
    
    for i = 1:size(filenames,1)
        results = [results get_force_direction(filenames(i,:),params)];
    end
end
params = rmfield(params,{'file_dir','date'});

%%
elecs = unique([results.elec]);

stims = cell(1,length(elecs));
for i = 1:length(elecs)
    % check to ensure this electrode exists for all epochs
    elec_idx = [results.elec] == elecs(i);
    if isempty(setxor(epochs,unique({results(elec_idx).epoch})))
        % get data for each epoch
        for j = 1:length(epochs)
            idx = find(elec_idx & strcmpi({results.epoch},epochs{j}));
            
            stims{i}(j).elec = results(idx(1)).elec;
            stims{i}(j).bank = results(idx(1)).bank;
            stims{i}(j).pin = results(idx(1)).pin;
            stims{i}(j).directions = results(idx(1)).directions;
            stims{i}(j).force = results(idx(1)).force;
            stims{i}(j).force_detrend = results(idx(1)).force_detrend;
            stims{i}(j).vel = results(idx(1)).vel;
            stims{i}(j).vel_detrend = results(idx(1)).vel_detrend;
            
            for k = 2:length(idx)
                stims{i}(j).directions = [stims{i}(j).directions, results(idx(k)).directions];
                stims{i}(j).force = cat(1, stims{i}(j).force, results(idx(k)).force);
                stims{i}(j).force_detrend = cat(1, stims{i}(j).force_detrend, results(idx(k)).force_detrend);
                stims{i}(j).vel = cat(1, stims{i}(j).vel, results(idx(k)).vel);
                stims{i}(j).vel_detrend = cat(1, stims{i}(j).vel_detrend, results(idx(k)).vel_detrend);
            end
        end
    end
end

elecs(cellfun(@isempty,stims)) = [];
stims(cellfun(@isempty,stims)) = [];

%% Identify bad stim attempts
win_size = -5;
stim_idx = round( params.zoom_window(1)*params.kin_samp_freq);

% loop along electrodes
for i = 1:length(stims)
    s = stims{i};
    for j = 1:length(s)
        bad_stims = zeros(size(s(j). vel,1),1);
        
        % see if velocity in pre-stim window is below threshold
        v = zeros(size(s(j).vel,1),1);
        for k = 1:size(s(j).vel,1)
            v(k) = any(hypot(s(j).vel_detrend(k,1:stim_idx+win_size,1),s(j).vel_detrend(k,1:stim_idx+win_size,1)) > 1.1);
        end
        bad_stims = bad_stims | v;
        
%         % look at std at direction time
%         v = zeros(size(s(j).vel,1),2);
%         for k = 1:size(s(j).vel,1)
%             v(k,:) = [s(j).force_detrend(k,stim_idx+40,1),s(j).force_detrend(k,stim_idx+40,1)];
%         end
%         bad_stims = bad_stims | v(:,1) > mean(v(:,1))+std(v(:,1)) | ...
%                                 v(:,1) < mean(v(:,1))-std(v(:,1)) | ...
%                                 v(:,2) > mean(v(:,2))+std(v(:,2)) | ...
%                                 v(:,2) < mean(v(:,2))-std(v(:,2));
        
        stims{i}(j).bad_stims = bad_stims;
    end
    
end

% raw_stim_plots(stims{2}(1),params)


%% Plot twitch over time

bin_size = 30;

close all;
for i = 1:length(stims)
    bad_stims = stims{i}(3).bad_stims;
    theta = stims{i}(3).directions(~bad_stims);
    bl = circular_mean(theta(floor(length(theta)/2):end)');
    
    theta = [];
    theta_std = [];
    counts = zeros(1,length(epochs)-1);
    for j = 1:length(epochs)
        bad_stims = stims{i}(j).bad_stims;
        s = stims{i}(j).directions(~bad_stims);
%         s = angleDiff(s,repmat(bl,size(s)),true,true);
        
        % now, bin
        if length(s) <= bin_size
            s_bin = circular_mean(s');
            s_bin_std = circular_std(s');
        else
            bin_vec = 1:bin_size:length(s);
            s_bin = zeros(size(bin_vec));
            s_bin_std = zeros(size(bin_vec));
            for k = 1:length(bin_vec)-1
                s_bin(k) = circular_mean(s(bin_vec(k):bin_vec(k+1))');
                s_bin_std(k) = circular_std(s(bin_vec(k):bin_vec(k+1))');
            end
        end
        
        theta = [theta, s_bin];
        theta_std = [theta_std, s_bin_std];
        
        counts(j) = bin_size*length(theta)-bin_size/2;
    end
    
    bin_vec = bin_size*(0:length(theta)-1);
    theta = angleDiff(theta,repmat(circular_mean(theta'),size(theta)),true,true);
    
    figure;
    hold all;
    plot(bin_vec,theta,'ko','LineWidth',2);
    plot([bin_vec; bin_vec],[theta-theta_std; theta+theta_std],'k-','LineWidth',2);
    plot([counts; counts],[repmat(-pi,size(counts)); repmat(pi,size(counts))],'k--');
    
    set(gca,'Box','off','TickDir','out','FontSize',14,'YLim',[-pi,pi],'XLim',[-1 bin_vec(end)+1]);
    xlabel('Stim Attempt','FontSize',14);
    ylabel('Centered Direction','FontSize',14);
    title([stims{i}(1).bank num2str(stims{i}(1).pin)],'FontSize',14);
end











%%
% % % %% Plot the raw traces
% % % idx_epoch = 2;
% % % params.mark_bad_trials = true;
% % % for i = 1:length(stims)
% % %     cm(i) = circular_confmean(stims{i}(idx_epoch).directions');
% % % end
% % % 
% % % [s,I] = sort(cm.*180/pi);
% % % 
% % % I = I(~isnan(s));
% % % s = s(~isnan(s));
% % % 
% % % for i = 1:length(I)
% % %     raw_stim_plots(stims{I(i)}(idx_epoch),params)
% % %     pause
% % %     close all
% % % end

%%
% figure;
% hold all;
% 
% file_sizes = zeros(1,length(elec_results));
% 
% i = 1;
% bad_stims = elec_results(i).stim.bad_stims;
% directions = elec_results(i).stim.directions;
% force = elec_results(i).stim.force;
% force_detrend = elec_results(i).stim.force_detrend;
% 
% sep_dir{1} = directions(~bad_stims);
% 
% for i = 5:2:length(elec_results)
%     bad_stims = [bad_stims, elec_results(i).stim.bad_stims];
%     directions = [directions, elec_results(i).stim.directions];
%     force = cat(1,force,elec_results(i).stim.force);
%     force_detrend = cat(1,force_detrend,elec_results(i).stim.force_detrend);
% end
% 
% directions = directions(~bad_stims);
% force = force(~bad_stims,:,:);
% force_detrend = force_detrend(~bad_stims,:,:);
% 
% % As a first crack, remove outliers in direction data
% outliers = directions > circular_mean(directions')+6*circular_std(directions') | directions < circular_mean(directions')-6*circular_std(directions');
% directions = directions(~outliers);
% 
% % look at mean in bins
% bin_size = 60;
% bins = 1:bin_size:length(directions);
% bin_dir = zeros(length(bins)-1,2);
% for i = 2:length(bins)
%     bin_dir(i-1,1) = circular_mean(directions(bins(i-1):bins(i))').*(180/pi);
%     %     bin_dir(i-1,2) = circular_std(directions(bins(i-1):bins(i))').*(180/pi)./sqrt(bin_size);
%     bin_dir(i-1,2) = circular_confmean(directions(bins(i-1):bins(i))').*(180/pi);
% end
% 
% bins = bins(2:end) - bin_size/2;
% 
% for i = 1:length(bins)
%     plot(bins(i),bin_dir(i,1),'bo','LineWidth',2);
%     plot([bins(i),bins(i)],[bin_dir(i,1)+bin_dir(i,2), bin_dir(i,1)-bin_dir(i,2)],'b-','LineWidth',2);
% end
% 
% n = 60; plot([n n],[60 160],'k--');
% n = 510; plot([n n],[60 160],'k--');
% 
% % set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 bins(end)+bin_size/2],'YLim',[60 160]);
% xlabel('Stimulation Number','FontSize',14);
% ylabel('Direction of Twitch','FontSize',14);
% title('2/24/16: Jaco, Bank C, Elec 10, CCW CF','FontSize',14);
