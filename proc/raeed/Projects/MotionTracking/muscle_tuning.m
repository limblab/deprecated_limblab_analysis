%% load in muscle data
folder = '/home/raeed/Projects/limblab/FSMRes/limblab/User_folders/Raeed/Arm Model/Data/Chips/experiment_20151203_RW_002/';
opensim_prefix = 'Chips_20151203_0-320';

muscle_pos_mat = csvread([folder 'Analysis/' opensim_prefix '_MuscleAnalysis_Length.sto'],12,0);
muscle_pos = array2table(muscle_pos_mat,'VariableNames',{'time','abd_poll_longus','anconeus','bicep_lh','bicep_sh','brachialis','brachioradialis','coracobrachialis','deltoid_ant','deltoid_med','deltoid_pos','dorsoepitrochlearis','ext_carpi_rad_longus','ext_carp_rad_brevis','ext_carpi_ulnaris','ext_digitorum','ext_digiti','ext_indicis','flex_carpi_radialis','flex_carpi_ulnaris','flex_digit_profundus','flex_digit_superficialis','flex_poll_longus','infraspinatus','lat_dorsi_sup','lat_dorsi_cen','lat_dorsi_inf','palmaris_longus','pectoralis_sup','pectoralis_inf','pronator_quad','pronator_teres','subscapularis','supinator','supraspinatus','teres_major','teres_minor','tricep_lat','tricep_lon','tricep_sho'});
clear muscle_pos_mat

%% try muscle PCA
[coeff,score,latent] = pca(muscle_pos{:,2:end});

% use first 5 PCs
muscle_scores = score(:,1:5);
times = muscle_pos.time;

%% Get muscle velocities
% interpolate muscle lengths
interp_times = times(1):0.03:times(end);
interp_muscle_scores = interp1(times,muscle_scores,interp_times);

% get muscle velocities
muscle_vel = interp_muscle_scores;
for i=1:size(interp_muscle_scores,2)
    muscle_vel{:,i} = gradient(muscle_pos{:,i},muscle_pos.time);
end

clear i