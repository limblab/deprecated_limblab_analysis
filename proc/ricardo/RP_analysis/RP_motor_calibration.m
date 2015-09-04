params.RP_file_prefix = 'MotorCalibrationLab3_2015-08-28_001';
target_folder = 'D:\MotorCalibration\';

params.reprocess_data = 0;
params.plot_behavior = 0;
params.plot_units = 0;
params.plot_each_neuron = 0;
params.plot_emg = 0;
params.plot_predicted_emg = 0;
params.plot_raw_emg = 0;
params.plot_pca = 0;
params.make_movie = 0;
params.cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Jaco 8I1\2014-02-04 Left Hemisphere Removal and Reimplant\SN_6250-001275_LH2.cmp';
params.left_handed = 0;
params.rot_handle = 0;

[fig_handles,data_struct] = RP_analysis(target_folder,params);
RP = data_struct.RP;

force_angle = mean(RP.force_bump_angle(:,end/2:end),2);
force_magnitude = mean(RP.force_bump_magnitude(:,end/2:end),2);

commanded_force_angle = RP.bump_directions;
commanded_force_magnitude = unique(RP.trial_table(:,RP.table_columns.bump_magnitude));

figure; 
plot(cos(force_angle).*force_magnitude,sin(force_angle).*force_magnitude,'.')
hold on
plot(cos(commanded_force_angle)*commanded_force_magnitude,...
    sin(commanded_force_angle)*commanded_force_magnitude,'o')
axis equal
