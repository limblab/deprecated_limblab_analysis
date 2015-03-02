%script to set input data and execute data processing
%% process PDs using Raeed/Tucker functions
folderpath='C:\Users\limblab\Documents\local_processing\experiment_20150223_b';
input_data.prefix='Chips_20150223_RW_tucker_001-s';
function_name='get_PDs';
input_data.labnum=6;
input_data.do_unit_pds=1;
input_data.do_electrode_pds=1;
data_struct = run_data_processing(function_name,folderpath,input_data);