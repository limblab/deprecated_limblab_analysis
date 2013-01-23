%quickscript

%set the mount drive to scan and convert
folderpath='E:\processing\';
matchstring='Kramer_bumpchoice_01182013_tucker_001.nev';
% matchstring2='12112012';
% 
autoconvert_nev_to_bdf(folderpath,matchstring)
% autoconvert_nev_to_bdf(folderpath,matchstring2)

% bdf=concatenate_bdfs_from_folder(folderpath,matchstring);
load('E:\processing\Kramer_bumpchoice_01182013_tucker_001.mat')
make_tdf

bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,0,0)
bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,0,0)
bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,2,0,0)
bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,3,0,0)

%plot_aborts(bdf,0,'pos')
%plot_aborts(bdf,1,'pos')

catch_trials(bdf.tt,bdf.tt_hdr,0)
catch_trials(bdf.tt,bdf.tt_hdr,1)
catch_trials(bdf.tt,bdf.tt_hdr,2)
catch_trials(bdf.tt,bdf.tt_hdr,3)
% bdf=concatenate_bdfs_from_folder(folderpath,matchstring2);
% make_tdf
% 
% bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,0,0,0)
% bc_psychometric_curve_stim3(bdf.tt,bdf.tt_hdr,1,0,0)
% 
% plot_aborts(bdf,0,'pos')
% plot_aborts(bdf,1,'pos')
% 
% catch_trials(bdf.tt,bdf.tt_hdr,0)
% catch_trials(bdf.tt,bdf.tt_hdr,1)




