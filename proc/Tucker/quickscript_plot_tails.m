%quickscript_plot_tails

%% clean up
 clear all
 close all
%% load the bdf from a file
%filename='E:\processing\270deg_single_electrode_80ua\Kramer_BC_05072013_tucker_4ch_stim_270deg_tgt_single_elec_80ua_001.mat';
%filename='E:\processing\20deg_single_electrode_80ua\Kramer_BC_0426013_tucker_4ch_stim_21deg_tgt_single_elec_80ua_001.mat';
folderpath='E:\processing\post_DARPA\bump_task\352degstim\sequester\';
filename='Kramer_BC_06072013_tucker_352deg_4ch_stim_001.mat';

load(strcat(folderpath,filename))
%% make tt fields
make_tdf

%% plot the tail choices
mkdir(folderpath,'Tail_choice_plots')
folderpath_tails=strcat(folderpath,'Tail_choice_plots\');
 [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr,0);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_all_electrodes.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_all_electrodes.pdf'))
 
  [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr,1);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_electrode1.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_electrode1.pdf'))
 
 [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr,2);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_electrode2.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_electrode2.pdf'))
 
 [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr,3);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_electrode3.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_electrode3.pdf'))
 
 [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr,4);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_electrode4.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_electrode4.pdf'))
 
 [H1,H2]=plot_tail_choices(bdf.tt,bdf.tt_hdr);
 print('-dpdf',H1,strcat(folderpath_tails,'primary_direction_tail_all_stim_trials.pdf'))
 print('-dpdf',H2,strcat(folderpath_tails,'secondary_direction_tail_all_stim_trials..pdf'))
 
  %% save the executing script to the same folder as the figures and data
fname=strcat(mfilename,'.m');
disp(strcat('attempting to write file: ',fname))
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath_tails);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end


%% plot the center choices
mkdir(folderpath,'Center_choice_plots')
folderpath_center=strcat(folderpath,'Center_choice_plots\');
H1=plot_center_choices(bdf.tt,bdf.tt_hdr,0);
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_all_electrodes.pdf'))
 
plot_center_choices(bdf.tt,bdf.tt_hdr,1)
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_electrode1.pdf'))
 
plot_center_choices(bdf.tt,bdf.tt_hdr,2)
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_electrode2.pdf'))
 
plot_center_choices(bdf.tt,bdf.tt_hdr,3)
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_electrode3.pdf'))
 
plot_center_choices(bdf.tt,bdf.tt_hdr,4)
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_electrode4.pdf'))
 
 plot_center_choices(bdf.tt,bdf.tt_hdr)
 print('-dpdf',H1,strcat(folderpath_center,'center_choices_all_stim_trials.pdf'))
 
  %save the executing script to the same folder as the figures and data

fname=strcat(mfilename,'.m');
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath_center);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end


