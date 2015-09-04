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

HC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-23\Chewie_Spike_RW_06202014001';
HC_file  = '\\citadel\data\Chewie_8I2\Ricardo\2014-06-20\Chewie_Spike_RW_06202014001';
% HC_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\Chewie_Spikess_06102013001';
BC_file  = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-23\Chewie_Spike_RW_06202014002';
log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-06-23\Chewie_Spike_RW_06202014002-binned_perfLDA_velDecoder_1stOrder_log';
% log_file = '\\165.124.111.182\data\Chewie_8I2\Ricardo\2014-04-17\Chewie_Spike_RW_04172014002_correctPos-binned_perfLDA_velDecoder_1stOrder_log';

if ~exist([BC_file '.plx'],'file')
    disp('Building first decoder')
    SD_decoder_from_plx([HC_file '.plx'],0,7,0); 
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
    out_struct.vel(1:100,2:3) = repmat(trial_log(1,7:8),100,1);
    for i = 1:size(trial_log,1)-1
        idx = round(1+1/dt*[trial_log(i,10) trial_log(i+1,10)])-1000;
        idx = idx(1):idx(2)-1;
        out_struct.pos(idx,2:3) = repmat(trial_log(i,5:6),length(idx),1);
        out_struct.vel(idx,2:3) = repmat(trial_log(i,7:8),length(idx),1);
    end
    out_struct.pos(idx(end):end,2:3) = repmat(trial_log(i,5:6),size(out_struct.pos(idx(end):end,2:3),1),1);
    out_struct.vel(idx(end):end,2:3) = repmat(trial_log(i,7:8),size(out_struct.vel(idx(end):end,2:3),1),1);

    % for x = 1:length(out_struct.pos)
    %     out_struct.pos(x,2:3) = trial_log(find((trial_log(:,10)-trial_log(1,10))/10^9 > out_struct.pos(x,1),1,'first'),(5:6));
    % end
    save([BC_file '_correctPos'],'out_struct');
    SD_decoder_from_plx([BC_file '_correctPos.mat'],0,7,0); 

%     SD_decoder_from_plx([BC_file '_correctPos.mat'],1,magnet_radius,0); 
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

%%
% load('\\citadel\data\Chewie_8I2\Ricardo\2014-06-20\Chewie_Spike_RW_06202014001-binned_class.mat')
% options.dataPath = '\\citadel\data\Chewie_8I2\Ricardo\2014-06-20\';

load('\\citadel\data\Mini_7H1\Nick Datafiles\onlineSD\6-3-2013\Mini_Spike_06032013001-binned_class.mat')
options.dataPath = '\\citadel\data\Mini_7H1\Nick Datafiles\onlineSD\6-3-2013\';

% load('\\citadel\data\Mini_7H1\Nick Datafiles\onlineSD\05-20-2013\Mini_Spike_05202013001-binned_class.mat');
% options.dataPath = '\\citadel\data\Mini_7H1\Nick Datafiles\onlineSD\05-20-2013';

options.foldlength = 60;
options.fillen = 0.5;
options.UseAllInputsOption = 1;
options.PolynomialOrder = 1;
options.PredVeloc = 1;
options.PredEMG = 0;
options.PredForce = 0;
options.PredCursPos = 0;
options.Use_SD = 0;
options.plotflag = 0;
options.EMGcascade = 0;

% Crossvalidation
[R2, vaf, mse] = mfxval(binnedData, options);
disp('Full decoder')
mean(vaf)
%
options.fillen = 0.05;
singleLagSpikes = DuplicateAndShift(binnedData.spikeratedata,10);
speed = sqrt(binnedData.velocbin(:,1).^2+binnedData.velocbin(:,2).^2);
% movement = speed > 7;
movement = binnedData.states(:,2);
movementBinnedData = binnedData;
movementBinnedData.timeframe = (1+(0:sum(movement)-1)*options.fillen)';
movementBinnedData.spikeratedata = singleLagSpikes(movement,:);
movementBinnedData.velocbin = binnedData.velocbin(movement,:);
if isfield(movementBinnedData,'spikeguide')
    movementBinnedData.spikeguide = [];
    for i=1:size(binnedData.spikeguide,1)
        movementBinnedData.spikeguide(end+1:end+10,:) = repmat(binnedData.spikeguide(i,:),10,1);
        movementBinnedData.spikeguide(end-9:end,end) = num2str([0:9]');
    end
    movementBinnedData.spikeguide = char(movementBinnedData.spikeguide);
else
    movementBinnedData.neuronIDs = [];
    for i=1:size(binnedData.neuronIDs,1)
        movementBinnedData.neuronIDs(end+1:end+10,1) = repmat(binnedData.neuronIDs(i,1),10,1);
        movementBinnedData.neuronIDs(end-9:end,2) = ([0:9]');
    end
end
[R2_mov, vaf_mov, mse_mov, predMovementData] = mfxval(movementBinnedData, options);

disp('Movement decoder')
mean(vaf_mov)

% Posture decoder
options.fillen = 0.05;
singleLagSpikes = DuplicateAndShift(binnedData.spikeratedata,10);
posture = ~movement;
postureBinnedData = binnedData;
postureBinnedData.timeframe = (1+(0:sum(posture)-1)*options.fillen)';
postureBinnedData.spikeratedata = singleLagSpikes(posture,:);
postureBinnedData.velocbin = binnedData.velocbin(posture,:);
if isfield(postureBinnedData,'spikeguide')
    postureBinnedData.spikeguide = [];
    for i=1:size(binnedData.spikeguide,1)
        postureBinnedData.spikeguide(end+1:end+10,:) = repmat(binnedData.spikeguide(i,:),10,1);
        postureBinnedData.spikeguide(end-9:end,end) = num2str([0:9]');
    end
    postureBinnedData.spikeguide = char(postureBinnedData.spikeguide);
else
    postureBinnedData.neuronIDs = [];
    for i=1:size(binnedData.neuronIDs,1)
        postureBinnedData.neuronIDs(end+1:end+10,1) = repmat(binnedData.neuronIDs(i,1),10,1);
        postureBinnedData.neuronIDs(end-9:end,2) = ([0:9]');
    end
end
[R2_pos, vaf_pos, mse_pos, predPostureData] = mfxval(postureBinnedData, options);

disp('Posture decoder')
mean(vaf_pos)

%
temp = postureBinnedData.velocbin(1:size(predPostureData.preddatabin,1),:);
temp2 = movementBinnedData.velocbin(1:size(predMovementData.preddatabin,1),:);
originalData = [temp; temp2];
predictedData = [predPostureData.preddatabin ; predMovementData.preddatabin];
num_folds = 10;
fold_length = floor(size(predictedData,1)*.05/num_folds);
clear R2 vaf
for iFold = 1:num_folds
    idx = (iFold-1)*fold_length/.05+1:(iFold)*fold_length/.05;
    R2(iFold,:) = CalculateR2(predictedData(idx,:),originalData(idx,:));
    vaf(iFold,:)  = 1 - sum( (predictedData(idx,:)-originalData(idx,:)).^2 ) ./ ...
            sum( (originalData(idx,:) - ...
            repmat(mean(originalData(idx,:)),...
            size(originalData(idx,:),1),1)).^2 );  
end
mean(R2)
mean(vaf)