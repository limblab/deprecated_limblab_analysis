function params = RP_build_decoders_old(data_struct,params)
RP = data_struct.RP;

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

neural_channels = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'chan')));
neural_labels = RP.BMI.params.headers(neural_channels);
num_char = max(cellfun(@length,neural_labels));
spikeguide = repmat('ee000u0',length(neural_labels),1);
for i=1:length(neural_labels)
    elec_num = num2str(neural_labels{i}(6:strfind(neural_labels{i},'-')-1));
    if length(elec_num)==1
        spikeguide(i,5) = elec_num;
    else
        spikeguide(i,4:5) = elec_num;
    end
    unit_num = num2str(neural_labels{i}(end));
    spikeguide(i,end) = unit_num;
end
emgguide = repmat(' ',length(emg_labels),12);
for i=1:size(emg_guide,1)
    emgguide(i,1:length(emg_labels{i}(strfind(emg_labels{i},'_')+1:end))) = emg_labels{i}(strfind(emg_labels{i},'_')+1:end);
end

if RP.BMI.params.arm_params.use_brd
    flexor = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'EMG_BRD')));
else
    flexor = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'EMG_BI')));
end
extensor = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'EMG_TRI')));

emg_channels = [flexor extensor];
emg_labels = RP.BMI.params.headers(emg_channels);

binnedData.emgdatabin = RP.BMI.data(RP.pert_idx_table_bmi(:),emg_channels);
binnedData.spikeratedata = RP.BMI.data(RP.pert_idx_table_bmi(:),neural_channels);
dt = diff(RP.BMI.data(1:2,strcmp(RP.BMI.params.headers,'t_bin_start')));
binnedData.timeframe = [0:dt:numel(RP.pert_idx_table_bmi)*dt-dt]';
binnedData.spikeguide = spikeguide;
binnedData.neuronIDs = [(1:length(neural_labels))' zeros(size(spikeguide,1),1)];
binnedData.emgguide = emgguide;

[filter, OLPredData] = BuildModel(binnedData, DecoderOptions);
[mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxval(binnedData, DecoderOptions);

figure; 
subplot(211)
plot(binnedData.timeframe,binnedData.emgdatabin(:,1),OLPredData.timeframe,OLPredData.preddatabin(:,1))
title(deblank(binnedData.emgguide(1,:)))
subplot(212)
plot(binnedData.timeframe,binnedData.emgdatabin(:,2),OLPredData.timeframe,OLPredData.preddatabin(:,2))
title(deblank(binnedData.emgguide(2,:)))
legend('Real data','Predicted')
