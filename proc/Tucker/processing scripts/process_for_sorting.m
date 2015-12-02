%% strip digital data from NEV
basepath='E:\local processing\Han\iso_RW_files_for_rummi';
basefilename='Han_20150204_RW_Tucker_001.nev';
nodigitalfilename='Han_20150204_RW_Tucker_001_nodigital.nev';
spikelessfilename='Han_20150204_RW_Tucker_001-nospikes.mat';

%open data
NEV = openNEV('read', [basepath, filesep, basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath filesep  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath filesep spikelessfilename]);

%% save append digital data back on and re-save
%should be unneccesary with new versions of cerebus2nevnsx

%basepath='E:\local_processing\chips\experiment_20150406_RW_sorting';
sortedfilename='Kramer_RW_03142013_tucker_001_nodigital-01.nev';
%spikelessfilename='Chips_20150331_RW_tucker_001_nospikes.mat';
processfilename='Kramer_RW_03142013_tucker_001-01';

oldnevdata=load([basepath filesep spikelessfilename]);
sortednev=openNEV([basepath filesep sortedfilename],'nosave','nomat','report');
NEV=oldnevdata.NEV_nospikes;
clear oldnevdata
NEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
save([basepath filesep processfilename '-s.mat'],'NEV')
saveNEV(NEV,[basepath filesep processfilename '.nev'],'report')