%% strip digital data from NEV
basepath='Z:\Han_13B1\Processed\experiment_20150417_RW\before_stim';
basefilename='Han_20150417_RW_Magali_area2_A2_area3_b2_001';
nodigitalfilename='Han_20150417_RW_Magali_area2_A2_area3_b2_001-nodigital.nev';
spikelessfilename='Han_20150417_RW_Magali_area2_A2_area3_b2_001-nospikes.mat';


%open data
NEV = openNEV('read', [basepath, '\', basefilename],'nosave','nomat','report');
%save just the spike data for sorting
saveNEVOnlySpikes2(NEV,[basepath '\'  nodigitalfilename]);
%save everything except the spikes so the nev can be recomposed.
saveNEVOnlyDigital(NEV,[basepath '\' spikelessfilename]);


%% save append digital data back on and re-save (doesn't have to be used)
basepath='Z:\Han_13B1\Processed\experiment_20150406_RW';
sortedfilename='Han_20150406_RW_Magali_area2_A2_001-nodigital.nev';
spikelessfilename='Han_20150406_RW_Magali_area2_A2_001-nospikes.mat';
processfilename='Han_20150406_RW_Magali_area2_A2_001-s.nev';

oldnevdata=load([basepath '\' spikelessfilename]);
sortednev=openNEV([basepath '\' sortedfilename],'nosave','nomat','report');
newNEV=oldnevdata.NEV;
clear oldnevdata
newNEV.Data.Spikes=sortednev.Data.Spikes;
clear sortednev
%save([basepath '\' processfilename],'newNEV')
saveNEV(newNEV,processfilename,'report')