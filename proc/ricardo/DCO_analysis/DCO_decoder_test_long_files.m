% function params = DCO_build_decoders(data_struct,params)

DCO = data_struct.DCO;
bdf = data_struct.bdf;
% 
units = reshape([bdf.units.id],2,[])';

BDF2BinArgs.binsize = 0.05;
BDF2BinArgs.starttime = 1;
BDF2BinArgs.stoptime = 0;
BDF2BinArgs.EMG_hp = 50;
BDF2BinArgs.EMG_lp = 10;
BDF2BinArgs.minFiringRate = 1;
BDF2BinArgs.NormData = 0;
BDF2BinArgs.FindStates = 0;
BDF2BinArgs.Unsorted = 1;
BDF2BinArgs.TriKernel = 0;
BDF2BinArgs.sig = 0.04;
BDF2BinArgs.ArtRemEnable = 1;
BDF2BinArgs.NumChan = 10;
BDF2BinArgs.TimeWind = .0005;

DecoderOptions.PredEMGs = 1;
DecoderOptions.PredForce = 0;
DecoderOptions.PredCursPos = 0;
DecoderOptions.PredVeloc = 0;
DecoderOptions.fillen = 0.5000;
DecoderOptions.UseAllInputs = 1;
DecoderOptions.PolynomialOrder = 2;
DecoderOptions.numPCs = 0;
DecoderOptions.Use_Thresh = 0;
DecoderOptions.Use_EMGs = 0;
DecoderOptions.Use_Ridge = 0;
DecoderOptions.Use_SD = 0;
DecoderOptions.foldlength = 60;
% 
disp('Converting BDF structure to binned data...');
binnedData = convertBDF2binned(bdf,BDF2BinArgs);

%% Normalizing EMG
for iTarget = 1:length(DCO.target_locations)    
    trial_idx = DCO.target_locations_idx{iTarget};
    trial_t_ct_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ct_hold_on DCO.table_columns.t_go_cue]);
    
    trial_t_final_hold = DCO.trial_table(trial_idx,[DCO.table_columns.t_ot_last_hold DCO.table_columns.t_trial_end]);
    t_idx_ct_hold = [];
    t_idx_final_hold = [];
    t_idx_all = [];
    for iTrial = 1:size(trial_t_final_hold,1)
        t_idx_ct_hold = [t_idx_ct_hold; find(binnedData.timeframe > trial_t_ct_hold(iTrial,1) & binnedData.timeframe < trial_t_ct_hold(iTrial,2))];
        t_idx_final_hold = [t_idx_final_hold; find(binnedData.timeframe > trial_t_final_hold(iTrial,1) & binnedData.timeframe < trial_t_final_hold(iTrial,2))];
        t_idx_all = [t_idx_all; find(binnedData.timeframe > trial_t_ct_hold(iTrial,1) & binnedData.timeframe < trial_t_final_hold(iTrial,2))];
    end
    min_emg_target(iTarget,:) = mean(binnedData.emgdatabin(t_idx_ct_hold,:));
    mean_emg_target(iTarget,:) = mean(binnedData.emgdatabin(t_idx_final_hold,:));  
%     max_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_final_hold,:)).^2));     
%     min_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_ct_hold,:)).^2));
    temp_force = mean(binnedData.forcedatabin(t_idx_final_hold,:)) - mean(binnedData.forcedatabin(t_idx_ct_hold,:));
    temp_force = sqrt(sum(temp_force.^2));
    max_force_target(iTarget) = temp_force;
%     max_force_target(iTarget) = mean(sqrt(sum(binnedData.forcedatabin(t_idx_final_hold,:).^2,2)));
    min_force_target(iTarget) = mean(sqrt(sum(binnedData.forcedatabin(t_idx_ct_hold,:).^2,2)));
    mean_rest_force(iTarget,:) = mean(binnedData.forcedatabin(t_idx_ct_hold,:));
    std_rest_force(iTarget,:) = std(binnedData.forcedatabin(t_idx_ct_hold,:));  
    mean_hold_force(iTarget,:) = mean(binnedData.forcedatabin(t_idx_final_hold,:));
    std_hold_force(iTarget,:) = std(binnedData.forcedatabin(t_idx_final_hold,:)); 
end
% Subtract baseline
min_emg_target = min(min_emg_target);
binnedData.emgdatabin = binnedData.emgdatabin - repmat(min_emg_target,size(binnedData.emgdatabin,1),1);

% Normalize
flexors = ~cellfun(@isempty,strfind(binnedData.emgguide,'BRD')) | ~cellfun(@isempty,strfind(binnedData.emgguide,'BI'));
extensor = ~cellfun(@isempty,strfind(binnedData.emgguide,'TRI'));
average_emg_target = ones(1,length(binnedData.emgguide));
average_emg_target(flexors) = max(mean_emg_target(:,flexors));
average_emg_target(extensor) = max(mean_emg_target(:,extensor));
% mean_emg_target = max(mean_emg_target,[],1);
binnedData.emgdatabin = binnedData.emgdatabin./repmat(average_emg_target,size(binnedData.emgdatabin,1),1);

% if any(min_force_target > max_force_target)
%     warning('Monkey probably wasn''t holding handle')
% else
    force_normalization_factor = ones(1,length(binnedData.emgguide));
    if strfind(bdf.meta.filename,'Jaco') % Right handed
        force_normalization_factor(flexors) = max_force_target(end);
        force_normalization_factor(extensor) = max_force_target(1);
    else
        force_normalization_factor(flexors) = max_force_target(1);
        force_normalization_factor(extensor) = max_force_target(end);
    end
%     binnedData.emgdatabin = binnedData.emgdatabin.*repmat(force_normalization_factor,size(binnedData.emgdatabin,1),1);
% end
binnedData.emgdatabin(binnedData.emgdatabin<0) = 0;
%%
binnedData_all = binnedData;
binnedData_all.timeframe = 0;
binnedData_all.emgdatabin = zeros(1,size(binnedData.emgdatabin,2));
binnedData_all.spikeratedata = zeros(1,size(binnedData.spikeratedata,2));
binnedData_all.forcedatabin = zeros(1,size(binnedData.forcedatabin,2));

for iTrial = 1:size(DCO.trial_table,1)
    
    index = cellfun(@(x) x==iTrial, DCO.target_locations_idx, 'UniformOutput', 0);
    iTarget = find(cellfun(@sum,index));
    
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_trial_start DCO.table_columns.t_trial_end]);
    t_idx = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
    
    if iTarget == 1 || iTarget == 3
        binnedData_all.timeframe = [binnedData_all.timeframe ;...
            (binnedData_all.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];
        binnedData_all.emgdatabin = [binnedData_all.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_all.spikeratedata = [binnedData_all.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_all.forcedatabin = [binnedData_all.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
    elseif iTarget == 2
        binnedData_all.timeframe = [binnedData_all.timeframe;...
            (binnedData_all.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];       
        binnedData_all.emgdatabin = [binnedData_all.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_all.spikeratedata = [binnedData_all.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_all.forcedatabin = [binnedData_all.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
    end
end

%%
binnedData_fixed = binnedData_all;
last_idx = find(binnedData_fixed.timeframe <= 600,1,'last');
binnedData_fixed.timeframe = binnedData_fixed.timeframe(1:last_idx);
binnedData_fixed.emgdatabin = binnedData_fixed.emgdatabin(1:last_idx,:);
binnedData_fixed.spikeratedata = binnedData_fixed.spikeratedata(1:last_idx,:);
binnedData_fixed.spikeratedata = [binnedData_fixed.spikeratedata binnedData_fixed.spikeratedata+rand(size(binnedData_fixed.spikeratedata))*10+5];
binnedData_fixed.spikeratedata = [binnedData_fixed.spikeratedata binnedData_fixed.spikeratedata(:,1:4)+rand(size(binnedData_fixed.spikeratedata,1),4)*10+5];
binnedData_fixed.neuronIDs = repmat(binnedData_fixed.neuronIDs,2,1);
binnedData_fixed.neuronIDs = [binnedData_fixed.neuronIDs; binnedData_fixed.neuronIDs(1:4,:)];
binnedData_fixed = rmfield(binnedData_fixed,'velocbin');
binnedData_fixed = rmfield(binnedData_fixed,'veloclabels');
binnedData_fixed = rmfield(binnedData_fixed,'cursorposbin');
binnedData_fixed = rmfield(binnedData_fixed,'cursorposlabels');
binnedData_fixed = rmfield(binnedData_fixed,'accelbin');
binnedData_fixed = rmfield(binnedData_fixed,'acclabels');
binnedData_fixed = rmfield(binnedData_fixed,'forcedatabin');
binnedData_fixed = rmfield(binnedData_fixed,'forcelabels');

binnedData_fixed.emgdatabin = repmat(binnedData_fixed.emgdatabin,1,4);
for i = 1:3
    binnedData_fixed.emgguide(i*4+[1:4]) = binnedData_fixed.emgguide(1:4);
end

filter_computation_time = [];
num_repeats = [2:8:50];
for i = num_repeats
    binnedData_temp = binnedData_fixed;
    binnedData_temp.spikeratedata = repmat(binnedData_fixed.spikeratedata,i,1);
    binnedData_temp.emgdatabin = repmat(binnedData_fixed.emgdatabin,i,1);
    binnedData_temp.timeframe = repmat(binnedData_fixed.timeframe,i,1);
    tic
    [filter_all, ~] = BuildModel(binnedData_temp, DecoderOptions);
    filter_computation_time(i) = toc;
    disp([num2str(i*10) ' minute file took ' num2str(filter_computation_time(i))... 
        ' seconds to compute'])
end

figure; 
plot(num_repeats*10,filter_computation_time(num_repeats))
xlabel('File length (minutes)')
ylabel('t (s)')
title({'Wiener filter computation time as a function of file length';...
    '16 emg channels, 96 spike channels'})

% [R2_all, vaf_all, mse_all] = mfxval(binnedData_fixed, DecoderOptions);

