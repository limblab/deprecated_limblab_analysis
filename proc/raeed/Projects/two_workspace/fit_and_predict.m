% fit to each coordinate in one workspace and predict the PD in the next

%% read files in
folder = '/home/raeed/Projects/limblab/FSMRes/limblab/User_folders/Raeed/Arm Model/Data/Chips/experiment_20151203_RW_002/';
prefix =  'Chips_20151203_RW_002';
labnum =  6;
opensim_prefix = 'Chips_20151203_0-320';
time_window = [1 319];

bdf = get_nev_mat_data([folder prefix],labnum);

% extract separate workspaces
times_PM = extract_workspace_times(bdf,[-10 -55],[0 -45]);
times_DL = extract_workspace_times(bdf,[0 -45],[10 -35]);

bdf.meta.task = 'RW';
opts.binsize=0.05;
opts.offset=-.015;
opts.do_trial_table=1;
opts.do_firing_rate=1;
bdf=postprocess_bdf(bdf,opts);

joint_pos_mat = csvread([folder 'Analysis/' opensim_prefix '_Kinematics_q.sto'],11,0);
bdf.joint_pos = array2table(joint_pos_mat,'VariableNames',{'time','shoulder_adduction','shoulder_rotation','shoulder_flexion','elbow_flexion','radial_pronation','wrist_flexion','wrist_abduction'});
clear joint_pos_mat

muscle_pos_mat = csvread([folder 'Analysis/' opensim_prefix '_MuscleAnalysis_Length.sto'],12,0);
bdf.muscle_pos = array2table(muscle_pos_mat,'VariableNames',{'time','abd_poll_longus','anconeus','bicep_lh','bicep_sh','brachialis','brachioradialis','coracobrachialis','deltoid_ant','deltoid_med','deltoid_pos','dorsoepitrochlearis','ext_carpi_rad_longus','ext_carp_rad_brevis','ext_carpi_ulnaris','ext_digitorum','ext_digiti','ext_indicis','flex_carpi_radialis','flex_carpi_ulnaris','flex_digit_profundus','flex_digit_superficialis','flex_poll_longus','infraspinatus','lat_dorsi_sup','lat_dorsi_cen','lat_dorsi_inf','palmaris_longus','pectoralis_sup','pectoralis_inf','pronator_quad','pronator_teres','subscapularis','supinator','supraspinatus','teres_major','teres_minor','tricep_lat','tricep_lon','tricep_sho'});
clear muscle_pos_mat

%% get muscle PCA
[coeff,score,latent] = pca(bdf.muscle_pos{:,2:end});

% use first 5 PCs
muscle_scores = score(:,1:5);

%% Fit neuron to muscle in one workspace (bootstrap)

%% Predict tuning in other workspace

%% Plot tuning in both workspaces