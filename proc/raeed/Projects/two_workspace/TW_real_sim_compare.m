%% Script to compare PD changes from real neurons to Monte Carlo simulated neurons given intrinsic coordinates

%% Chips 20151203
folder = '/home/raeed/Projects/limblab/FSMRes/limblab/User_folders/Raeed/Arm Model/Data/Chips/experiment_20151203_RW_002/';
clear options
options.prefix = 'Chips_20151203_RW_002';
options.opensim_prefix = 'Chips_20151203_0-320';
options.labnum = 6;
options.dual_array = 0;
options.time_window = [0 320];
function_name = 'plot_PD_predictions';

dbstop if error
output_data_pred = run_data_processing(function_name,folder,options);
dbclear if error