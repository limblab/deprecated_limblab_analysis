function filter = marc_spike_decoder( filein, fileout, offsetx, offsety ) 


% load_paths;

disp('Loading File');
bdf = get_plexon_data([filein,'.plx']);
disp('Done Loading File');

bdf.pos(:,2) = bdf.pos(:,2) - offsetx;
bdf.pos(:,3) = bdf.pos(:,3) - offsety;

endtime=bdf.pos(end,1);
save([filein,'.mat'],'bdf')
clear bdf;
% load_paths;

%%
[binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData] = convertBDF2binnedGUI;

disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned([filein,'.mat'],binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData);

disp('Building Prediction Model, please wait...');
%binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
[fillen, UseAllInputsOption, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh] = BuildModelGUI(binsize);
[filter, OLPredData] = BuildModel(binnedData, 'C:\Documents and Settings\limblab\Desktop\s1_analysis', fillen, 1, PolynomialOrder, Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh);
clear binnedData;
disp('Done.');

filter.P = filter.P';

H = filter.H;
P = filter.P;
binsize = filter.binsize;
fillen = filter.fillen;
neuronIDs = filter.neuronIDs;


%calculate R2 for rest of file if we have at least 10s of data that was not
%used to build the filter
if stoptime<(endtime-10)
    bindatnew = convertBDF2binned([filein,'.mat'],binsize,stoptime+1,endtime,hpfreq,lpfreq,MinFiringRate,NormData);
[pd,xtnew,ytnew]=predMIMO3(bindatnew.spikeratedata,H,1,1,bindatnew.cursorposbin);   %Chris's version of BuildModel uses fs=1, which is not quite accurate
r1=corrcoef(pd(:,1),ytnew(:,1));
rsq1=r1(1,2)^2;
r2=corrcoef(pd(:,2),ytnew(:,2));
rsq2=r2(1,2)^2;
end

save([fileout,'.mat'], 'H', 'P', 'binsize', 'fillen', 'neuronIDs');

