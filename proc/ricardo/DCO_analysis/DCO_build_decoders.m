% % function params = DCO_build_decoders(data_struct,params)
DCO = data_struct.DCO;
bdf = data_struct.bdf;
% 
units = reshape([bdf.units.id],2,[])';
if any(units(:,2))
    error('This script only works with unsorted files')
end

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
    max_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_final_hold,:)).^2));     
    min_force_target(iTarget) = sqrt(sum(mean(binnedData.forcedatabin(t_idx_ct_hold,:)).^2));     
end
% Subtract baseline
min_emg_target = min(min_emg_target);
binnedData.emgdatabin = binnedData.emgdatabin - repmat(min_emg_target,size(binnedData.emgdatabin,1),1);

% Normalize
flexors = ~cellfun(@isempty,strfind(binnedData.emgguide,'BRD')) | ~cellfun(@isempty,strfind(binnedData.emgguide,'BI'));
extensor = ~cellfun(@isempty,strfind(binnedData.emgguide,'TRI'));
average_emg_target = ones(1,length(binnedData.emgguide));
average_emg_target(flexors) = mean_emg_target(1,flexors);
average_emg_target(extensor) = mean_emg_target(end,extensor);
% mean_emg_target = max(mean_emg_target,[],1);
binnedData.emgdatabin = binnedData.emgdatabin./repmat(average_emg_target,size(binnedData.emgdatabin,1),1);

force_normalization_factor = ones(1,length(binnedData.emgguide));
force_normalization_factor(flexors) = max_force_target(1);
force_normalization_factor(extensor) = max_force_target(end);
binnedData.emgdatabin = binnedData.emgdatabin.*repmat(force_normalization_factor,size(binnedData.emgdatabin,1),1);
binnedData.emgdatabin(binnedData.emgdatabin<0) = 0;
%%
binnedData_all = binnedData;
binnedData_all.timeframe = 0;
binnedData_all.emgdatabin = zeros(1,size(binnedData.emgdatabin,2));
binnedData_all.spikeratedata = zeros(1,size(binnedData.spikeratedata,2));
binnedData_all.forcedatabin = zeros(1,size(binnedData.forcedatabin,2));
binnedData_reciprocal = binnedData;
binnedData_reciprocal.timeframe = 0;
binnedData_reciprocal.emgdatabin = zeros(1,size(binnedData.emgdatabin,2));
binnedData_reciprocal.spikeratedata = zeros(1,size(binnedData.spikeratedata,2));
binnedData_reciprocal.forcedatabin = zeros(1,size(binnedData.forcedatabin,2));

for iTrial = 1:size(DCO.trial_table,1)
    
    index = cellfun(@(x) x==iTrial, DCO.target_locations_idx, 'UniformOutput', 0);
    iTarget = find(cellfun(@sum,index));
    
    trial_t = DCO.trial_table(iTrial,[DCO.table_columns.t_trial_start DCO.table_columns.t_trial_end]);
    t_idx = find(binnedData.timeframe > trial_t(1) & binnedData.timeframe < trial_t(2));
    
    if iTarget == 1 || iTarget == 3
        binnedData_reciprocal.timeframe = [binnedData_reciprocal.timeframe ;...
            (binnedData_reciprocal.timeframe(end) + BDF2BinArgs.binsize +...
            [0:diff(binnedData.timeframe(1:2)):(length(t_idx)-1)*diff(binnedData.timeframe(1:2))])'];
        binnedData_reciprocal.emgdatabin = [binnedData_reciprocal.emgdatabin ; binnedData.emgdatabin(t_idx,:)];
        binnedData_reciprocal.spikeratedata = [binnedData_reciprocal.spikeratedata ; binnedData.spikeratedata(t_idx,:)];
        binnedData_reciprocal.forcedatabin = [binnedData_reciprocal.forcedatabin ; binnedData.forcedatabin(t_idx,:)];
        
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
new_length = size(binnedData_reciprocal.timeframe,1);
binnedData_all.timeframe = binnedData_all.timeframe(1:new_length);
binnedData_all.emgdatabin = binnedData_all.emgdatabin(1:new_length,:);
binnedData_all.spikeratedata = binnedData_all.spikeratedata(1:new_length,:);
binnedData_all.forcedatabin = binnedData_all.forcedatabin(1:new_length,:);

[filter_reciprocal, ~] = BuildModel(binnedData_reciprocal, DecoderOptions);
[R2_rec, vaf_rec, mse_rec] = mfxval(binnedData_reciprocal, DecoderOptions);

[filter_all, ~] = BuildModel(binnedData_all, DecoderOptions);
[R2_all, vaf_all, mse_all] = mfxval(binnedData_all, DecoderOptions);

%%
data_folder = params.target_folder(1:strfind(params.target_folder,'CerebusData')-1);
mkdir([data_folder 'SavedFilters'])
save([data_folder 'SavedFilters\' params.DCO_file_prefix '_filter_all'],'filter_all')
save([data_folder 'SavedFilters\' params.DCO_file_prefix '_filter_reciprocal'],'filter_reciprocal')


%%
% PredData = predictSignals(filter_reciprocal,binnedData_reciprocal);
% interp_pred_data = interp1(PredData.timeframe,PredData.preddatabin(:,3),binnedData_reciprocal.timeframe);
% interp_pred_data(isnan(interp_pred_data)) = 0;
% corrcoef(binnedData_reciprocal.emgdatabin(:,3),interp_pred_data)