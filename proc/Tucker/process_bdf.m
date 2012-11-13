

 clear bdf;
 fname='Kramer_BumpDir_10182012_tucker_with_stim_001.nev';
 fbase1='\\CITADEL\data\Kramer_10I1\BumpDirection\Data Raw\Post-implant\';
 
 disp(strcat('Loading: ',fname))
 disp(strcat('From directory: ',fbase1))
 
 bdf=get_cerebus_data(strcat(fbase1,fname));
 make_tdf
 fbase2='\\CITADEL\data\Kramer_10I1\BumpDirection\Data bdf\';
 fname=strcat(fname(1:(end-3)),'mat');
  
 disp(strcat('Saving: ',fname))
 disp(strcat('To directory: ',fbase2))
 save( strcat(fbase2,fname),bdf);
 