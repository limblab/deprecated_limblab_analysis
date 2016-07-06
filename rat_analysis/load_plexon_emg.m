function ret = load_plexon_emg(animal,date,directories, channels)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cd([directories.rawdata 'plexon'])
filename = [animal '_' date '_GS.plx'];

[~,~,frequency,~,~,~,~,~,~,~,~,recording_length_sec,~] = plx_information(filename);
timedata.binwidth = 1;
timedata.timebinedges = 0:timedata.binwidth:recording_length_sec;
timedata.timebincenters = 0.5*timedata.binwidth+timedata.timebinedges(1:end-1);


%%%%%%%%%%%%%%%%%%%%%%%%% Get vicon frame/trial data from ad channel
disp('Getting Vicon on/off times'); 
[ad_freq,~,starttime_sec,~,vicon_duration] = plx_ad_v([animal '_' date '_GS.plx'], 16);
[~,~,~,~,vicon_frames]                     = plx_ad_v([animal '_' date '_GS.plx'], 17);

%%% Get EMG data %%%
disp('Getting EMG data'); 
emg_channel_data = struct(); 
for channel=channels %64
    [~,~,~,~,emg_channel_data(channel-48).v] = plx_ad_v([animal '_' date '_GS.plx'], channel);
    
end


disp(['Saving file ' animal '_' date '_emg.mat']); 
save([animal '_' date '_emg.mat'], 'emg_channel_data'); 

ret = 0; 

% plx_adchannel_times = starttime_sec+ (0:(1/ad_freq):(1/ad_freq)*(length(vicon_duration)-1));
% 
% trialstart_times = plx_adchannel_times(find(diff(vicon_duration) > 1)+1);
% trialend_times   = plx_adchannel_times(find(diff(vicon_duration) < -1));
% 
% figure; hold on;
% plot(plx_adchannel_times,frames,'r')
% plot(plx_adchannel_times,vicon_duration,'k')
% 
% framestart_inds = find(diff(frames) > 1)+1;
% frameend_inds = find(diff(frames) < -1);
% 
% if framestart_inds(1)>frameend_inds(1)
%     framestart_inds(1) = [];
% end
% if framestart_inds(end)>frameend_inds(end)
%     framestart_inds(1) = [];
% end
% 
% framestart_times = plx_adchannel_times(framestart_inds);
% frameend_times   = plx_adchannel_times(frameend_inds);
% 
% framestart_times(framestart_times<trialstart_times(1)) = [];
% frameend_times(frameend_times<trialstart_times(1)) = [];
% framestart_times(framestart_times>trialend_times(end)) = [];
% frameend_times(frameend_times>trialend_times(end)) = [];
% 
% plot(framestart_times,5.5*ones(length(framestart_times),1),'k+')
% plot(frameend_times,5*ones(length(frameend_times),1),'r+')
% keyboard
% trialdata_plexon = struct();
% for trialind = 1:length(trialstart_times)
%     
%     trialdata_plexon(trialind).starttime = trialstart_times(trialind);
%     trialdata_plexon(trialind).endtime   = trialend_times(trialind);
%     
%     trial_framestart_inds = find(framestart_times>=trialstart_times(trialind) & framestart_times<=trialend_times(trialind));
%     trial_frameend_inds   = find(frameend_times>=trialstart_times(trialind) & frameend_times<=trialend_times(trialind));
%    
%     if trial_framestart_inds(1)>trial_frameend_inds(1)
%         trial_framestart_inds(1) = [];
%     end
%     if trial_framestart_inds(end)>trial_frameend_inds(end)
%         trial_framestart_inds(1) = [];
%     end
%     
%     trial_framestart_times = framestart_times(trial_framestart_inds);
%     trial_frameend_times   = frameend_times(trial_frameend_inds);
%     
%     trialdata_plexon(trialind).frametimes = 0.5*(trial_framestart_times+trial_frameend_times);
% end
% 
% % 
% % % 
% % % figure; hold on;
% % % plot(plx_adchannel_times,frames,'r')
% % % plot(plx_adchannel_times,vicon_duration,'k')
% % % 
% % % plot(framestart_times,5*ones(length(framestart_times),1),'k+')
% % % plot(frameend_times,5*ones(length(frameend_times),1),'r+')
% % % 
% % % plot(trialdata_plexontart_times,[6 6],'ko')
% % % plot(trialend_times,[6 6],'ro')
% % % 
% % % for trialind = 1:length(trialdata_plexontart_times)
% % %     plot(trialdata_plexon(trialind).frametimes,5.5*ones(length(trialdata_plexon(trialind).frametimes),1),'k+')
% % % 
% % % end
% % % 
% % % 
