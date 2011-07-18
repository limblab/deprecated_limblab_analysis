function filter = buildSpikePositionDecoder(BDFfileIn)

if ischar(BDFfileIn)
    bdf=load(BDFfileIn);
    bdf=bdf.bdf;
else
    bdf=BDFfileIn;
end

bdf.pos(:,2) = bdf.pos(:,2) - offsetx;
bdf.pos(:,3) = bdf.pos(:,3) - offsety;

[binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData] = convertBDF2binnedGUI;

disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned('temp.mat',binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData);

disp('Building Prediction Model, please wait...');
%binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
[fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh] = BuildModelGUI(binsize);
[filter, OLPredData] = BuildModel(binnedData, 'C:\Documents and Settings\limblab\Desktop\s1_analysis', fillen, 1, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh);
clear binnedData;
disp('Done.');

filter.P = filter.P'

H = filter.H;
P = filter.P;
binsize = filter.binsize;
fillen = filter.fillen;
neuronIDs = filter.neuronIDs;

datlen=length(OLPredData);

save(fileout, 'H', 'P', 'binsize', 'fillen', 'neuronIDs');
