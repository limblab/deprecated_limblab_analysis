%% strip digital data from NEV
basepath='E:\local_processing\chips\experiment_20150513_BD_77degstim';
basefilename='Chips_20150513_BD_Tucker_4CHstim_77degPD_001.nev';
nodigitalfilename='Chips_20150421_RW_tucker_001-nodigital.nev';
spikelessfilename='Chips_20150421_RW_tucker_001-nospikes.mat';

%open data
NEV = openNEV('read', [basepath, filesep, basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath filesep  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath filesep spikelessfilename]);

%% save append digital data back on and re-save
%should be unneccesary with new versions of cerebus2nevnsx

basepath='E:\local_processing\chips\experiment_20150406_RW_sorting';
sortedfilename='Chips_20150331_RW_tucker_001_nodigital-01.nev';
spikelessfilename='Chips_20150331_RW_tucker_001_nospikes.mat';
processfilename='Chips_20150331_RW_tucker_001_-01';

oldnevdata=load([basepath filesep spikelessfilename]);
sortednev=openNEV([basepath filesep sortedfilename],'nosave','nomat','report');
NEV=oldnevdata.NEV_nospikes;
clear oldnevdata
NEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
save([basepath filesep processfilename '-s.mat'],'NEV')
saveNEV(NEV,[basepath filesep processfilename '.nev'],'report')