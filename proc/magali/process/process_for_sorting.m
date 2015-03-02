%% strip digital data from NEV
basepath='C:\Users\limblab\Desktop\S1_analysis\proc\magali\data';
basefilename='Chips_20150227_RW_tucker_002.nev';
nodigitalfilename='Chips_20150227_RW_tucker_002_nodigital.nev';
spikelessfilename='Chips_20150227_RW_tucker_002_nospikes.mat';


%open data
NEV = openNEV('read', [basepath, '\', basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath '\'  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath '\' spikelessfilename]);


%% save append digital data back on and re-save
basepath='C:\Users\limblab\Desktop\S1_analysis\proc\magali\data';
sortedfilename='Chips_20150227_RW_tucker_007_nodigital-01.nev';
spikelessfilename='Chips_20150227_RW_tucker_002_nospikes.mat';
processfilename='Chips_20150227_RW_tucker_002-s.nev';

oldnevdata=load([basepath '\' spikelessfilename]);
sortednev=openNEV([basepath '\' sortedfilename],'nosave','nomat','report');
newNEV=oldnevdata.NEV;
clear oldnevdata
newNEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
%save([basepath '\' processfilename],'newNEV')
saveNEV(newNEV,processfilename,'report')