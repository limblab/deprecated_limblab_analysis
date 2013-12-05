% %quickscript
% 
% %set the mount drive to scan and convert
close all

folderpath_base='E:\processing\bump_task\211degstim\';
matchstring='Kramer';
% %matchstring2='BC';
disp('converting nev files to bdf format')
file_list=autoconvert_nev_to_bdf(folderpath_base,matchstring);
% autoconvert_nev_to_bdf(folderpath,matchstring2)
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath_base,matchstring,0,0,0);
%load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')

make_tdf

%make folder to save into:
mkdir(folderpath_base,strcat('Psychometrics_',date));
folderpath=strcat(folderpath_base,'Psychometrics_',date,'\');
disp('saving new figures and files to:')
disp(folderpath)
fid=fopen(strcat(folderpath,'file_list.txt'),'w+');
fprintf(fid,'%s',file_list);
fclose(fid);

 H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
  title('Catch trials: reaching rate to secondary target') 
 print('-dpdf',H,strcat(folderpath,'Catch_trials_inverted.pdf'))

 [H]=error_rate(bdf.tt,bdf.tt_hdr,[0,1,2,3,4]);
title('error rate by stim condition') 
print('-dpdf',H,strcat(folderpath,'error_rate.pdf'))
 

 [H]=error_rate_aggregate(bdf.tt,bdf.tt_hdr);
title('error rate Stim vs No-stim') 
print('-dpdf',H,strcat(folderpath,'error_rate_aggregate.pdf'))


 %new fitting plus inverting the y axis of the sigmoid
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'5ua_inverted.txt'),'temp','-ascii')
print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_5ua_inverted.pdf'))
  figure(H_cartesian)
title('Psychometric cartesian 5uA inverted')
  figure(H_polar)
title('Psychometric polar 5uA inverted')
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_5ua_inverted.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
  figure(H_cartesian)
title('Psychometric cartesian 10uA inverted')
  figure(H_polar)
title('Psychometric polar 10uA inverted')
save(strcat(folderpath,'10ua_inverted.txt'),'temp','-ascii')
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_10ua_inverted.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,2,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'15ua_inverted.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 15uA inverted')
  figure(H_polar)
title('Psychometric polar 15uA inverted')
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_15ua_inverted.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,3,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'20ua_inverted.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 20uA inverted')
  figure(H_polar)
title('Psychometric polar 20uA inverted')
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_inverted.pdf'))


 
 %new fitting plus inverting the y axis of the sigmoid and folding into a
 %single hemispace
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'5ua_inverted_compressed.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 5uA inverted compressed')
  figure(H_polar)
title('Psychometric polar 5uA inverted compressed')
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_5ua_inverted_compressed.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,1,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'10ua_inverted_compressed.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 10uA inverted compressed')
  figure(H_polar)
title('Psychometric polar 10uA inverted compressed')
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_10ua_inverted_compressed.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,2,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'15ua_inverted_compressed.txt'),'temp','-ascii')
   figure(H_cartesian)
title('Psychometric cartesian 15uA inverted compressed')
  figure(H_polar)
title('Psychometric polar 15uA inverted compressed')
 print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_15ua_inverted_compressed.pdf'))
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,3,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
save(strcat(folderpath,'20ua_inverted_compressed.txt'),'temp','-ascii')
  figure(H_cartesian)
title('Psychometric cartesian 20uA inverted compressed')
  figure(H_polar)
title('Psychometric polar 20uA inverted compressed')
  print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_20ua_inverted_compressed.pdf'))


 %save the executing script to the same folder as the figures and data

fname=strcat(mfilename('fullpath'),'.m');
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end
