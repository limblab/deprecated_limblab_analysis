% bdf1=load( 'E:\processing\Kramer_BC_02222013_tucker_4ch_stim_002.mat');
% bdf1=bdf1.bdf;
% bdf2=load( 'E:\processing\Kramer_BC_02232013_tucker_4ch_stim_001.mat');
% bdf2=bdf2.bdf;
% bdf3=load( 'E:\processing\Kramer_BC_02252013_tucker_4ch_stim_001.mat');
% bdf3=bdf3.bdf;
% full_bdf=concatenate_bdfs(bdf1,bdf2,30);
% full_bdf=concatenate_bdfs(full_bdf,bdf3,30);
% 
% bdf=bdf1;
% make_tdf;
% bdf1=bdf;
% 
% bdf=bdf2;
% make_tdf;
% bdf2=bdf;
% 
% bdf=bdf3;
% make_tdf;
% bdf.tt=fix_coding(bdf.tt,40,[-1,0,1],[-1,2,3]);
% bdf3=bdf;
% 
% tt_full=concatenate_trial_tables(bdf1.tt_hdr,bdf1.tt,bdf2.tt,30);
% tt_full=concatenate_trial_tables(bdf1.tt_hdr,tt_full,bdf3.tt,30);
% 
% full_bdf.tt=tt_full;
% full_bdf.tt_hdr=bdf1.tt_hdr;
% 
% save('full_bdf_02222013_02252013.mat','full_bdf')

sig1=bc_psychometric_curve_stim4(full_bdf.tt,full_bdf.tt_hdr,0,0,0)
sig2=bc_psychometric_curve_stim4(full_bdf.tt,full_bdf.tt_hdr,1,0,0)
sig3=bc_psychometric_curve_stim4(full_bdf.tt,full_bdf.tt_hdr,2,0,0)
sig4=bc_psychometric_curve_stim4(full_bdf.tt,full_bdf.tt_hdr,3,0,0)

%plot_aborts(bdf,0,'pos')
%plot_aborts(bdf,1,'pos')

 catch_trials(full_bdf.tt,full_bdf.tt_hdr,0)
 catch_trials(full_bdf.tt,full_bdf.tt_hdr,1)
 catch_trials(full_bdf.tt,full_bdf.tt_hdr,2)
 catch_trials(full_bdf.tt,full_bdf.tt_hdr,3)