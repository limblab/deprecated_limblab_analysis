%% cross-correlations with joint movement
% data working directory
folder = 'C:\Users\rhc307\Documents\Data\experiment_20151201_COactpas_001\';
prefix = 'Chips_20151201_COactpas_001';

% load bdf
bdf = get_nev_mat_data([folder prefix],6);

bdf.meta.task = 'CO';
opts.binsize=0.05;
opts.offset=-.015;
opts.do_trial_table=1;
opts.do_firing_rate=1;
bdf=postprocess_bdf(bdf,opts);

% load kinematics
kinematics_name = [folder prefix '_Kinematics_q_noheader.csv'];
