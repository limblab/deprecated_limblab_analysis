% %quickscript_2PD
% 
% %set the mount drive to scan and convert
close all

folderpath='E:\processing\25deg_2dirstim\';
matchstring='Kramer';
% %matchstring2='BC';
disp('converting nev files to bdf format')
autoconvert_nev_to_bdf(folderpath,matchstring)
% autoconvert_nev_to_bdf(folderpath,matchstring2)
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath,matchstring,0,0);
%load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')

make_tdf

%make folder to save into:
mkdir(folderpath,strcat('Psychometrics_',date));
folderpath=strcat(folderpath,'\','Psychometrics_',date,'\')
disp('saving new figures and files to:')
disp(folderpath)

[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H] = bc_psychometric_curve_stim3_nofit2(bdf.tt,bdf.tt_hdr,0,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'21deg_15uA.txt'),'temp','-ascii')
figure(H)
title('Psychometric cartesian 21deg 15uA nofit')
print('-deps',H,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_nofit.eps'))
print('-dpdf',H,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_nofit.pdf'))
[dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H] = bc_psychometric_curve_stim3_nofit2(bdf.tt,bdf.tt_hdr,1,0,0);
temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'210deg_15uA.txt'),'temp','-ascii')
figure(H)
title('Psychometric_cartesian_210deg_15uA_nofit')
print('-deps',H,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_nofit.eps'))
print('-dpdf',H,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_nofit.pdf'))




%plot_aborts(bdf,0,'pos')
%plot_aborts(bdf,1,'pos')

 H=catch_trials(bdf.tt,bdf.tt_hdr,0);
 figure(H)
 title('Catch trials 21deg 15uA')
 print('-deps',H,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_catch.eps'))
 print('-dpdf',H,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_catch.pdf'))
 H=catch_trials(bdf.tt,bdf.tt_hdr,1);
 figure(H)
 title('Catch trials 210deg 15uA')
 print('-deps',H,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_catch.eps'))
 print('-dpdf',H,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_catch.pdf'))

 
 H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1],0);
 print('-deps',H,strcat(folderpath,'Catch_trials.eps'))
 print('-dpdf',H,strcat(folderpath,'Catch_trials.pdf'))
 H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1],1);
 print('-deps',H,strcat(folderpath,'Catch_trials_inverted.eps'))
 print('-dpdf',H,strcat(folderpath,'Catch_trials_inverted.pdf'))
 
 %plotting with new fitting algorythem
 %bc_psychometric_curve_stim3(tt,tt_hdr,stimcode,invert_dir,plot_error,invert_error)
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,0,0,0);
  temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'21deg_15uA.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 21deg 15uA')
  figure(H_polar)
title('Psychometric polar 21deg 15uA')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA.pdfs'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,0,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'210deg_15uA.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 210deg 15uA')
  figure(H_polar)
title('Psychometric polar 210deg 15uA')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA.pdf'))

 %new fitting plus inverting the y axis of the sigmoid
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'21deg_15uA_inverted.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 21deg 15uA inverted')
  figure(H_polar)
title('Psychometric polar 21deg 15uA inverted')

 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_inverted.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_inverted.eps'))
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_inverted.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_inverted.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'210deg_15uA_inverted.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 210deg 15uA inverted')
  figure(H_polar)
title('Psychometric polar 210deg 15uA inverted')

 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_inverted.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_inverted.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_inverted.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_inverted.pdf'))


 %folding the 180->360deg bumps onto the 0->180 hemispace for cleaner plots
  [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,0,0,0);
  
  temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'21deg_15uA_compressed.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 21deg 15uA')
  figure(H_polar)
title('Psychometric polar 21deg 15uA')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_compressed.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_compressed.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_compressed.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_compressed.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,1,0,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'210deg_15uA_compressed.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 210deg 15uA')
  figure(H_polar)
title('Psychometric polar 210deg 15uA')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_compressed.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_compressed.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_compressed.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_compressed.pdf'))

 %new fitting plus inverting the y axis of the sigmoid
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'21deg_15uA_compressed_inverted.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 21deg 15uA inverted')
  figure(H_polar)
title('Psychometric polar 21deg 15uA inverted')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_inverted_compressed.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_inverted_compressed.eps'))
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_21deg_15uA_inverted_compressed.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_21deg_15uA_inverted_compressed.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,1,1,0,0);
  temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'210deg_15uA_compressed_inverted.txt'),'temp','-ascii')
figure(H_cartesian)
title('Psychometric cartesian 210deg 15uA inverted')
  figure(H_polar)
title('Psychometric polar 210deg 15uA inverted')
 print('-deps',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_inverted_compressed.eps'))
 print('-deps',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_inverted_compressed.eps'))
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_210deg_15uA_inverted_compressed.pdf'))
 print('-dpdf',H_polar,strcat(folderpath,'Psychometric_polar_210deg_15uA_inverted_compressed.pdf'))





