clear all;

monkey = 'MrT';
area = 'M1';
date = '02192013';
task = 'UNT1D'; 
id = '001';
type = 'nev';
labnumber = 3;

fname = [monkey '_' area '_' date '_' task '_' id];

bdf=getBDF([fname '.' type],labnumber);
save(['bdf/bdf_' fname '.mat'],'bdf');
tt=getTT_UNT1D(bdf);
save(['tt/tt_' fname '.mat'],'tt');

%%
bdf_m1 = bdf;
clear bdf;
area = 'PMDSORTED';

fname = [monkey '_' area '_' date '_' task '_' id];
bdf=getBDF([fname '.' type],labnumber);



save(['bdf/bdf_' fname '.mat'],'bdf');