%% strip digital data from NEV
basepath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150227_RW_sorting';
basefilename='Chips_20150227_RW_tucker_001.nev';
nodigitalfilename='Chips_20150227_RW_tucker_001_nodigital.nev';
spikelessfilename='Chips_20150227_RW_tucker_001_nospikes.mat';


%open data
NEV = openNEV('read', [basepath, '\', basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath '\'  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath '\' spikelessfilename]);


%% save append digital data back on and re-save
basepath='C:\Users\limblab\Documents\local_processing\chips\experiemnt_20150226_RW_sorting';
sortedfilename='Chips_20150226_RW_tucker_001_nodigital-01.nev';
spikelessfilename='Chips_20150226_RW_tucker_001_nospikes.mat';
processfilename='Chips_20150226_RW_tucker_001-s.nev';

oldnevdata=load([basepath '\' spikelessfilename]);
sortednev=openNEV([basepath '\' sortedfilename],'nosave','nomat','report');
newNEV=oldnevdata.NEV;
clear oldnevdata
newNEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
%save([basepath '\' processfilename],'newNEV')
saveNEV(newNEV,processfilename,'report')