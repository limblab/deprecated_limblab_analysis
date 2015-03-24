%% strip digital data from NEV
basepath='Z:\Han_13B1\Processed\experiment_20150320_RW';
basefilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002.nev';
nodigitalfilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002_nodigital.nev';
spikelessfilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002_nospikes.mat';


%open data
NEV = openNEV('read', [basepath, '\', basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath '\'  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath '\' spikelessfilename]);


%% save append digital data back on and re-save
basepath='Z:\Han_13B1\Processed\experiment_20150320_RW';
sortedfilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002_nodigital.nev';
spikelessfilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002_nospikes.mat';
processfilename='Han_20150320_RW_Magali_area2_A2_after_stim_session_002-s.nev';

oldnevdata=load([basepath '\' spikelessfilename]);
sortednev=openNEV([basepath '\' sortedfilename],'nosave','nomat','report');
newNEV=oldnevdata.NEV;
clear oldnevdata
newNEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
%save([basepath '\' processfilename],'newNEV')
saveNEV(newNEV,processfilename,'report')