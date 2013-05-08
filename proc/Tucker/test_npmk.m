%script to test out npmk load

foldername='E:\processing\210deg_single_electrode\';
filename='Kramer_BC_04112013_tucker_4ch_stim_210deg_tgt_cereport_adaptor_test001.nev';

NEV = openNEV(strcat(foldername,filename),'read','report','nosave','nomat','uV');

