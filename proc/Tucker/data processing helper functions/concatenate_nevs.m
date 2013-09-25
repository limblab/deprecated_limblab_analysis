

file_1='E:\processing\Kramer_BC_02222013_tucker_4ch_stim_002.nev';
file_2='E:\processing\Kramer_BC_02232013_tucker_4ch_stim_001.nev';
savename='E:\processing\4ch_stim_02222013_02232013_grouped.nev';

NEV1=openNEV(file_1,'report','read');
NEV2=openNEV(file_2,'report','read');


NEV = addNEV(NEV1, NEV2, 'report', 'offset', 10);
saveNEV(NEV, savename, 'report');