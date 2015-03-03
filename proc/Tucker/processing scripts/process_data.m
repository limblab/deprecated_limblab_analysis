%script to set input data and execute data processing
%% process psyhcometrics
folderpath='Z:\MrT_9I4\Processed\experiment_20141118_BD_159deg';
function_name='quickscript_function_looped';
input_data.matchstring='MrT';
input_data.labnum=6;
input_data.stimcodes=[0 1 2];
input_data.num_stim_cases=3;
input_data.currents=[20 30 40];
run_data_processing(function_name,folderpath,input_data)

%% process PDs
folderpath='C:\Users\limblab\Documents\local_processing\experiment_20150223';
input_data.filename='Chips_20150223_RW_tucker_001-01.nev';
input_data.matchstring='Chips';
function_name='get_move_pds_function';
input_data.labnum=6;
input_data.array_map_path='Y:\lab_folder\Animal-Miscellany\Chips_12H1\map_files\SN6251-001266.cmp';
data_struct = run_data_processing(function_name,folderpath,input_data);

%% process PDs using Raeed/Tucker functions
folderpath='C:\Users\limblab\Documents\local_processing\chips\experiment_20150223_b';
input_data.prefix='Chips_20150223_RW_tucker_001-01';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;
data_struct = run_data_processing(function_name,folderpath,input_data);

%% process single unit PDs
folderpath='Z:\MrT_9I4\Processed\experiment_20141009_RW_file1';
input_data.filename='MrT_RW_20141008_tucker_-4rms_001.nev - Shortcut.lnk';
function_name='move_PDs';
input_data.labnum=6;
run_data_processing(function_name,folderpath,input_data)

%% get PDs from bump direction file
folderpath='Z:\MrT_9I4\Processed\experiment_20140903_BD_PDAnalysis';
function_name='BumpDirection_PDs';
input_data.labnum=6;
input_data.matchstring='MrT';
run_data_processing(function_name,folderpath,input_data)

%% check for unit stability
folderpath='C:\Users\limblab\Documents\local_processing\chips\20150220-27_unit_stability';
function_name='compute_unit_stability';
input_data.num_channels=96;
input_data.min_moddepth=2*10^-4;
unit_stability=run_data_processing(function_name,folderpath,input_data);
%% check for electrode stability
folderpath='C:\Users\limblab\Documents\local_processing\chips\20150220-27_electrode_stability';
function_name='compute_electrode_stability';
input_data.num_channels=96;
input_data.min_moddepth=2*10^-4;
electrode_stability=run_data_processing(function_name,folderpath,input_data);