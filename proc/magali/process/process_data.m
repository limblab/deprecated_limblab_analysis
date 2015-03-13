%script to set input data and execute data processing
%% process PDs using Raeed/Tucker functions
folderpath='Z:\Han_13B1\Processed\experiment_20150311_RW\area_2 bank_A2';
input_data.prefix='Han_20150311_RW_Magali_2A2_001-s';
input_data.only_sorted=1
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
data_struct = run_data_processing(function_name,folderpath,input_data);
%% check for electrode stability
folderpath='Z:\Han_13B1\Processed\week_0309_0313_stability_RW\area_3 bank_B2\electrode_stability';
function_name='compute_electrode_stability';
input_data.num_channels=32;
input_data.min_moddepth=2*10^-4;
electrode_stability=run_data_processing(function_name,folderpath,input_data);
%% check for unit stability
folderpath='Z:\Han_13B1\Processed\week_0309_0313_stability_RW\area_2 bank_A2\unit_stability';
function_name='compute_unit_stability';
input_data.num_channels=32;
input_data.min_moddepth=2*10^-4;
unit_stability=run_data_processing(function_name,folderpath,input_data);