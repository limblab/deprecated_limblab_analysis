clear
% HC_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013001';
% BC_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013002';
% log_file = '\\165.124.111.182\data\Mini_7H1\Nick Datafiles\onlineSD\6-10-2013\Mini_Spikes_06102013001-binned_perfLDA_velDecoder_1stOrder_log';
% HC_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013001';
% BC_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013002';
% log_file = '\\165.124.111.182\data\Chewie_8I2\Nick Datafiles\onlineSD\6-10-2013\Chewie_Spikes_06102013001-binned_perfLDA_velDecoder_1stOrder_log';

% HC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-05-27\Chewie_Spike_RW_05272014001';
% % HC_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\Chewie_Spikess_06102013001';
% BC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-05-27\Chewie_Spike_RW_05272014002';
% log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-05-27\Chewie_Spike_RW_05272014002-binned_perfLDA_velDecoder_1stOrder_log';
% % log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-04-17\Chewie_Spike_RW_04172014002_correctPos-binned_perfLDA_velDecoder_1stOrder_log';

HC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-06\Chewie_Spike_RW_06032014001';
% HC_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\Chewie_Spikess_06102013001';
BC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-06\Chewie_Spike_RW_06062014001';
log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-06\Chewie_Spike_RW_06062014001_correctPos-binned_perfLDA_velDecoder_1stOrder_log';
% log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-04-17\Chewie_Spike_RW_04172014002_correctPos-binned_perfLDA_velDecoder_1stOrder_log';

if ~exist([BC_file '.plx'],'file')
    disp('Building first decoder')
    SD_decoder_from_plx([HC_file '.plx'],0,5,0); 
else
    disp('Building LDA classifier')
    out_struct = get_plexon_data([BC_file '.plx'],'verbose');
    save('BC_file','out_struct');
    % uiopen([log_file '.txt'],1);

    % Remove all data before 'startup' and save in new file
    FID = fopen([log_file '.txt'], 'r');
    str = fread(FID, [1, inf], '*char');
    fclose(FID);
    FID_new = fopen([log_file '_correctPos.txt'],'w');
    fwrite(FID_new,str(strfind(str,'startup')+7:end));
    fclose(FID_new);

    % Find magnet radius in log file.
    temp = str(strfind(str,'magnet_radius'):end);
    magnet_radius = str2double(temp(length('magnet_radius')+1:find(temp==10,1,'first')-1));
    clear str temp FID FID_new

    trial_log = load([log_file '_correctPos.txt']);
    trial_log(:,10) = (trial_log(:,10)-trial_log(1,10))/10^9;
    trial_log = trial_log(find(trial_log(:,10)>=out_struct.pos(1,1),1,'first'):...
        find(trial_log(:,10)<=out_struct.pos(end,1),1,'last'),:);
    dt = diff(out_struct.pos(1:2,1));
    out_struct.pos(1:100,2:3) = repmat(trial_log(1,5:6),100,1);
    for i = 1:size(trial_log,1)-1
        idx = round(1+1/dt*[trial_log(i,10) trial_log(i+1,10)])-1000;
        idx = idx(1):idx(2)-1;
        out_struct.pos(idx,2:3) = repmat(trial_log(i,5:6),length(idx),1);
    end
    out_struct.pos(idx(end):end,2:3) = repmat(trial_log(i,5:6),size(out_struct.pos(idx(end):end,2:3),1),1);

    % for x = 1:length(out_struct.pos)
    %     out_struct.pos(x,2:3) = trial_log(find((trial_log(:,10)-trial_log(1,10))/10^9 > out_struct.pos(x,1),1,'first'),(5:6));
    % end
    save([BC_file '_correctPos'],'out_struct');
    SD_decoder_from_plx([BC_file '_correctPos.mat'],1,magnet_radius,0); 
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
end