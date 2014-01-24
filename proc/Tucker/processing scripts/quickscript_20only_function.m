function [figure_list,data_struct]=quickscript_20only_function(fpath)
% %quickscript
% 
% %set the mount drive to scan and convert
close all

folderpath_base='E:\processing\CO_bump\BD efficacy checking\37degstim\';
matchstring='Kramer';

disp('converting nev files to bdf format')
file_list=autoconvert_nev_to_bdf(folderpath_base,matchstring);
data_struct.file_list=file_list;
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath_base,matchstring,0,0,0);
data_struct.Aggregate_bdf=bdf;

bdf=make_tdf_function(bdf);

 H=catch_trials_all(bdf.tt,bdf.tt_hdr,[0,1,2,3],1);
  title('Catch trials: reaching rate to secondary target') 
  set(H,'Name','Catch Trials')
 figure_list{1}=H;

 [H]=error_rate(bdf.tt,bdf.tt_hdr,[0,1,2,3,4]);
title('error rate by stim condition') 
set(H,'Name','error rate by stim condition')
 figure_list{length(figure_list)+1}=H;

 [H]=error_rate_aggregate(bdf.tt,bdf.tt_hdr);
title('error rate Stim vs No-stim') 
figure_list{length(figure_list)+1}=H;

 %new fitting plus inverting the y axis of the sigmoid
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data=temp;
  figure(H_cartesian)
title('Psychometric cartesian 20uA inverted')
  figure(H_polar)
title('Psychometric polar 20uA inverted')


 
 %new fitting plus inverting the y axis of the sigmoid and folding into a
 %single hemispace
 [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian, H_polar] =  bc_psychometric_curve_stim3_compressed(bdf.tt,bdf.tt_hdr,0,1,0,0);
 temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
data_struct.reach_data_collapsed=temp;
  figure(H_cartesian)
title('Psychometric cartesian 20uA inverted compressed')
  figure(H_polar)
title('Psychometric polar 20uA inverted compressed')
end


 
