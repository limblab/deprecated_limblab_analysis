function params = RP_build_decoders(data_struct,params)
RP = data_struct.RP;
bdf = data_struct.bdf;

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

binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
[filter, OLPredData] = BuildModel(binnedData, DecoderOptions);
disp('Saving prediction model...');
Filt_FileName = [Bin_FileName(1:end-4) '_Decoder.mat'];
filter.FromData = Bin_FileName;

OLPred_FileName = [sprintf('OLPred_DATA-%s_Filter-%s', Bin_FileName(1:end-4),Filt_FileName(1:end-4)) '.mat'];

disp(sprintf('Proceeding to multifold cross-validation using %g sec folds...', DecoderOptions.foldlength));
[mfxval_R2, mfxval_vaf, mfxval_mse, OLPredData] = mfxval(binnedData, DecoderOptions);
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