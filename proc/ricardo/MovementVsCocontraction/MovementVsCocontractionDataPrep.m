filePrefix = 'Chewie_2015-04-08_DCO_emg_hu';
fileNumber = '001';
dataPath = ['D:\Chewie_8I2\' filePrefix];

CB_FileName = [filePrefix '_' fileNumber '.nev'];

BMI_FileName = strrep(CB_FileName,'.nev','_data.txt');
BMI_params_FileName = strrep(CB_FileName,'.nev','_params.mat');
CB_FullFileName = fullfile([dataPath filesep 'CerebusData'], CB_FileName);
BMI_FullFileName = fullfile([dataPath filesep 'CerebusData'], BMI_FileName);
BMI_params_FullFileName = fullfile([dataPath filesep 'CerebusData'], BMI_params_FileName);

mkdir([dataPath filesep 'BDFStructs'])
mkdir([dataPath filesep 'BinnedData'])
mkdir([dataPath filesep 'NeuronIDfiles'])
mkdir([dataPath filesep 'OLPreds'])
mkdir([dataPath filesep 'RTPreds'])
mkdir([dataPath filesep 'SavedFilters'])

BDF_FileName =  strrep(CB_FileName,'.nev','.mat');
BDF_opts.rothandle = 1;
BDF_opts.labnum = 3;

BDF2BinArgs.binsize = 0.05;
BDF2BinArgs.starttime = 1;
BDF2BinArgs.stoptime = 0;
BDF2BinArgs.EMG_hp = 50;
BDF2BinArgs.EMG_lp = 10;
BDF2BinArgs.minFiringRate = 1;
BDF2BinArgs.NormData = 1;
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

disp('Creating bdf structure')
bdf = get_nev_mat_data(CB_FullFileName,'rothandle',BDF_opts.rothandle,BDF_opts.labnum);
save([dataPath filesep 'BDFStructs' filesep BDF_FileName],'bdf');
if BDF2BinArgs.ArtRemEnable
    disp('Looking for Artifacts...');
    bdf = artifact_removal(bdf,BDF2BinArgs.NumChan,BDF2BinArgs.TimeWind, 1);
end

disp('Converting BDF structure to binned data...');
binnedData = convertBDF2binned(bdf,BDF2BinArgs);
[end_idx,~] = find(binnedData.emgdatabin>20*max(std(binnedData.emgdatabin)),1,'first');
if ~isempty(end_idx)
    BDF2BinArgs.stoptime = floor(binnedData.timeframe(end_idx)-1);
    disp(['Removing last ' num2str(binnedData.timeframe(end) - floor(binnedData.timeframe(end_idx)-1))...
        ' seconds because of noise in the EMG recordings.'])    
    binnedData = convertBDF2binned(bdf,BDF2BinArgs);
end
disp('Done.');

disp('Integrating BMI data into binnedData structure')
BMI_params = load(BMI_params_FullFileName);
BMI_data = load(BMI_FullFileName);
BMI_data = BMI_data(find(diff(BMI_data(:,1))<0,1,'last')+1:end,:);
BMI_data(diff(BMI_data(:,1))==0,:) = [];
BMI_data = interp1(BMI_data(:,1),BMI_data,binnedData.timeframe);
binnedData.bmi = BMI_data;
binnedData.bmi_headers = BMI_params.headers;

disp('Saving binned data...');
Bin_FileName = BDF_FileName;
save([dataPath filesep 'BinnedData' filesep BDF_FileName],'binnedData');
disp('Done.');


binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
[filter, OLPredData] = BuildModel(binnedData, DecoderOptions);
disp('Saving prediction model...');
Filt_FileName = [Bin_FileName(1:end-4) '_Decoder.mat'];
filter.FromData = Bin_FileName;
save([dataPath filesep 'SavedFilters' filesep Filt_FileName],'filter');

disp('Saving Offline  Predictions...');
OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];
save([dataPath filesep 'OLPreds' filesep OLPred_FileName],'OLPredData');

disp(sprintf('Proceeding to multifold cross-validation using %g sec folds...', DecoderOptions.foldlength));
[mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxval(binnedData, DecoderOptions);
disp('Done.');
disp('Saving Offline Predictions...');
OLPred_FileName = [sprintf('OLPred_mfxval_%s', Bin_FileName(1:end-4)) '.mat'];
save([dataPath filesep 'OLPreds' filesep OLPred_FileName],'OLPredData');
disp('Done.');

figure; 
subplot(211)
plot(binnedData.timeframe,binnedData.emgdatabin(:,2),OLPredData.timeframe,OLPredData.preddatabin(:,2))
title(deblank(binnedData.emgguide(2,:)))
subplot(212)
plot(binnedData.timeframe,binnedData.emgdatabin(:,3),OLPredData.timeframe,OLPredData.preddatabin(:,3))
title(deblank(binnedData.emgguide(3,:)))
legend('Real data','Predicted')

mean(mfxval_vaf)