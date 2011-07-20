function filter = MRSeric_spike_decoder( filein, fileout, offsetx, offsety ) 


% load_paths;

disp('Loading File');
%bdf = get_plexon_data(filein);
out_struct = filein;
disp('Done Loading File');

%out_struct.pos(:,2) = out_struct.pos(:,2) - offsetx;
%out_struct.pos(:,3) = out_struct.pos(:,3) - offsety;

save temp out_struct;
clear out_struct;
%load_paths;

%%
[binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData] = convertBDF2binnedGUI;

disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned('temp.mat',binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData);

disp('Building Prediction Model, please wait...');
%binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
[fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh] = BuildModelGUI(binsize,[]);
[filter, OLPredData] = BuildModel(binnedData, 'C:\Documents and Settings\limblab\Desktop\s1_analysis', fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh);
clear binnedData;
disp('Done.');

filter.P = filter.P'

H = filter.H;
P = filter.P;
binsize = filter.binsize;
fillen = filter.fillen;
neuronIDs = filter.neuronIDs;


%calculate R2
datlen=length(OLPredData);

save(fileout, 'H', 'P', 'binsize', 'fillen', 'neuronIDs');
