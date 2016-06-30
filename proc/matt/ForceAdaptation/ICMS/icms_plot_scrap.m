
%% Get information for each electrode
close all;

if isempty(tuning_filename)
    compare_tuning = false;
end

icms_elec_results;


%% make some plots
params.use_signal = use_signal;
params.mark_bad_trials = mark_bad_trials; % plot bad trials as red
params.bad_trial_window = bad_trial_window; % how large of a window to look for deviations
params.detrend_data = detrend_data; % if false, just subtracts mean
params.detrend_window = detrend_window; % time window for detrending or mean [before,after]
params.zoom_window = zoom_window; % time window for plotting zoomed data
params.pulse_thresh = pulse_thresh;
params.sync_samp_freq = sync_samp_freq;
params.kin_samp_freq = kin_samp_freq;
params.time_before = time_before; % time before sync pulse in sec
params.time_after  = time_after; % time after sync pulse in sec

if ~skip_plots
    params.compare_tuning = compare_tuning;
    icms_elec_plots(elec_results,params);
end


%% 
% % %% Pool results from a couple of days
% % % NOTE: Assumes there are no overlapping electrodes for now
% % file_dirs = {'F:\Jaco\ICMS_testing\TTA_data_2016_02_17\','F:\Jaco\ICMS_testing\TTA_data_2016_02_18\'};
% % 
% % load(fullfile(file_dirs{1},'elec_results.mat'));
% % temp_results = elec_results;
% % temp_info = elec_info;
% % for iFile = 2:length(file_dirs)
% %     load(fullfile(file_dirs{iFile},'elec_results.mat'));
% %     temp_results = [temp_results elec_results];
% %     idx = ~cellfun(@(x) isempty(x), elec_info(:,4));
% %     temp_info(idx,:) = elec_info(idx,:);
% % end
% % elec_results = temp_results; elec_info = temp_info; clear temp_results temp_info iFile;


%% plot summary
% filter based on crosstalk
use_elecs = elec_info(elec_crosstalk < 100,:);
use_elecs = use_elecs(~cellfun(@(x) isempty(x), use_elecs(:,4)),:);
use_elecs = use_elecs(~cellfun(@(x) isnan(x),use_elecs(:,4)),:);
% filter based on r2
use_elecs = use_elecs(cell2mat(use_elecs(:,3)) >= 0.5,:);

all_data = zeros(size(use_elecs,1),3);
for i = 1:size(use_elecs,1)
    idx = find(strcmpi({elec_results.bank},use_elecs{i,1}) & [elec_results.elec] == use_elecs{i,2});
    
    s = elec_results(idx).stim.directions(~elec_results(idx).stim.bad_stims);
    t = elec_results(idx).tuning.cosine(3,:);
    
    s_boot = zeros(1,length(t));
    for j = 1:length(t)
        idx = randi(length(s),1,length(s));
        s_boot(j) = circular_mean(s(idx)');
    end
    
    all_data(i,1) = circular_mean(s_boot');
    all_data(i,2) = circular_mean(t');
    all_data(i,3) = circular_mean(angleDiff(t,s_boot,true,true)');
    
    figure;
    num_bins = 50;
    % plots distribution of PDs
    pd_bin = linspace(-pi, pi, num_bins);
    freq = histc(s_boot,pd_bin);
    freq_norm = freq/max(freq);
    freq_norm(end) = freq_norm(1);
    pd_bin(end) = pd_bin(1);
    % plot polar pd distribution
    h_pol = polar(pd_bin(:),freq_norm(:),'b-');
    set(h_pol,'LineWidth',3)
    
    hold all
    % plots distribution of PDs
    pd_bin = linspace(-pi, pi, num_bins);
    freq = histc(t,pd_bin);
    freq_norm = freq/max(freq);
    freq_norm(end) = freq_norm(1);
    pd_bin(end) = pd_bin(1);
    % plot polar pd distribution
    h_pol = polar(pd_bin(:),freq_norm(:),'r-');
    set(h_pol,'LineWidth',3)
%         pause;
    close all;
end

figure;
rose(all_data(:,3),72)
set(gca,'Box','off','TickDir','out','FontSize',14);
title('Difference between Channel PD and Twitch Direction','FontSize',14);

figure;
plot(all_data(:,1)*180/pi,all_data(:,2)*180/pi,'o');
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[-pi pi]*180/pi,'YLim',[-pi pi]*180/pi);
xlabel('Twitch Direction','FontSize',14);
ylabel('Channel PD','FontSize',14);
