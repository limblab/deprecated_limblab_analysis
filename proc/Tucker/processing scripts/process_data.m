%script to set input data and execute data processing
%% process psyhcometrics
folderpath='E:\local processing\chips\experiement_20160111_BD_290degPD';
function_name='quickscript_function_looped';
input_data.matchstring='Chips';
input_data.labnum=6;
input_data.stimcodes=[0 1 2 3];
input_data.num_stim_cases=4;
input_data.currents=[1500 3000 4500 6000];
input_data.current_units='pA';
run_data_processing(function_name,folderpath,input_data)
%% batch of psychometrics:
function_name='quickscript_function_looped';
input_data.labnum=3;
input_data.stimcodes=[0 1 2 3];
input_data.num_stim_cases=4;
input_data.currents=[5 10 15 20];
input_data.matchstring='Kramer';
folderpath='E:\local_processing\kramer\experiment_20130305_0322_BD_70degstim';
run_data_processing(function_name,folderpath,input_data)
%% process PDs
folderpath='E:\local processing\chips\experiment_20160105_RW_PD';
input_data.filename='Chips_20160105_RW_tucker_001.nev';
input_data.matchstring='Chips';
function_name='get_move_pds_function';
input_data.labnum=6;
input_data.array_map_path='Y:\lab_folder\Animal-Miscellany\Chips_12H1\map_files\SN6251-001266.cmp';
data_struct = run_data_processing(function_name,folderpath,input_data);

%% process PDs using Raeed/Tucker functions
folderpath='E:\local processing\chips\experiment_20160110_RW_PD';
input_data.prefix='Chips';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=0;
input_data.do_electrode_pds=1;
input_data.only_sorted=1;
input_data.task='RW';
input_data.offset=-.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=0;%default flag is 0
data_struct = run_data_processing(function_name,folderpath,input_data);

%% force pds
folderpath='E:\local_processing\kevin\04-03-15';
input_data.prefix='Kevin_IsoBoxCO_HC_SpikesEMGsForces_04032015_SN_001';
function_name='get_PDs';
input_data.labnum=1;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=0;
input_data.only_sorted=1;
input_data.task='WF';
input_data.offset=.015;%latency from neural action to motor effect
input_data.binsize=.05;%bin size to compute firing rate
input_data.vel_pd=1;%default flag is 1
input_data.force_pd=1;%default flag is 0
data_struct = run_data_processing(function_name,folderpath,input_data);

%% process single unit PDs
folderpath='Z:\MrT_9I4\Processed\experiment_20141009_RW_file1';
input_data.filename='MrT_RW_20141008_tucker_-4rms_001.nev - Shortcut.lnk';
function_name='move_PDs';
input_data.labnum=6;
data_struct = run_data_processing(function_name,folderpath,input_data);

%% get PDs from bump direction file
folderpath='Z:\MrT_9I4\Processed\experiment_20140903_BD_PDAnalysis';
function_name='BumpDirection_PDs';
input_data.labnum=6;
input_data.matchstring='MrT';
data_struct = run_data_processing(function_name,folderpath,input_data);

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
%% compute SNR
folderpath='';
function_name='analyze_SNR';
run_data_processing(function_name,folderpath,input_data)
%% make polar plots of stimulated electrode groups for chips
folderpath='Z:\Chips_12H1\processed\summary of stim directions';
function_name='make_chips_polar_PD_summaries';
input_data.monkey_name='C';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% Track Neurons across days
folderpath='E:\local processing\pedro\20100726_neuron_tracking';
function_name='get_neuron_matching';
input_data.matchstring='Pedro';
input_data.labnum=2;
data_struct = run_data_processing(function_name,folderpath,input_data);
%% export data for katsaggelos group
folderpath='E:\local processing\pedro\20100726_export_data_for_Katsaggelos_Grp';
function_name='export_for_katsaggelos';
input_data.filename='stable_session.mat';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% export single file data for katsaggelos group
folderpath='E:\local processing\kramer\experiment_20130314_RW_Katsaggelos';
function_name='dump_file_for_katsaggelos';
input_data.filename='Kramer_RW_03142013_tucker_001-01.nev';
input_data.only_sorted=1;
input_data.labnum=3;
input_data.task='RW';
data_struct = run_data_processing(function_name,folderpath,input_data);
%% test encoder skipping:

folderpath='E:\local processing\test_skips';
function_name='testEncoderSkips';
data_struct=run_data_processing(function_name,folderpath);