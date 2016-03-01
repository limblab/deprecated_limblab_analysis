%% %% Plot PD change predictions based on different coordinate frame neurons

%% load bdf
% bdf = get_nev_mat_data([folder options.prefix],options.labnum);
bdf = get_nev_mat_data('C:\Users\rhc307\Box Sync\Research\Arm Model\Chips_20151203_RWchaos_001\Chips_20151203_RWchaos',6);

%% load joint kinematics
joint_kin_mat = csvread('C:\Users\rhc307\Box Sync\Research\Arm Model\Chips_20151203_RWchaos_001\Muscle analysis\Chips_20151203_RWchaos_001_scaled_Kinematics_q.sto',11,0);
joint_kin = array2table(joint_kin_mat,'VariableNames',{'time','shoulder_adduction','shoulder_rotation','shoulder_flexion','elbow_flexion','radial_pronation','wrist_flexion','wrist_abduction'});
clear joint_kin_mat

%% load muscle kinematics
muscle_kin_mat = csvread('C:\Users\rhc307\Box Sync\Research\Arm Model\Chips_20151203_RWchaos_001\Muscle analysis\Chips_20151203_RWchaos_001_scaled_MuscleAnalysis_Length.sto',12,0);
muscle_kin = array2table(muscle_kin_mat,'VariableNames',{'time','abd_poll_longus','anconeus','bicep_lh','bicep_sh','brachialis','brachioradialis','coracobrachialis','deltoid_ant','deltoid_med','deltoid_pos','dorsoepitrochlearis','ext_carpi_rad_longus','ext_carp_rad_brevis','ext_carpi_ulnaris','ext_digitorum','ext_digiti','ext_indicis','flex_carpi_radialis','flex_carpi_ulnaris','flex_digit_profundus','flex_digit_superficialis','flex_poll_longus','infraspinatus','lat_dorsi_sup','lat_dorsi_cen','lat_dorsi_inf','palmaris_longus','pectoralis_sup','pectoralis_inf','pronator_quad','pronator_teres','subscapularis','supinator','supraspinatus','teres_major','teres_minor','tricep_lat','tricep_lon','tricep_sho'});
clear muscle_kin_mat

%% plot PD change prediction assuming joint-based neurons
