

 clear bdf;
 fname='Kramer_RW_03142013_tucker_001-01.nev';
 fbase1='E:\processing\';
 
 disp(strcat('Loading: ',fname))
 disp(strcat('From directory: ',fbase1))
 
 bdf=get_cerebus_data(strcat(fbase1,fname),3,'verbose','noeye');
 %make_tdf
 %fbase2='Kramer_RW_02122013_tucker_x10_y33_001-02.nev';
 fname=strcat(fname(1:(end-3)),'mat');
  
 disp(strcat('Saving: ',fname))
 disp(strcat('To directory: ',fbase1))
 save( strcat(fbase1,fname),'bdf');
% load(strcat(fbase1,fname));
 PD_posvel_plot(bdf,'Kramer',2,1)