%% strip digital data from NEV
basepath='F:\local processing\chips\experiment_20160526_CObump_PD';
basename='Chips_20160526_COBump_area2_tucker_001';
basefilename=[basename,'.nev'];
nodigitalfilename=[basename,'_nodigital.nev'];
spikelessfilename=[basename,'_nospikes.mat'];

%open data
NEV = openNEV('read', [basepath, filesep, basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath filesep  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath filesep spikelessfilename]);

%% save append digital data back on and re-save
%should be unneccesary with new versions of cerebus2nevnsx

%basepath='E:\local_processing\chips\experiment_20150406_RW_sorting';
sortedfilename=[basename,'_nodigital-01.nev'];
spikelessfilename=[basename,'_nospikes.mat'];
processfilename=[basename,'-s.nev'];

oldnevdata=load([basepath filesep spikelessfilename]);
sortednev=openNEV([basepath filesep sortedfilename],'nosave','nomat','report');
NEV=oldnevdata.NEV_nospikes;
clear oldnevdata
NEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
save([basepath filesep processfilename '-s.mat'],'NEV')
saveNEV(NEV,[basepath filesep processfilename ],'report')