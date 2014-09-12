params.UR_file_prefix = 'Chewie_2014-09-12_UR_HC';
target_folder = ['D:\Data\Chewie_8I2\' params.UR_file_prefix];
params.reprocess_data = 1;
params.plot_behavior = 0;
params.plot_units = 0;
params.plot_emg = 0;
params.plot_raw_emg = 0;
params.make_movie = 0;
params.movie_range = [10 250];
params.rot_handle = 1; 
params.fig_handles = [];
params.cmp_file = '\\citadel\limblab\lab_folder\Animal-Miscellany\Kevin 12A2\Microdrive info\MicrodriveMapFile_diagonal.cmp';
params.left_handed = 1;

data_struct = run_data_processing('UR_analysis',target_folder,params);
params = data_struct.params;