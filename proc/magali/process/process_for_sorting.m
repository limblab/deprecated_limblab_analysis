%% strip digital data from NEV
basepath='Z:\Han_13B1\Processed\experiment_20150309_RW (sorting)';
basefilename='Han_20150309_RW_Magali_3B2_003.nev';
nodigitalfilename='Han_20150309_RW_Magali_3B2_003_nodigital.nev';
spikelessfilename='Han_20150309_RW_Magali_3B2_003_nospikes.mat';


%open data
NEV = openNEV('read', [basepath, '\', basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath '\'  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath '\' spikelessfilename]);


%% save append digital data back on and re-save
basepath='Z:\Han_13B1\Processed\experiment_20150309_RW_area2bankA2';
sortedfilename='Han_20150309_RW_Magali_2A2_001_nodigital.nev';
spikelessfilename='Han_20150309_RW_Magali_2A2_001_nospikes.mat';
processfilename='Han_20150309_RW_Magali_2A2_001-s.nev';

oldnevdata=load([basepath '\' spikelessfilename]);
sortednev=openNEV([basepath '\' sortedfilename],'nosave','nomat','report');
newNEV=oldnevdata.NEV;
clear oldnevdata
newNEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
%save([basepath '\' processfilename],'newNEV')
saveNEV(newNEV,processfilename,'report')