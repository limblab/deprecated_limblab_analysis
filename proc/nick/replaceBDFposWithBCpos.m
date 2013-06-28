clear
% HC_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013001';
% BC_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013002';
% log_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013001-binned_perfLDA_velDecoder_1stOrder_log';
HC_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013001';
BC_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013002';
log_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013001-binned_perfLDA_velDecoder_1stOrder_log';
out_struct = get_plexon_data([BC_file '.plx'],'verbose');
save('BC_file','out_struct');
uiopen([log_file '.txt'],1);

% set breakpoint on line 17 before running
% find 'startup'
% delete all above
% save as [log_file '_correctPos']

trial_log = load([log_file '_correctPos']);
for x = 1:length(out_struct.pos)
    out_struct.pos(x,2:3) = trial_log(find((trial_log(:,10)-trial_log(1,10))/10^9 > out_struct.pos(x,1),1,'first'),(5:6));
end
save([BC_file '_correctPos'],'out_struct');
SD_decoder_from_plx([BC_file '_correctPos.mat'],1,2,0); %2.5 for Chewie
load([HC_file '-binned_perfLDA_velDecoder_1stOrder.mat']);
general_decoder2 = general_decoder;
posture_decoder2 = posture_decoder;
movement_decoder2 = movement_decoder;
load([BC_file '_correctPos-binned_perfLDA_velDecoder_1stOrder.mat']);
general_decoder = general_decoder2;
posture_decoder = posture_decoder2;
movement_decoder = movement_decoder2;
save([HC_file '-binned_velDecoder_1stOrder.mat'],'-struct','general_decoder');
save([BC_file '_correctPos-binned_perfLDA_velDecoder_1stOrder.mat'],'general_decoder', 'movement_classifier', 'movement_decoder', 'posture_classifier', 'posture_decoder');

% out_struct.vel(:,2:3) = [0 0; diff(out_struct.pos(:,2:3))/0.001]; % this doesn't really work...
% out_struct.acc(:,2:3) = [0 0; diff(out_struct.vel(:,2:3))/0.001];