%script to test out npmk load

foldername='E:\processing\pre_DARPA\210degstim\';
filename='Kramer_BC_02282013_tucker_4ch_stim_004.nev';

NEV = openNEV(strcat(foldername,filename),'read','report','nosave','nomat','uV');

